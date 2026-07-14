import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Signing in with email and password

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Signing up with email and password

  // Sign up (normal user)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required DateTime birthdate,
    required String gender,
    required String mobileNumber,
  }) async {
    try {
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      final res = await _supabase.auth.signUp(email: email, password: password);

      if (res.user != null) {
        await _supabase.rpc(
          'register_user',
          params: {
            'p_email': email,
            'p_full_name': fullName,
            'p_birthdate': birthdate.toIso8601String().split('T').first,
            'p_gender': gender,
            'p_mobile_number': mobileNumber,
          },
        );
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up (Pastor without a church)
  Future<AuthResponse> signUpPastor({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required DateTime birthdate,
    required String gender,
    required String mobileNumber,
    required String licenseNumber,
    required DateTime licenseExpiryDate,
  }) async {
    try {
      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      final res = await _supabase.auth.signUp(email: email, password: password);

      if (res.user != null) {
        await _supabase.rpc(
          'register_pastor_no_church',
          params: {
            'p_email': email,
            'p_full_name': fullName,
            'p_birthdate': birthdate.toIso8601String().split('T').first,
            'p_gender': gender,
            'p_mobile_number': mobileNumber,
            'p_license_number': licenseNumber,
            'p_license_expiry_date': licenseExpiryDate
                .toIso8601String()
                .split('T')
                .first,
          },
        );
      }

      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up (Pastor with Church)
  Future<AuthResponse> signUpPastorWithChurch({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
    required DateTime birthdate,
    required String gender,
    required String mobileNumber,
    required String licenseNumber,
    required DateTime licenseExpiryDate,
    required String churchName,
    required String doctrine,
    required int memberCount,
    required String churchEmail,
    required String churchPhone,
    required DateTime? dateBuilt,
  }) async {
    try {
      if (password != confirmPassword) {
        throw Exception('Password do not match');
      }

      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await _supabase.rpc(
          'register_pastor_with_church',
          params: {
            'p_email': email,
            'p_full_name': fullName,
            'p_birthdate': birthdate.toIso8601String().split('T').first,
            'p_gender': gender,
            'p_mobile_number': mobileNumber,
            'p_license_number': licenseNumber,
            'p_license_expiry_date': licenseExpiryDate
                .toIso8601String()
                .split('T')
                .first,
            'p_church_name': churchName,
            'p_doctrine': doctrine,
            'p_member_count': memberCount,
            'p_church_email': churchEmail,
            'p_church_phone': churchPhone,
            'p_date_built': dateBuilt?.toIso8601String().split('T').first,
          },
        );
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Get user email
  String? getUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Get User ID
  String getUserId() {
    return _supabase.auth.currentUser!.id;
  }

  // Get User Profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('❌ No authenticated user');
        return null;
      }

      debugPrint("🔍 User ID: ${user.id}");
      debugPrint("🔍 User Email: ${user.email}");

      final res = await _supabase
          .from('profiles')
          .select('''
          *,
          church:churches!profiles_church_id_fkey (
            id,
            name,
            doctrine,
            member_count,
            email,
            phone,
            date_built
          )
        ''')
          .eq('id', user.id)
          .maybeSingle();

      if (res == null) {
        debugPrint('❌ No profile found for user: ${user.id}');
        final allProfiles = await _supabase.from('profiles').select('id, email');
        debugPrint('🔍 All profiles in table: $allProfiles');
        return null;
      }

      debugPrint('✅ Profile found: $res');
      debugPrint("✅ User Role: ${res['role']}");
      debugPrint("✅ User Full Name: ${res['full_name']}");

      if (res['church'] != null) {
        debugPrint("✅ Church: ${res['church']['name']}");
      }

      return res;
    } catch (e) {
      debugPrint('❌ Error getting profile: $e');
      debugPrint('❌ Error details: ${e.toString()}');
      return null;
    }
  }

  // Get User Dashboard Type

  Future<String> getUserDashboardType() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'login';

      final response = await _supabase.rpc(
        'get_user_dashboard_type',
        params: {'p_user_id': user.id},
      );

      debugPrint(response.toString());

      return response as String;
    } catch (e) {
      return 'user_dashboard';
    }
  }

  // Get Pastor Church

  Future<List<Map<String, dynamic>>> getPastorChurch() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase.rpc(
        'get_pastor_church',
        params: {'p_user_id': user.id},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Check the licensed validity

  Future<bool> isValidPastor() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase.rpc(
        'is_valid_pastor',
        params: {'p_user_id': user.id},
      );

      return response as bool;
    } catch (e) {
      return false;
    }
  }

  // Sign out

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PROFILE

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _supabase.from('profiles').update(data).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE CHURCH (For Pastors)
  Future<void> updateChurch(Map<String, dynamic> data) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final profile = await getCurrentUserProfile();
      final churchId = profile?['church_id'];

      if (churchId == null) throw Exception('User has no church');

      await _supabase.from('churches').update(data).eq('id', churchId);
    } catch (e) {
      rethrow;
    }
  }

  // generate invitation code
  Future<String> generateInvitationCode({
    required String churchId,
    int maxUses = 1,
    DateTime? expiryDate,
  }) async {
    try {
      final res = await _supabase.rpc(
        'generate_invitation_code',
        params: {
          'p_church_id': churchId,
          'p_max_uses': maxUses,
          'p_expires_at': expiryDate?.toIso8601String().split('T').first,
        },
      );
      return res as String;
    } catch (e) {
      rethrow;
    }
  }

  // use invitation code
  Future<String> useInvitationCode(String code) async {
    try {
      final res = await _supabase.rpc(
        'use_invitation_code',
        params: {'p_code': code},
      );
      return res as String;
    } catch (e) {
      rethrow;
    }
  }

  // get church invitation code
  Future<List<Map<String, dynamic>>> getChurchInvitationCodes({
    required String churchId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_church_invitation_codes',
        params: {'p_church_id': churchId},
      );
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // check if user naay a church
  Future<bool> userHasChurch() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final profile = await _supabase
          .from('profiles')
          .select('church_id')
          .eq('id', user.id)
          .single();

      return profile['church_id'] != null;
    } catch (e) {
      return false;
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  bool get isAuthenticated => _supabase.auth.currentUser != null;
}
