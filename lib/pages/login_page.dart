import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:polyassistant/services/firebase/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _forLogin = true;
  String _selectedFiliere = 'LF_Génie_Mécanique';
  String _selectedSemester = 'Semestre 1';

  final List<String> _filieres = [
    'LF_Génie_Mécanique',
    'LF_Génie_Civil',
    'LF_Génie_Électrique',
    'LF_IA&BigData',
    'LF_Informatique&Système',
    'LF_Logistique&Transport',
  ];

  final List<String> _semesters = [
    'Semestre_1',
    'Semestre_2',
    'Semestre_3',
    'Semestre_4',
    'Semestre_5',
    'Semestre_6',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() {
      _forLogin = args?['forLogin'] ?? true;
    });
  }

  void _toggleFormMode() {
    setState(() {
      _forLogin = !_forLogin;
      _emailController.clear();
      _passwordController.clear();
      _passwordConfirmationController.clear();
      _usernameController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pseudo', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('filiere', _selectedFiliere);
    await prefs.setString('semestre', _selectedSemester);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(_forLogin ? 'Connexion' : 'Inscription'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _forLogin ? 'Bienvenue !' : 'Créez votre compte',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (!_forLogin)
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: 'Pseudo',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le pseudo est requis';
                        } else if (value.length < 3) {
                          return 'Le pseudo doit faire au moins 3 caractères';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 800.ms).slideX(),
                  if (!_forLogin) const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'email est requis';
                      } else if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 1000.ms).slideX(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Mot de passe',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe est requis';
                      } else if (value.length < 6) {
                        return 'Le mot de passe doit faire au moins 6 caractères';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 1200.ms).slideX(),
                  const SizedBox(height: 16),
                  if (!_forLogin)
                    TextFormField(
                      controller: _passwordConfirmationController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Confirmation du mot de passe',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La confirmation est requise';
                        } else if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 1400.ms).slideX(),
                  const SizedBox(height: 16),
                  if (!_forLogin)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedFiliere,
                      decoration: InputDecoration(
                        labelText: 'Filière',
                        prefixIcon: const FaIcon(
                          FontAwesomeIcons.graduationCap,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _filieres.map<DropdownMenuItem<String>>((filiere) {
                        return DropdownMenuItem<String>(
                          value: filiere,
                          child: Text(filiere),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFiliere = value!;
                        });
                      },
                    ).animate().fadeIn(duration: 1600.ms).slideX(),
                  const SizedBox(height: 16),
                  if (!_forLogin)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSemester,
                      decoration: InputDecoration(
                        labelText: 'Semestre',
                        prefixIcon: const FaIcon(FontAwesomeIcons.calendar),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _semesters.map<DropdownMenuItem<String>>((
                        semester,
                      ) {
                        return DropdownMenuItem<String>(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
                        });
                      },
                    ).animate().fadeIn(duration: 1800.ms).slideX(),
                  const SizedBox(height: 24),
                  if (_forLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showPasswordResetDialog,
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
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
                                  if (mounted && context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/redirection',
                                    );
                                  }
                                } else {
                                  await Auth().createUserWithEmailAndPassword(
                                    _emailController.text,
                                    _passwordController.text,
                                    _usernameController.text,
                                  );
                                  await _saveUserData();
                                  if (mounted && context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/redirection',
                                    );
                                  }
                                }
                              } on FirebaseAuthException catch (e) {
                                if (mounted && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.message ??
                                            'Erreur d\'authentification',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.black,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(_forLogin ? 'Se connecter' : 'S\'inscrire'),
                  ).animate().fadeIn(duration: 2000.ms).slideY(),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _toggleFormMode,
                    child: Text(
                      _forLogin
                          ? 'Pas de compte ? S\'inscrire'
                          : 'Déjà un compte ? Se connecter',
                    ),
                  ).animate().fadeIn(duration: 2200.ms),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    icon: const FaIcon(FontAwesomeIcons.github),
                    label: const Text('Se connecter avec GitHub'),
                    onPressed: () async {
                      try {
                        final userCredential = await Auth().signInWithGitHub();
                        if (userCredential != null &&
                            mounted &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connecté avec GitHub ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            '/redirection',
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur GitHub : ${e.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ).animate().fadeIn(duration: 2400.ms).slideY(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/google.png',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text('Se connecter avec Google'),
                    onPressed: () async {
                      try {
                        final userCredential = await Auth().signInWithGoogle();
                        if (userCredential != null &&
                            mounted &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Connecté avec Google ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            '/redirection',
                          );
                        }
                      } catch (e) {
                        if (mounted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur Google : $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ).animate().fadeIn(duration: 2600.ms).slideY(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordResetDialog() {
    final resetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Réinitialiser le mot de passe'),
        content: TextField(
          controller: resetController,
          decoration: const InputDecoration(
            labelText: 'Entrez votre email',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await Auth().sendPasswordResetEmail(resetController.text);
                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email de réinitialisation envoyé ✅'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur : $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
