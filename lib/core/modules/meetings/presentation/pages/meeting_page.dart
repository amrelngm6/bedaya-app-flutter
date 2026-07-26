import 'package:bedaya2/core/di/service_locator.dart';
import 'package:bedaya2/core/modules/auth/models/patient_model.dart';
import 'package:bedaya2/core/modules/meetings/models/meeting_model.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key, this.meeting});

  final MeetingModel? meeting;

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _jitsiMeetPlugin = JitsiMeet();

  // Track whether a conference is currently active so we don't call
  // hangUp()/dispose logic twice, and so we know when it's safe to pop.
  bool _isMeetingActive = false;

  @override
  void dispose() {
    // Belt-and-braces: if the widget is torn down while a conference is
    // still technically active (e.g. user backgrounds the app and the
    // page gets disposed), make sure we tell the native side to hang up
    // and release the camera before the Dart side goes away.
    // if (_isMeetingActive) {
    _jitsiMeetPlugin.hangUp();
    // }
    super.dispose();
  }

  PatientModel? myProfile;

  void _fetchProfile() async {
    final result = await sl.auth.getMyProfile();
    if (!mounted) return;
    if (result case Success(:final data)) {
      setState(() {
        myProfile = PatientModel.fromJson(data.toJson());
      });
    }
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    return statuses.values.every((s) => s.isGranted);
  }

  void _joinMeeting() async {
    if (!await _ensurePermissions()) {
      return;
    }
    final listener = JitsiMeetEventListener(
      conferenceJoined: (url) {
        setState(() => _isMeetingActive = true);
        debugPrint('Bedaya: conference joined -> $url');
      },

      conferenceTerminated: (url, error) async {
        debugPrint('Bedaya: conference terminated -> $url, error: $error');
        _isMeetingActive = false;

        // This explicit hangUp() is what actually tells the native
        // Android/iOS side to tear down the conference (camera, mic,
        // renderer). Without it, on some OEM ROMs (Oppo/OnePlus/Realme
        // "ColorOS" builds) the camera manager keeps getting pinged
        // in the background because the native surface never released.
        await _jitsiMeetPlugin.hangUp();

        Navigator.of(context).pop();
      },
      participantLeft: (participantId) async {
        // Leave the meeting
        setState(() => _isMeetingActive = false);
        await _jitsiMeetPlugin.hangUp();
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );

    var options = JitsiMeetConferenceOptions(
      // 1. Point to your self-hosted subdomain
      serverURL: "https://meet.bedayaapp.com",

      // 2. Define room name
      room: widget.meeting?.meetingID ?? "bedaya-meeting-${widget.meeting?.id}",

      // 3. Optional conference settings
      // configOverrides: {
      //   "startWithAudioMuted": false,
      //   "startWithVideoMuted": false,
      // },
      featureFlags: {"welcomepage.enabled": true},

      // 4. User details
      userInfo: JitsiMeetUserInfo(
        displayName: myProfile?.fullName ?? "Guest",
        email: myProfile?.email ?? "",
      ),
    );

    await _jitsiMeetPlugin.setVideoMuted(false);

    await _jitsiMeetPlugin.setAudioMuted(false);

    // Call join, passing the listener as the second argument.
    // join() returns once the native SDK has been handed the options;
    // it does NOT block until the user leaves — cleanup happens inside
    // the conferenceTerminated callback above.
    await _jitsiMeetPlugin.join(options, listener);
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Meeting'.tr())),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _isMeetingActive ? null : _joinMeeting,
              child: Text('Join Meeting'.tr()),
            ),
          ),
          myProfile?.fullName != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('${'welcome_back'.tr()} ${myProfile?.fullName}'),
                )
              : Container(),
        ],
      ),
    );
  }
}
