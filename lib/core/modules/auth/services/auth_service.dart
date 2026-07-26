import 'package:dio/dio.dart';

import 'package:bedaya2/core/modules/auth/models/auth_models.dart';
import 'package:bedaya2/core/network/api_endpoints.dart';
import 'package:bedaya2/core/network/base_api_service.dart';
import 'package:bedaya2/core/network/network_result.dart';
import 'package:bedaya2/core/services/storage_service.dart';

/// Handles all authentication flows:
/// - Login / Register
/// - OTP verification and resend
/// - Forgot / Reset password
/// - Change password (authenticated)
/// - Profile retrieval and update
/// - Logout
///
/// Tokens are automatically persisted to [StorageService] on successful
/// login / register.
class AuthService extends BaseApiService {
  AuthService(super.client, this._storage);

  final StorageService _storage;

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<NetworkResult<AuthResponse>> login(LoginRequest request) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.login,
          data: request.toJson(),
        );
        final auth = AuthResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
        await _storage.saveAuthResponse(auth);
        return auth;
      });

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<NetworkResult<AuthResponse>> register(RegisterRequest request) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.register,
          data: request.toJson(),
        );
        final auth = AuthResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
        await _storage.saveAuthResponse(auth);
        return auth;
      });

  // ─── Validate Phone ─────────────────────────────────────────────────

  Future<NetworkResult<MessageResponse>> checkPhoneExists(String phone) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.checkPhoneExists,
          data: {'phone': phone.trim()},
        );
        return MessageResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });

  // ─── OTP ──────────────────────────────────────────────────────────────────

  Future<NetworkResult<MessageResponse>> verifyOtp(VerifyOtpRequest request) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.verifyOtp,
          data: request.toJson(),
        );
        return MessageResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });

  Future<NetworkResult<MessageResponse>> resendOtp(String phone) =>
      execute(() async {
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.resendOtp,
          data: {'phone': phone.trim()},
        );
        return MessageResponse.fromJson(
          response.data!['data'] as Map<String, dynamic>,
        );
      });

  // ─── Password management ──────────────────────────────────────────────────

  Future<NetworkResult<MessageResponse>> forgotPassword(
    ForgotPasswordRequest request,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  Future<NetworkResult<MessageResponse>> resetPassword(
    ResetPasswordRequest request,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  Future<NetworkResult<MessageResponse>> changePassword(
    ChangePasswordRequest request,
  ) => execute(() async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiEndpoints.changePassword,
      data: request.toJson(),
    );
    return MessageResponse.fromJson(
      response.data!['data'] as Map<String, dynamic>,
    );
  });

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<NetworkResult<UserModel>> getMyProfile() => execute(() async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.myProfile,
    );
    final user = UserModel.fromJson(
      response.data!['data']['user'] as Map<String, dynamic>,
    );
    await _storage.updateUser(user);
    return user;
  });

  Future<NetworkResult<UserModel>> updateProfile(
    UpdateProfileRequest request,
  ) => execute(() async {
    final response = await dio.put<Map<String, dynamic>>(
      ApiEndpoints.updateProfile,
      data: request.toJson(),
    );
    final user = UserModel.fromJson(_dataOf(response.data!));
    await _storage.updateUser(user);
    return user;
  });

  /// Uploads a profile avatar.  [imagePath] is the local file path.
  Future<NetworkResult<UserModel>> updateAvatar(String imagePath) =>
      execute(() async {
        final formData = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(imagePath),
        });
        final response = await dio.post<Map<String, dynamic>>(
          ApiEndpoints.updateAvatar,
          data: formData,
        );
        final user = UserModel.fromJson(_dataOf(response.data!));
        await _storage.updateUser(user);
        return user;
      });

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Calls the server logout endpoint (revokes the token) then clears all
  /// locally stored credentials.
  Future<NetworkResult<void>> logout() async {
    // Best-effort server call — clear local data regardless of outcome.
    await execute(() => dio.post<void>(ApiEndpoints.logout));
    await _storage.clearAuthData();
    return const Success(null);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  

  /// Unwraps a `{ "data": {...} }` wrapper if present, otherwise returns
  /// the map as-is.
  Map<String, dynamic> _dataOf(Map<String, dynamic> json) =>
      json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;

  List<String> countriesList() {
    return [
      'Egypt',
      'Afghanistan',
      'Albania',
      'Algeria',
      'Andorra',
      'Angola',
      'Antigua and Barbuda',
      'Argentina',
      'Armenia',
      'Australia',
      'Austria',
      'Azerbaijan',
      'Bahamas ',
      'Bahrain',
      'Bangladesh',
      'Barbados',
      'Belarus',
      'Belgium',
      'Belize',
      'Benin',
      'Bhutan',
      'Bolivia',
      'Bosnia and Herzegovina',
      'Botswana',
      'Brazil',
      'Brunei',
      'Bulgaria',
      'Burkina Faso',
      'Burundi',
      'Cabo Verde',
      'Cambodia',
      'Cameroon',
      'Canada',
      'Central African Republic',
      'Chad',
      'Chile',
      'China',
      'Colombia',
      'Comoros',
      'Congo',
      'Costa Rica',
      'Ivory Coast',
      'Croatia',
      'Cuba',
      'Cyprus',
      'Czechia',
      'Denmark',
      'Djibouti',
      'Dominica',
      'Dominican Republic',
      'Ecuador',
      'El Salvador',
      'Equatorial Guinea',
      'Eritrea',
      'Estonia',
      'Eswatini',
      'Ethiopia',
      'Fiji',
      'Finland',
      'France',
      'Gabon',
      'Gambia',
      'Georgia',
      'Germany',
      'Ghana',
      'Greece',
      'Grenada',
      'Guatemala',
      'Guinea',
      'Guinea-Bissau',
      'Guyana',
      'Haiti',
      'Honduras',
      'Hungary',
      'Iceland',
      'India',
      'Indonesia',
      'Iran',
      'Iraq',
      'Ireland',
      'Italy',
      'Jamaica',
      'Japan',
      'Jordan',
      'Kazakhstan',
      'Kenya',
      'Kiribati',
      'Korea, North',
      'Korea, South',
      'Kuwait',
      'Kyrgyzstan',
      'Laos',
      'Latvia',
      'Lebanon',
      'Lesotho',
      'Liberia',
      'Libya',
      'Liechtenstein',
      'Lithuania',
      'Luxembourg',
      'Madagascar',
      'Malawi',
      'Malaysia',
      'Maldives',
      'Mali',
      'Malta',
      'Marshall Islands',
      'Mauritania',
      'Mauritius',
      'Mexico',
      'Micronesia',
      'Moldova',
      'Monaco',
      'Mongolia',
      'Montenegro',
      'Morocco',
      'Mozambique',
      'Myanmar - Burma',
      'Namibia',
      'Nauru',
      'Nepal',
      'Netherlands',
      'New Zealand',
      'Nicaragua',
      'Niger',
      'Nigeria',
      'North Macedonia',
      'Norway',
      'Oman',
      'Pakistan',
      'Palau',
      'Palestine',
      'Panama',
      'Papua New Guinea',
      'Paraguay',
      'Peru',
      'Philippines',
      'Poland',
      'Portugal',
      'Qatar',
      'Romania',
      'Russia',
      'Rwanda',
      'Saint Kitts and Nevis',
      'Saint Lucia',
      'Saint Vincent and the Grenadines',
      'Samoa',
      'San Marino',
      'Sao Tome and Principe',
      'Saudi Arabia',
      'Senegal',
      'Serbia',
      'Seychelles',
      'Sierra Leone',
      'Singapore',
      'Slovakia',
      'Slovenia',
      'Solomon Islands',
      'Somalia',
      'South Africa',
      'South Sudan',
      'Spain',
      'Sri Lanka',
      'Sudan',
      'Suriname',
      'Sweden',
      'Switzerland',
      'Syria',
      'Taiwan',
      'Tajikistan',
      'Tanzania',
      'Thailand',
      'Timor-Leste',
      'Togo',
      'Tonga',
      'Trinidad and Tobago',
      'Tunisia',
      'Turkey ',
      'Turkmenistan',
      'Tuvalu',
      'Uganda',
      'Ukraine',
      'United Arab Emirates',
      'United Kingdom',
      'United States',
      'Uruguay',
      'Uzbekistan',
      'Vanuatu',
      'Venezuela',
      'Vietnam',
      'Yemen',
      'Zambia',
      'Zimbabwe',
    ];
  }
}
