import 'package:flutter/material.dart';
import 'package:polyassistant/services/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _forLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _usernameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      _forLogin = !_forLogin;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _performAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (_forLogin) {
          await Auth().loginWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
          );
        } else {
          await Auth().createUserWithEmailAndPassword(
            _emailController.text,
            _passwordController.text,
            _usernameController.text,
          );
        }
        if (mounted && context.mounted) {
          Navigator.pushReplacementNamed(context, '/redirection');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${e.message}"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted && context.mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withValues(alpha:0.08),
              colorScheme.primary.withValues(alpha:0.02),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header avec animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha:0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _forLogin
                                    ? 'Content de vous revoir !'
                                    : 'Créez votre compte',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _forLogin
                                    ? 'Connectez-vous pour accéder à votre espace'
                                    : 'Rejoignez la communauté PolyAssistant',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha:0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Formulaire avec animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Champ pseudo (seulement pour l'inscription)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                switchInCurve: Curves.easeInOut,
                                switchOutCurve: Curves.easeInOut,
                                child: !_forLogin
                                    ? Column(
                                        key: const ValueKey('signup_fields'),
                                        children: [
                                          TextFormField(
                                            controller: _usernameController,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.person_outline_rounded,
                                                color: colorScheme.primary,
                                              ),
                                              labelText: "Pseudo",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: colorScheme.secondary,
                                                  width: 2,
                                                ),
                                              ),
                                              floatingLabelStyle: TextStyle(
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Le pseudo est requis';
                                              } else if (value.length < 3) {
                                                return 'Le pseudo doit faire au moins 3 caractères';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Champ email
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  labelText: "Adresse email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.secondary,
                                      width: 2,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'L\'email est requis';
                                  } else if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Format d\'email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Champ mot de passe
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  labelText: "Mot de passe",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.secondary,
                                      width: 2,
                                    ),
                                  ),
                                  floatingLabelStyle: TextStyle(
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Le mot de passe est requis';
                                  } else if (value.length < 6) {
                                    return 'Le mot de passe doit faire au moins 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),

                              // Mot de passe oublié
                              if (_forLogin)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _showPasswordResetDialog,
                                    child: Text(
                                      "Mot de passe oublié ?",
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),

                              // Confirmation mot de passe (inscription)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: !_forLogin
                                    ? Column(
                                        key: const ValueKey(
                                          'password_confirmation',
                                        ),
                                        children: [
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller:
                                                _passwordConfirmationController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.lock_reset_rounded,
                                                color: colorScheme.primary,
                                              ),
                                              labelText:
                                                  "Confirmation du mot de passe",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: colorScheme.secondary,
                                                  width: 2,
                                                ),
                                              ),
                                              floatingLabelStyle: TextStyle(
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'La confirmation est requise';
                                              } else if (value !=
                                                  _passwordController.text) {
                                                return 'Les mots de passe ne correspondent pas';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              // Bouton principal
                              Container(
                                margin: const EdgeInsets.only(
                                  top: 24,
                                  bottom: 16,
                                ),
                                width: double.infinity,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                      shadowColor: colorScheme.primary
                                          .withValues(alpha:0.3),
                                    ),
                                    onPressed: _isLoading ? null : _performAuth,
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _forLogin
                                                ? "Se connecter"
                                                : "Créer mon compte",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              // Lien pour basculer entre connexion/inscription
                              TextButton(
                                onPressed: _isLoading ? null : _toggleForm,
                                child: Text(
                                  _forLogin
                                      ? "Pas encore de compte ? S'inscrire"
                                      : "Déjà un compte ? Se connecter",
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Séparateur
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Ou continuer avec",
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons d'authentification sociale
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Bouton GitHub
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[900],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.code_rounded),
                            label: const Text("GitHub"),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    try {
                                      final userCredential = await Auth()
                                          .signInWithGitHub();
                                      if (userCredential != null && mounted && context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/redirection',
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      if (mounted && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Erreur GitHub: ${e.message}",
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted && context.mounted)
                                        setState(() => _isLoading = false);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Bouton Google
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey[800],
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            icon: Image.asset(
                              'assets/images/google.png',
                              height: 20,
                              width: 20,
                            ),
                            label: const Text("Google"),
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() => _isLoading = true);
                                    try {
                                      final userCredential = await Auth()
                                          .signInWithGoogle();
                                      if (userCredential != null && mounted && context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/redirection',
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text("Erreur Google: $e"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted && context.mounted)
                                        setState(() => _isLoading = false);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog() {
    final resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                "Réinitialiser le mot de passe",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Entrez votre email pour recevoir un lien de réinitialisation",
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: resetController,
                decoration: InputDecoration(
                  labelText: "Votre email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await Auth().sendPasswordResetEmail(
                            resetController.text,
                          );
                          if (mounted && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Email envoyé avec succès ✅",
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erreur: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Envoyer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
