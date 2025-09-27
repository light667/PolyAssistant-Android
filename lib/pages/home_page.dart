import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:polyassistant/pages/chat_page.dart';
import 'package:polyassistant/pages/resources_page.dart';
import 'package:polyassistant/pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _pseudo = 'Utilisateur';
  String _filiere = 'LF Génie Mécanique';
  String _semestre = 'Semestre 1';

  final List<Widget> _pages = const <Widget>[
    HomeContent(),
    ChatPage(title: 'Chat'),
    ResourcesPage(title: 'Ressources'),
    SettingsPage(title: 'Paramètres'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pseudo = prefs.getString('pseudo');
      final filiere = prefs.getString('filiere');
      final semestre = prefs.getString('semestre');

      debugPrint(
        'SharedPreferences - pseudo: $pseudo, filiere: $filiere, semestre: $semestre',
      );

      if (mounted) {
        setState(() {
          _pseudo = pseudo ?? 'Utilisateur';
          _filiere = filiere ?? 'LF Génie Mécanique';
          _semestre = semestre ?? 'Semestre 1';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du chargement des données utilisateur : $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Erreur dans _loadUserData: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PolyAssistant',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF121212), const Color(0xFF1E3A8A)]
                : [const Color(0xFFF3F4F6), const Color(0xFFBBDEFB)],
          ),
        ),
        child: _pages[_selectedIndex].animate().fadeIn(duration: 400.ms),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Accueil',
            tooltip: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.message),
            label: 'Chat',
            tooltip: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.book),
            label: 'Ressources',
            tooltip: 'Ressources',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: 'Paramètres',
            tooltip: 'Paramètres',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: Theme.of(
          context,
        ).bottomNavigationBarTheme.backgroundColor,
        elevation: 8,
        onTap: _onItemTapped,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/profile');
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        tooltip: 'Voir le profil',
        child: const FaIcon(FontAwesomeIcons.user, color: Colors.black),
      ).animate().scale(delay: 1000.ms, duration: 300.ms),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomePageState>();
    final pseudo = state?._pseudo ?? 'Utilisateur';
    final filiere = state?._filiere ?? 'LF Génie Mécanique';
    final semestre = state?._semestre ?? 'Semestre 1';

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bienvenue, $pseudo !',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ).animate().fadeIn(duration: 600.ms).slideY(),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      pseudo[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ).animate().scale(duration: 800.ms, delay: 200.ms),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$filiere - $semestre',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(),
              const SizedBox(height: 16),
              Text(
                'Votre assistant pour réussir vos études à l\'Ecole Polytechnique de Lomé',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 1000.ms).slideY(),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ressources suggérées',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().fadeIn(duration: 1200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Découvrez des cours adaptés à votre $filiere, $semestre.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 1400.ms),
                      const SizedBox(height: 16),
                      Animate(
                        effects: [
                          FadeEffect(duration: 1600.ms),
                          ScaleEffect(),
                        ],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickActionButton(
                              context,
                              icon: FontAwesomeIcons.book,
                              label: 'Cours',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/resources'),
                            ),
                            _buildQuickActionButton(
                              context,
                              icon: FontAwesomeIcons.message,
                              label: 'Chat',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/chat'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Développez vos compétences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ).animate().fadeIn(duration: 1800.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Explorez des opportunités pour améliorer vos compétences académiques et professionnelles.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ).animate().fadeIn(duration: 2000.ms),
                      const SizedBox(height: 16),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.language,
                        title: 'Test d\'anglais',
                        description:
                            'Passez un test EF SET et obtenez un certificat reconnu internationalement.',
                        url: 'https://www.efset.org/english-certificate/',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.brain,
                        title: 'Test de QI',
                        description:
                            'Évaluez votre intelligence avec le test BMI Certified IQ.',
                        url: 'https://www.test-iq.org/take-the-iq-test-now/',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.mobileScreenButton,
                        title: 'Apprendre le développement mobile',
                        description:
                            'Suivez une formation complète sur Flutter pour créer des apps Android/iOS.',
                        url:
                            'https://www.youtube.com/playlist?list=PLhi8DXg8yPWbQHwZ9WZtBJ3FGiB72qFkE',
                      ),
                      const SizedBox(height: 12),
                      _buildSkillCard(
                        context,
                        icon: FontAwesomeIcons.userGraduate,
                        title: 'Trouver un mentor',
                        description:
                            'Connectez-vous avec un mentor en développement mobile via MentorCruise.',
                        url: 'https://wa.link/5shcdl',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 2200.ms).slideY(),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Explorez et réussissez avec PolyAssistant !',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(duration: 2400.ms).slideY(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.2),
      highlightColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 300.ms, curve: Curves.easeInOut);
  }

  Widget _buildSkillCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () async {
        try {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ouverture de : $title'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Impossible d\'ouvrir le lien : $url'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de l\'ouverture du lien : $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.2),
      highlightColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            FaIcon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Theme.of(context).colorScheme.secondary,
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(curve: Curves.easeInOut);
  }
}
