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

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.violet,
        title: Text(
          _isLoginMode ? 'Вход' : 'Регистрация',
          style: AppTextStyles.subtitle,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Image.asset('assets/logo.jpg', width: 120, height: 120),
              ),
              const SizedBox(height: 20),
              _buildEmailField(),
              const SizedBox(height: 16),
              if (!_isLoginMode) _buildNameField(),
              if (!_isLoginMode) const SizedBox(height: 16),
              _buildPasswordField(),
              if (!_isLoginMode) const SizedBox(height: 16),
              if (!_isLoginMode) _buildConfirmPasswordField(),
              if (!_isLoginMode) const SizedBox(height: 16),
              if (!_isLoginMode) _buildAgeField(),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.yellow,
                  foregroundColor: AppColors.dark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
                child: Text(
                  _isLoginMode ? 'Войти' : 'Зарегистрироваться',
                  style: AppTextStyles.body,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    // Сброс всех полей при смене режима
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _nameController.clear();
                    _ageController.clear();
                  });
                },
                child: Text(
                  _isLoginMode ? 'Нет аккаунта? Зарегистрируйтесь' : 'Уже есть аккаунт? Войдите',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                },
                child: const Text('Пропустить авторизацию', style: TextStyle(color: Colors.white54)),
              ),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() => TextFormField(
    controller: _emailController,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration('Email'),
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      if (value == null || value.isEmpty) return 'Введите email';
      if (!value.contains('@')) return 'Введите корректный email';
      return null;
    },
  );

  Widget _buildNameField() => TextFormField(
    controller: _nameController,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration('Имя'),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Введите имя';
      return null;
    },
  );

  Widget _buildPasswordField() => TextFormField(
    controller: _passwordController,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration('Пароль'),
    obscureText: true,
    validator: (value) {
      if (value == null || value.isEmpty) return 'Введите пароль';
      if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
      return null;
    },
  );

  Widget _buildConfirmPasswordField() => TextFormField(
    controller: _confirmPasswordController,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration('Повторите пароль'),
    obscureText: true,
    validator: (value) {
      if (value != _passwordController.text) return 'Пароли не совпадают';
      return null;
    },
  );

  Widget _buildAgeField() => TextFormField(
    controller: _ageController,
    style: const TextStyle(color: Colors.white),
    decoration: _inputDecoration('Возраст'),
    keyboardType: TextInputType.number,
    validator: (value) {
      final age = int.tryParse(value ?? '');
      if (age == null || age < 10 || age > 100) return 'Введите возраст от 10 до 100';
      return null;
    },
  );

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white54),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.cyan),
      borderRadius: BorderRadius.circular(12),
    ),
  );

  void _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    }
  }
}
