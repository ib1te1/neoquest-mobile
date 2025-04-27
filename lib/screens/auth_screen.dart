
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  // === Настраиваемые константы ===
  static const double TAB_TOP_MARGIN = 90.0;
  static const double TAB_WIDTH_FACTOR = 0.6;
  static const double SPACING_TAB_FIELDS = 75.0;
  static const double SPACING_FIELDS_BUTTON = 70.0;
  static const double SPACING_BUTTON_FIRST_LINK = 16.0;
  static const double SPACING_FIRST_SECOND_LINK = 40.0;
  static const double TAB_BORDER_RADIUS = 15.0;
  static const double TAB_HEIGHT = 50.0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoginMode = true;
  String? _localError;

  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.dark,
        title: Text('Успешная регистрация', style: AppTextStyles.subtitle),
        content: Text(
          'Регистрация прошла успешно. Пожалуйста, войдите в систему.',
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Ок', style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: AppColors.dark,
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: TAB_TOP_MARGIN),
                    _buildGradientTab(screenWidth),
                    const SizedBox(height: SPACING_TAB_FIELDS),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTextField(_emailController, 'Email'),
                              if (!_isLoginMode) const SizedBox(height: 16),
                              if (!_isLoginMode)
                                _buildTextField(_nameController, 'Имя'),
                              const SizedBox(height: 16),
                              _buildTextField(
                                _passwordController,
                                'Пароль',
                                obscure: true,
                              ),
                              if (!_isLoginMode) const SizedBox(height: 16),
                              if (!_isLoginMode)
                                _buildTextField(
                                  _confirmPasswordController,
                                  'Повторите пароль',
                                  obscure: true,
                                ),
                              if (!_isLoginMode) const SizedBox(height: 16),
                              if (!_isLoginMode)
                                _buildTextField(
                                  _ageController,
                                  'Возраст',
                                  isNumber: true,
                                ),
                              const SizedBox(height: SPACING_FIELDS_BUTTON),
                              _buildGradientButton(
                                text: _isLoginMode ? 'Войти' : 'Зарегистрироваться',
                                onPressed: _submit,
                              ),
                              const SizedBox(height: SPACING_BUTTON_FIRST_LINK),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoginMode = !_isLoginMode;
                                    _localError = null;
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _confirmPasswordController.clear();
                                    _nameController.clear();
                                    _ageController.clear();
                                  });
                                },
                                child: Text(
                                  _isLoginMode
                                      ? 'Нет аккаунта? Зарегистрируйтесь'
                                      : 'Уже есть аккаунт? Войдите',
                                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                                ),
                              ),
                              const SizedBox(height: SPACING_FIRST_SECOND_LINK),
                              if (_localError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _localError!,
                                    style: const TextStyle(color: Colors.redAccent),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (authProvider.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Image.asset(
                          'assets/logo2_zero_background.png',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientTab(double screenWidth) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: screenWidth * TAB_WIDTH_FACTOR,
          height: TAB_HEIGHT,
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(TAB_BORDER_RADIUS),
              bottomRight: Radius.circular(TAB_BORDER_RADIUS),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            _isLoginMode ? 'ВХОД' : 'РЕГИСТРАЦИЯ',
            style: AppTextStyles.headline.copyWith(color: Colors.white),
          ),
        ),
        Positioned(
          left: screenWidth * TAB_WIDTH_FACTOR - 20,
          top: -((TAB_HEIGHT + 30) / 2) - 10,
          child: Image.asset(
            'assets/logo2_zero_background.png',
            width: 100,
            height: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(TAB_BORDER_RADIUS),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TAB_BORDER_RADIUS),
            ),
          ),
          onPressed: onPressed,
          child: Text(text,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
        ),
      );

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        bool isNumber = false,
      }) =>
      Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          borderRadius: BorderRadius.circular(TAB_BORDER_RADIUS),
        ),
        padding: const EdgeInsets.all(1),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(TAB_BORDER_RADIUS),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TAB_BORDER_RADIUS),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Заполните поле "$label"';
              if (label == 'Email' && !value.contains('@'))
                return 'Введите корректный email';
              if (label == 'Пароль' && value.length < 6)
                return 'Минимум 6 символов';
              if (label == 'Повторите пароль' &&
                  value != _passwordController.text)
                return 'Пароли не совпадают';
              if (label == 'Возраст') {
                final age = int.tryParse(value);
                if (age == null || age < 10 || age > 100)
                  return 'Возраст от 10 до 100';
              }
              return null;
            },
          ),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _localError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    bool success;
    if (_isLoginMode) {
      success = await authProvider.login(email, password);
    } else {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      success = await authProvider.register(email, password, name, age);
    }

    if (success) {
      if (_isLoginMode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        setState(() {
          _isLoginMode = true;
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _nameController.clear();
          _ageController.clear();
        });
        _showRegistrationSuccessDialog();
      }
    } else {
      final raw = authProvider.errorMessage?.toLowerCase() ?? '';
      if (raw.contains('wrong-password') ||
          raw.contains('user-not-found') ||
          raw.contains('incorrect')) {
        setState(() => _localError = 'Неверный email или пароль');
      } else {
        setState(() => _localError = authProvider.errorMessage);
      }
    }
  }
}
