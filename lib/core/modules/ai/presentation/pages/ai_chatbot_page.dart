import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bedaya2/core/theme/colors.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/login_page.dart';
import 'package:bedaya2/core/modules/auth/presentation/pages/register_page.dart';
import 'package:bedaya2/core/modules/bookings/presentation/widgets/auth_required_sheet.dart';
import 'package:bedaya2/core/di/service_locator.dart';
import '../widgets/ai_text_chat_widget.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _checkAuthAndProceed(back: false);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Auth Gate ────────────────────────────────────────────────────────────
  void _checkAuthAndProceed({bool? back = false}) {
    if (!sl.storage.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAuthModal(back: back);
      });
    }
  }

  Future<void> _showAuthModal({bool? back = false}) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (sheetCtx) => AuthRequiredSheet(
        onNavigateToLogin: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onNavigateToRegister: () async {
          await Navigator.push(
            sheetCtx,
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          );
          if (sl.storage.isLoggedIn && sheetCtx.mounted) {
            Navigator.pop(sheetCtx);
          }
        },
        onGoBack: () {
          Navigator.pop(sheetCtx);
          if (mounted) Navigator.pop(context);
        },
      ),
    );

    // If the modal was closed without authenticating, leave the booking page.
    if (mounted && !sl.storage.isLoggedIn && back == true) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Assistant'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: AITextChatWidget(),
    );
  }
}
