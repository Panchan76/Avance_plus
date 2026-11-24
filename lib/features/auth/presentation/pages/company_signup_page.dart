import '../../data/auth_service.dart';
import 'auth_gate.dart';
import 'package:flutter/material.dart';


class CompanySignupPage extends StatefulWidget {
  const CompanySignupPage({super.key});

  @override
  State<CompanySignupPage> createState() =>
      _CompanySignupPageState();
}

class _CompanySignupPageState
    extends State<CompanySignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _busy = false;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _createCompanyAccount() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.register(email: _emailController.text,
        password: _passwordController.text, name: _companyNameController.text,
        role: 'company', cnpj: _cnpjController.text);
      if (mounted) openAuthenticatedRoot(context);
    } catch (error) {
      if (!mounted) return;
      final partial = AuthService.instance.auth.currentUser != null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        partial ? 'Sua conta foi criada. Conclua o perfil para continuar. ${authErrorMessage(error)}'
          : authErrorMessage(error))));
      if (partial) openAuthenticatedRoot(context);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o e-mail da empresa.';
    }

    if (!value.contains('@') || !value.contains('.')) {
      return 'Digite um e-mail válido.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de empresa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Icon(
                      Icons.business_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Cadastre sua empresa',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Crie uma conta para publicar oportunidades e encontrar candidatos.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),

                    const SizedBox(height: 32),

                    TextFormField(
                      enabled: !_busy,
                      controller: _companyNameController,
                      maxLength: 120,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nome da empresa',
                        prefixIcon: Icon(
                          Icons.business_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().length < 2) {
                          return 'Informe o nome da empresa.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      enabled: !_busy,
                      controller: _cnpjController,
                      maxLength: 32,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'CNPJ',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Informe o CNPJ.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      enabled: !_busy,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail da empresa',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      enabled: !_busy,
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _hidePassword
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    TextFormField(
                      enabled: !_busy,
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _hideConfirmPassword
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword =
                                  !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'As senhas não são iguais.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _createCompanyAccount,
                        icon: const Icon(
                          Icons.business,
                        ),
                        label: Text(_busy ? 'Criando conta...' : 'Cadastrar empresa'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}
