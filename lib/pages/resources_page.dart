import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:convert';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key, required this.title});
  final String title;

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<dynamic> _filieres = [];
  String _selectedFiliere = '';
  String _selectedSemester = '';
  bool _isLoading = true;

  final Color _primaryColor = const Color(0xFF1E3A8A);
  final Color _secondaryColor = const Color(0xFF3B82F6);
  final Color _accentColor = const Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _loadManifest();
  }

  Future<void> _loadManifest() async {
    try {
      final manifestString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/resources_manifest_online.json');
      final manifestJson = jsonDecode(manifestString);

      if (mounted) {
        setState(() {
          _filieres = manifestJson['filieres'] ?? [];
          if (_filieres.isNotEmpty) {
            _selectedFiliere = _filieres[0]['name'];
            final semesters = _getSemestersForFiliere(_selectedFiliere);
            if (semesters.isNotEmpty) {
              _selectedSemester = semesters[0];
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du manifeste : $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des ressources : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDisplayName(String name) {
    if (name.isEmpty) return name;

    String formatted = name.replaceAll('_', ' ');
    formatted = formatted
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    formatted = formatted
        .replaceAll('Lf', 'LF')
        .replaceAll('Ia', 'IA')
        .replaceAll('Bigdata', 'Big Data')
        .replaceAll('Genie', 'Génie')
        .replaceAll('Mecanique', 'Mécanique')
        .replaceAll('Electrique', 'Électrique')
        .replaceAll('Informatique', 'Informatique')
        .replaceAll('Civil', 'Civil')
        .replaceAll('Logistique', 'Logistique')
        .replaceAll('Transport', 'Transport')
        .replaceAll('Logistiquetransport', 'Logistique et Transport');

    return formatted;
  }

  List<String> _getSemestersForFiliere(String filiereName) {
    try {
      final filiere = _filieres.firstWhere(
        (f) => f['name'] == filiereName,
        orElse: () => {'semestres': []},
      );
      return (filiere['semestres'] as List)
          .map((s) => s['name'] as String)
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des semestres: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _getMatieresForFiliereAndSemester(
    String filiereName,
    String semesterName,
  ) {
    try {
      final filiere = _filieres.firstWhere(
        (f) => f['name'] == filiereName,
        orElse: () => {'semestres': []},
      );

      final semester = (filiere['semestres'] as List).firstWhere(
        (s) => s['name'] == semesterName,
        orElse: () => {'matieres': []},
      );

      final matieres = (semester['matieres'] as List)
          .cast<Map<String, dynamic>>();

      return matieres;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des matières: $e');
      return [];
    }
  }

  Widget _buildFiliereCard(String filiereName, bool isSelected) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedFiliere = filiereName;
              final semesters = _getSemestersForFiliere(filiereName);
              if (semesters.isNotEmpty) {
                _selectedSemester = semesters[0];
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.graduationCap,
                    color: isSelected ? _primaryColor : Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDisplayName(filiereName),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getSemestersForFiliere(filiereName).length} semestres',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterChip(String semesterName, bool isSelected) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          _formatDisplayName(semesterName),
          style: TextStyle(
            color: isSelected ? Colors.white : _primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedSemester = semesterName);
          }
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: _primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildMatiereCardHorizontal(Map<String, dynamic> matiere, int index) {
    final pdfCount = matiere['pdfs']?.length ?? 0;

    return AnimatedContainer(
      duration: 300.ms,
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UniteDetailPage(
                  filiere: _selectedFiliere,
                  semestre: _selectedSemester,
                  matiere: matiere['name'],
                  pdfs: matiere['pdfs'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.book,
                        color: _primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDisplayName(matiere['name']),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.picture_as_pdf, color: _accentColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$pdfCount PDF${pdfCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode améliorée pour gérer les PDFs depuis GitHub
  Future<void> _handlePdfAction(
    BuildContext context,
    Map<String, dynamic> pdfData,
    bool isDownload,
  ) async {
    try {
      final pdfName = pdfData['name'];
      final pdfUrl = pdfData['url'] ?? '';

      if (pdfUrl.isEmpty) {
        throw Exception('URL GitHub non disponible pour ce fichier');
      }

      // Vérifier si l'URL contient le bon chemin
      if (!pdfUrl.contains('/assets/')) {
        debugPrint('⚠️ URL suspecte - peut-être manque assets/: $pdfUrl');
      }

      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blue[700]!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDownload
                        ? 'Préparation du téléchargement...'
                        : 'Ouverture...',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connexion à GitHub...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pdfName,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // SOLUTION POUR LE WEB : ouvrir directement l'URL GitHub
      if (isDownload) {
        // Téléchargement : forcer le téléchargement
        final anchor = html.AnchorElement(href: pdfUrl)
          ..setAttribute('download', pdfName)
          ..click();
      } else {
        // Visualisation : ouvrir dans un nouvel onglet
        html.window.open(pdfUrl, pdfName);
      }

      // Fermer le dialogue après un court délai
      await Future.delayed(const Duration(milliseconds: 1000));
      if (context.mounted) {
        Navigator.of(context).pop();

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDownload
                      ? '📥 Téléchargement lancé'
                      : '📖 Ouverture du PDF',
                ),
                const SizedBox(height: 4),
                Text(
                  pdfName,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('❌ Erreur: ${e.toString()}'),
                const SizedBox(height: 4),
                Text('Fichier: ${pdfData['name']}'),
                const SizedBox(height: 4),
                Text(
                  'Vérifiez que le fichier existe sur GitHub',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'URL: ${pdfData['url']}',
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semesters = _getSemestersForFiliere(_selectedFiliere);
    final matieres = _getMatieresForFiliereAndSemester(
      _selectedFiliere,
      _selectedSemester,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Ressources Pédagogiques",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _filieres.isEmpty
          ? _buildEmptyState()
          : _buildContent(semesters, matieres),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(_primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement des ressources...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Aucune ressource disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Les ressources pédagogiques seront bientôt disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    List<String> semesters,
    List<Map<String, dynamic>> matieres,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bannière GitHub
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.blue.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📡 Ressources en ligne',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tous les PDFs sont chargés depuis GitHub',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section des filières
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school_rounded, color: _primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Choisissez votre filière',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sélectionnez votre domaine d\'étude pour accéder aux ressources correspondantes',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Liste horizontale des filières
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _filieres.length,
              itemBuilder: (context, index) {
                final filiere = _filieres[index]['name'];
                return _buildFiliereCard(
                  filiere,
                  filiere == _selectedFiliere,
                ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.3);
              },
            ),
          ),

          // Section des semestres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Semestre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Chips des semestres
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: semesters.length,
              itemBuilder: (context, index) {
                final semester = semesters[index];
                return _buildSemesterChip(
                  semester,
                  semester == _selectedSemester,
                ).animate(delay: (index * 80).ms).fadeIn().scale();
              },
            ),
          ),

          // Section des matières
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: _primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unités d\'enseignement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${matieres.length} matière(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sélectionnez une matière pour accéder aux ressources',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Liste horizontale des matières
          matieres.isEmpty
              ? _buildNoMatieresState()
              : SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: matieres.length,
                    itemBuilder: (context, index) {
                      return _buildMatiereCardHorizontal(matieres[index], index)
                          .animate(delay: (index * 100).ms)
                          .fadeIn()
                          .slideX(begin: 0.2);
                    },
                  ),
                ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoMatieresState() {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucune matière disponible',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Aucun contenu pour cette sélection',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class UniteDetailPage extends StatelessWidget {
  final String filiere;
  final String semestre;
  final String matiere;
  final List<dynamic> pdfs;

  const UniteDetailPage({
    super.key,
    required this.filiere,
    required this.semestre,
    required this.matiere,
    required this.pdfs,
  });

  String _formatDisplayName(String name) {
    if (name.isEmpty) return name;

    String formatted = name.replaceAll('_', ' ');
    formatted = formatted
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');

    formatted = formatted
        .replaceAll('Lf', 'LF')
        .replaceAll('Ia', 'IA')
        .replaceAll('Bigdata', 'Big Data')
        .replaceAll('Genie', 'Génie')
        .replaceAll('Mecanique', 'Mécanique')
        .replaceAll('Logistiquetransport', 'Logistique et Transport')
        .replaceAll('Electrique', 'Électrique');

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF1E3A8A);
    final accentColor = const Color(0xFFF59E0B);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatDisplayName(matiere),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // En-tête informatif
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.05),
                  primaryColor.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.school, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDisplayName(filiere),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Semestre: ${_formatDisplayName(semestre)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'GitHub',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pdfs.length} PDF(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Liste des PDFs
          Expanded(
            child: pdfs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun PDF disponible',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pdfs.length,
                    itemBuilder: (context, index) {
                      final pdfData = pdfs[index];
                      final pdfName = pdfData['name'];
                      final pdfUrl = pdfData['url'] ?? '';

                      return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.filePdf,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                _formatDisplayName(
                                  pdfName.replaceAll('.pdf', ''),
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cloud,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Source GitHub',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Cliquez pour ouvrir ou télécharger',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () => _handlePdfAction(
                                      context,
                                      pdfData,
                                      false,
                                    ),
                                    tooltip: 'Voir le PDF',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.download,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    onPressed: () => _handlePdfAction(
                                      context,
                                      pdfData,
                                      true,
                                    ),
                                    tooltip: 'Télécharger',
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(delay: (index * 100).ms)
                          .fadeIn()
                          .slideX(begin: 0.2);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handlePdfAction(
    BuildContext context,
    Map<String, dynamic> pdfData,
    bool isDownload,
  ) {
    final _ResourcesPageState? parentState = context
        .findAncestorStateOfType<_ResourcesPageState>();
    if (parentState != null) {
      parentState._handlePdfAction(context, pdfData, isDownload);
    }
  }
}
