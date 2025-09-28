import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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
      ).loadString('assets/resources_manifest.json');
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
        .replaceAll('Transport', 'Transport');

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

  // NOUVEAU : Carte de matière pour affichage horizontal
  Widget _buildMatiereCardHorizontal(Map<String, dynamic> matiere, int index) {
    final pdfCount = matiere['pdfs']?.length ?? 0;

    return AnimatedContainer(
      duration: 300.ms,
      width: 160, // Largeur fixe pour l'affichage horizontal
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
                  folder: matiere['folder'],
                  pdfs: List<String>.from(matiere['pdfs'] ?? []),
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
                // Icone et titre
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

                // Nombre de PDFs
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

  // CORRECTION : Widget de contenu avec défilement
  Widget _buildContent(
    List<String> semesters,
    List<Map<String, dynamic>> matieres,
  ) {
    return SingleChildScrollView(
      // ✅ AJOUTÉ : Permet le défilement
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          // NOUVEAU : Section des matières en horizontal
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

          // NOUVEAU : Liste horizontale des matières
          matieres.isEmpty
              ? _buildNoMatieresState()
              : SizedBox(
                  height: 140, // Hauteur fixe pour la liste horizontale
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

          // Espace en bas pour permettre le défilement
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
  final String folder;
  final List<String> pdfs;

  const UniteDetailPage({
    super.key,
    required this.filiere,
    required this.semestre,
    required this.matiere,
    required this.folder,
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
        .replaceAll('Electrique', 'Électrique');

    return formatted;
  }

  // CORRECTION : Méthode simplifiée pour charger les PDFs locaux
  Future<String> _loadPdfToTempFile(
    String assetPath,
    BuildContext context,
  ) async {
    try {
      debugPrint('🔄 Chargement du PDF local: $assetPath');

      // CORRECTION : Utiliser le chemin tel quel depuis le manifeste
      // Le manifeste donne déjà le bon chemin : "assets/resources/lf_genie_civil/..."
      String cleanPath = assetPath;

      debugPrint('🔄 Chemin utilisé: $cleanPath');

      final byteData = await DefaultAssetBundle.of(context).load(cleanPath);

      if (byteData.lengthInBytes == 0) {
        throw Exception('Fichier vide ou introuvable: $cleanPath');
      }

      // Créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      if (!await file.exists()) {
        throw Exception('Échec de la création du fichier temporaire');
      }

      debugPrint('✅ PDF chargé avec succès: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement du PDF: $e');
      rethrow;
    }
  }

  Future<void> _handlePdfAction(
    BuildContext context,
    String pdfPath,
    String pdfName,
    bool isDownload,
  ) async {
    try {
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
                  Text(isDownload ? 'Téléchargement...' : 'Chargement...'),
                  const SizedBox(height: 8),
                  Text(
                    'Depuis les ressources locales',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      if (isDownload) {
        await _downloadPdf(context, pdfPath, pdfName);
      } else {
        await _viewPdf(context, pdfPath, pdfName);
      }

      // Fermer le dialogue de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Erreur: ${e.toString()}'),
                const SizedBox(height: 4),
                Text('Fichier: $pdfName', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text('Chemin: $pdfPath', style: const TextStyle(fontSize: 10)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  Future<void> _viewPdf(
    BuildContext context,
    String pdfPath,
    String pdfName,
  ) async {
    try {
      final tempFilePath = await _loadPdfToTempFile(pdfPath, context);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PDFViewerPage(title: pdfName, filePath: tempFilePath),
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _downloadPdf(
    BuildContext context,
    String pdfPath,
    String pdfName,
  ) async {
    try {
      final tempFilePath = await _loadPdfToTempFile(pdfPath, context);
      final file = File(tempFilePath);

      // Vérifier que le fichier existe
      if (!await file.exists()) {
        throw Exception('Fichier temporaire introuvable');
      }

      // Pour le web, on utilise une approche différente
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', pdfName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Pour mobile/desktop
        final downloadsDir = await getDownloadsDirectory();
        final newFile = File('${downloadsDir?.path}/$pdfName');
        await newFile.writeAsBytes(await file.readAsBytes());
        await OpenFile.open(newFile.path);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF téléchargé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
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
          // En-tête informatif COMPACT
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
                    const SizedBox(width: 8),
                    Icon(Icons.storage, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'Local',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
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
                      final pdfName = pdfs[index];
                      // CORRECTION : Utiliser directement le chemin du manifeste
                      final pdfPath = '$folder/$pdfName';

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
                                  color: Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.filePdf,
                                  color: Colors.red,
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
                                  Text(
                                    'Ressource locale • Cliquez pour ouvrir ou télécharger',
                                    style: TextStyle(
                                      fontSize: 11,
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
                                      pdfPath,
                                      pdfName,
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
                                      pdfPath,
                                      pdfName,
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
}

class PDFViewerPage extends StatelessWidget {
  final String title;
  final String filePath;

  const PDFViewerPage({super.key, required this.title, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.file(
        File(filePath),
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de chargement: ${details.error}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
