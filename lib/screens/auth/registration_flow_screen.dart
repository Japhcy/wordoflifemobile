import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wordoflifemobile/services/auth_service.dart';
import 'package:wordoflifemobile/core/theme/app_colors.dart';
import 'package:wordoflifemobile/screens/pastor/pastor_no_church/pastor_dashboard_screen.dart';
import 'package:wordoflifemobile/screens/pastor/pastor_with_church/pastor_church_dashboard_screen.dart';
import 'package:wordoflifemobile/screens/user/home_screen.dart';

class RegistrationFlowScreen extends StatefulWidget {
  const RegistrationFlowScreen({super.key});

  @override
  State<RegistrationFlowScreen> createState() => _RegistrationFlowScreenState();
}

class _RegistrationFlowScreenState extends State<RegistrationFlowScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int currentPage = 0;
  String? _userType;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;
  final _supabase = Supabase.instance.client;


  // REGISTRATION CONTROLLERS

  // Common fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  DateTime? _selectedBirthdate;
  String? _selectedGender;

  // Pastor-only fields
  final _licenseNumberController = TextEditingController();
  DateTime? _selectedLicenseExpiry;

  // Church fields (for pastor with church)
  bool _registerChurch = false;
  final _churchNameController = TextEditingController();
  final _churchDoctrineController = TextEditingController();
  final _churchEmailController = TextEditingController();
  final _churchPhoneController = TextEditingController();
  final _memberCountController = TextEditingController();
  DateTime? _selectedDateBuilt;

  // INVITATION CODE FIELDS (for normal users)
  final _invitationCodeController = TextEditingController();
  bool _showInvitationCodeField = false;

  // POST-REGISTRATION (for pastor with church)
  String? _generatedInvitationCode;
  bool _showInvitationCodeSuccess = false;

  final AuthService _authService = AuthService();

  // SPACING TOKENS
  static const double _radius = 18;
  static const double _fieldRadius = 14;

  @override
  Widget build(BuildContext context) {
    // Show invitation code success screen if pastor registered with church
    if (_showInvitationCodeSuccess && _generatedInvitationCode != null) {
      return _buildInvitationCodeSuccessScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => currentPage = index);
                },
                children: [_buildStep1(), _buildStep2()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INVITATION CODE SUCCESS SCREEN
  Widget _buildInvitationCodeSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Registration Successful!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Your church has been created. Share this invitation code with your members so they can join:',
                style: TextStyle(fontSize: 16, color: AppColors.neutral600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Invitation Code Card
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.navy200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy200.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.navy200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _generatedInvitationCode!,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: AppColors.navy800,
                            ),
                          ),
                          const SizedBox(width: 18),
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _generatedInvitationCode!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invitation code copied!'),
                                  backgroundColor: AppColors.success,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: AppColors.navy600,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Code Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                          icon: Icons.people_rounded,
                          label: 'Single-use code',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: 'No expiration',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoChip(
                          icon: Icons.check_circle_rounded,
                          label: 'Active',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Copy and navigate to dashboard
                        Clipboard.setData(
                          ClipboardData(text: _generatedInvitationCode!),
                        );
                        _navigateToDashboard('pastor_church_dashboard');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Copy & Continue'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToDashboard('pastor_church_dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Go to Dashboard'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Note
              Text(
                'You can generate more invitation codes from your church dashboard.',
                style: TextStyle(fontSize: 13, color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.neutral500),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color ?? AppColors.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  // PROGRESS HEADER
  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (currentPage + 1) / 2,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                color: AppColors.navy600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Step ${currentPage + 1} of 2',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  // STEP 1: Are you a Pastor?
  Widget _buildStep1() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.pastelBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.church_rounded,
                size: 32,
                color: AppColors.navy600,
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              "Are you a pastor?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.navy800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This determines your dashboard and the\nfeatures available to your account.",
              style: TextStyle(
                fontSize: 15,
                color: AppColors.neutral500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            _buildRoleOption(
              label: "Yes, I'm a pastor",
              description: "Manage a congregation and messages",
              icon: PhosphorIconsBold.church,
              selected: _userType == 'pastor',
              onTap: () => _selectRoleAndAdvance('pastor'),
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              label: "No, I'm a member",
              description: "Follow along as a community member",
              icon: PhosphorIconsBold.user,
              selected: _userType == 'user',
              onTap: () => _selectRoleAndAdvance('user'),
            ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Back to login",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectRoleAndAdvance(String type) {
    setState(() => _userType = type);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildRoleOption({
    required String label,
    required String description,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? AppColors.pastelBlue : Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(
          color: selected ? AppColors.navy600 : AppColors.neutral200,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.navy600 : AppColors.neutral100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected ? Colors.white : AppColors.navy500,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? AppColors.navy600 : AppColors.neutral300,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STEP 2: Registration Form
  Widget _buildStep2() {
    final isPastor = _userType == 'pastor';

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.navy600,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.neutral200),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isPastor ? 'Pastor registration' : 'Member registration',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ============================================
            // COMMON FIELDS
            // ============================================
            _SectionCard(
              icon: PhosphorIconsBold.user,
              title: 'Personal information',
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Full name',
                  icon: PhosphorIconsBold.user,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email address',
                  icon: PhosphorIconsBold.envelope,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: obscurePassword,
                  icon: PhosphorIconsBold.lock,
                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => obscurePassword = !obscurePassword);
                    },
                    icon: Icon(
                      obscurePassword
                          ? PhosphorIconsBold.eye
                          : PhosphorIconsBold.eyeSlash,
                      color: AppColors.navy400,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  obscureText: obscureConfirmPassword,
                  icon: PhosphorIconsBold.lock,
                  validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword,
                      );
                    },
                    icon: Icon(
                      obscureConfirmPassword
                          ? PhosphorIconsBold.eye
                          : PhosphorIconsBold.eyeSlash,
                      color: AppColors.navy400,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _mobileController,
                  label: 'Mobile number',
                  icon: PhosphorIconsBold.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildDatePicker(
                  label: 'Birthdate',
                  selectedDate: _selectedBirthdate,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedBirthdate = date);
                    }
                  },
                ),
                const SizedBox(height: 14),
                _buildGenderDropdown(),
              ],
            ),

            // Registration for normal users
            if (!isPastor) ...[
              const SizedBox(height: 16),
              _buildInvitationCodeToggle(),
              if (_showInvitationCodeField) ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _invitationCodeController,
                  label: 'Invitation code',
                  icon: PhosphorIconsBold.qrCode,
                  hintText: 'Enter your church invitation code',
                  validator: (v) {
                    if (_showInvitationCodeField && (v == null || v.isEmpty)) {
                      return 'Please enter an invitation code';
                    }
                    return null;
                  },
                ),
              ],
            ],

            // Pastor field
            if (isPastor) ...[
              const SizedBox(height: 16),
              _SectionCard(
                icon: PhosphorIconsBold.identificationCard,
                title: 'Pastor information',
                children: [
                  _buildTextField(
                    controller: _licenseNumberController,
                    label: 'License number',
                    icon: PhosphorIconsBold.identificationCard,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildDatePicker(
                    label: 'License expiry date',
                    selectedDate: _selectedLicenseExpiry,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 365),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 10),
                        ),
                      );
                      if (date != null) {
                        setState(() => _selectedLicenseExpiry = date);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // optional - church toggle
              _buildChurchToggle(),

              if (_registerChurch) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  icon: PhosphorIconsBold.church,
                  title: 'Church information',
                  subtitle: 'Optional',
                  children: [
                    _buildTextField(
                      controller: _churchNameController,
                      label: 'Church name',
                      icon: PhosphorIconsBold.church,
                      validator: (v) =>
                          _registerChurch && v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _churchDoctrineController,
                      label: 'Doctrine / denomination',
                      icon: PhosphorIconsBold.book,
                      maxLines: 2,
                      hintText: 'e.g., Evangelical, Bible-based',
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _churchEmailController,
                      label: 'Church email',
                      icon: PhosphorIconsBold.envelope,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _churchPhoneController,
                      label: 'Church phone',
                      icon: PhosphorIconsBold.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _memberCountController,
                      label: 'Number of members',
                      icon: PhosphorIconsBold.users,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    _buildDatePicker(
                      label: 'Date built / anniversary',
                      selectedDate: _selectedDateBuilt,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 365 * 10),
                          ),
                          firstDate: DateTime(1800),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _selectedDateBuilt = date);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _submitRegistration,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 1.8,
                      )
                    : Text(
                        isPastor
                            ? (_registerChurch
                                  ? 'Register as pastor & church'
                                  : 'Register as pastor')
                            : 'Register',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // INVITATION CODE TOGGLE (for normal users)
  Widget _buildInvitationCodeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => setState(
            () => _showInvitationCodeField = !_showInvitationCodeField,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have an invitation code?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Join a church using an invitation code from your pastor',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _showInvitationCodeField,
                  activeTrackColor: AppColors.navy600,
                  onChanged: (value) =>
                      setState(() => _showInvitationCodeField = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // CHURCH TOGGLE (for pastors)
  Widget _buildChurchToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: () => setState(() => _registerChurch = !_registerChurch),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register a church',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add your church details with this account',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _registerChurch,
                  activeTrackColor: AppColors.navy600,
                  onChanged: (value) => setState(() => _registerChurch = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // BUILD HELPERS
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.neutral50,
        prefixIcon: Icon(icon, color: AppColors.navy400, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppColors.navy500, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_fieldRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.neutral50,
          prefixIcon: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.navy400,
            size: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_fieldRadius),
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'
              : 'Select date',
          style: TextStyle(
            fontSize: 15,
            color: selectedDate != null
                ? AppColors.neutral900
                : AppColors.neutral400,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      style: const TextStyle(fontSize: 15, color: AppColors.neutral900),
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: AppColors.neutral50,
        prefixIcon: const Icon(
          Icons.person_outline_rounded,
          color: AppColors.navy400,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: const BorderSide(color: AppColors.navy500, width: 1.5),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
      validator: (v) => v == null ? 'Please select gender' : null,
    );
  }

  // SUBMIT LOGIC
  Future<void> _submitRegistration() async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _selectedBirthdate == null ||
        _selectedGender == null) {
      _showError('Please fill in all required fields');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // loading
    setState(() {
      isLoading = true;
    });

    try {
      final isPastor = _userType == 'pastor';

      if (isPastor) {
        if (_licenseNumberController.text.isEmpty ||
            _selectedLicenseExpiry == null) {
          _showError('Please fill in all pastor license details');
          setState(() => isLoading = false);
          return;
        }

        if (_registerChurch) {
          if (_churchNameController.text.isEmpty) {
            _showError('Please enter church name');
            setState(() => isLoading = false);
            return;
          }

          // REGISTER PASTOR WITH CHURCH
          await _authService.signUpPastorWithChurch(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            fullName: _fullNameController.text.trim(),
            birthdate: _selectedBirthdate!,
            gender: _selectedGender!,
            mobileNumber: _mobileController.text.trim(),
            licenseNumber: _licenseNumberController.text.trim(),
            licenseExpiryDate: _selectedLicenseExpiry!,
            churchName: _churchNameController.text.trim(),
            doctrine: _churchDoctrineController.text.trim(),
            memberCount: int.tryParse(_memberCountController.text) ?? 0,
            churchEmail: _churchEmailController.text.trim(),
            churchPhone: _churchPhoneController.text.trim(),
            dateBuilt: _selectedDateBuilt,
          );

          final userId = _authService.getUserId();

          if (userId.isNotEmpty) {
            await Future.delayed(Duration(milliseconds: 800));

            final churchData = await _supabase
                .from('churches')
                .select('id')
                .eq('pastor_id', userId)
                .maybeSingle();

            final churchId = churchData?['id'] as String?;

            if (churchId != null && churchId.isNotEmpty) {
              //generate inv code
              final invitationCode = await _authService.generateInvitationCode(
                churchId: churchId,
                maxUses: 1,
              );

              if (!mounted) return;

              // show invitation code success screen
              setState(() {
                _generatedInvitationCode = invitationCode;
                _showInvitationCodeSuccess = true;
                isLoading = false;
              });
              return;
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Church created but could not generate invitation code.',
                  ),
                  backgroundColor: AppColors.warning,
                ),
              );
            }
          }
        } else {
          // REGISTER PASTOR WITHOUT CHURCH
          await _authService.signUpPastor(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            fullName: _fullNameController.text.trim(),
            birthdate: _selectedBirthdate!,
            gender: _selectedGender!,
            mobileNumber: _mobileController.text.trim(),
            licenseNumber: _licenseNumberController.text.trim(),
            licenseExpiryDate: _selectedLicenseExpiry!,
          );
        }
      } else {
        // REGISTER NORMAL USER
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          fullName: _fullNameController.text.trim(),
          birthdate: _selectedBirthdate!,
          gender: _selectedGender!,
          mobileNumber: _mobileController.text.trim(),
        );

        // If invitation is nahatag na, use it
        if (_showInvitationCodeField &&
            _invitationCodeController.text.isNotEmpty) {
          try {
            await _authService.useInvitationCode(
              _invitationCodeController.text.trim().toUpperCase(),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not join church: $e'),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: AppColors.success,
        ),
      );
      _navigateToDashboard(_userType!);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Registration failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToDashboard(String dashboardType) {
    switch (dashboardType) {
      case 'user_dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 'pastor_dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PastorDashboard()),
        );
        break;
      case 'pastor_church_dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PastorChurchDashboard(),
          ),
        );
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
    }
  }

  // DISPOSE
  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _licenseNumberController.dispose();
    _churchNameController.dispose();
    _churchDoctrineController.dispose();
    _churchEmailController.dispose();
    _churchPhoneController.dispose();
    _memberCountController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }
}

// SECTION CARD
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.pastelBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: AppColors.navy600),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
