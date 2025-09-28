import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';

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

  // Couleurs personnalisées pour un design professionnel
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
      final manifestString = await DefaultAssetBundle.of(context)
          .loadString('assets/resources_manifest.json');
      final manifestJson = jsonDecode(manifestString);
      
      if (mounted) {
        setState(() {
          _filieres = manifestJson['filieres'] ?? [];
          if (_filieres.isNotEmpty) {
            _selectedFiliere = _filieres[0]['name'];
            _selectedSemester = _getSemestersForFiliere(_selectedFiliere)[0];
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

  // Fonction pour formater les noms (enlever underscores, mettre en majuscules, etc.)
  String _formatDisplayName(String name) {
    if (name.isEmpty) return name;
    
    // Remplacer les underscores par des espaces
    String formatted = name.replaceAll('_', ' ');
    
    // Capitaliser chaque mot
    formatted = formatted.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
    
    // Corrections spécifiques pour les acronymes
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
      
      return (semester['matieres'] as List).cast<Map<String, dynamic>>();
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
            color: Colors.black.withOpacity(0.1),
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
                          color: isSelected ? Colors.white70 : Colors.grey.shade600,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        pressElevation: 4,
      ),
    );
  }

  Widget _buildMatiereCard(Map<String, dynamic> matiere, int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.book,
              color: _primaryColor,
              size: 20,
            ),
          ),
          title: Text(
            _formatDisplayName(matiere['name']),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${matiere['pdfs']?.length ?? 0} PDF(s) disponible(s)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: _accentColor,
              size: 16,
            ),
          ),
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
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.2);
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
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
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(_primaryColor)),
          const SizedBox(height: 20),
          Text(
            'Chargement des ressources...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
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

  Widget _buildContent(List<String> semesters, List<Map<String, dynamic>> matieres) {
    return Column(
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Liste horizontale des filières
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
                  Icon(Icons.calendar_today_rounded, color: _primaryColor, size: 20),
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
          child: Row(
            children: [
              Icon(Icons.menu_book_rounded, color: _primaryColor, size: 20),
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
              Chip(
                label: Text(
                  '${matieres.length} matière(s)',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: _primaryColor.withOpacity(0.1),
              ),
            ],
          ),
        ),
        
        // Liste des matières
        Expanded(
          child: matieres.isEmpty
              ? _buildNoMatieresState()
              : ListView.builder(
                  itemCount: matieres.length,
                  itemBuilder: (context, index) {
                    return _buildMatiereCard(matieres[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoMatieresState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune matière disponible',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucun contenu n\'est disponible pour cette sélection',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
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

  // Fonction de formatage (identique à celle de la page principale)
  String _formatDisplayName(String name) {
    if (name.isEmpty) return name;
    
    String formatted = name.replaceAll('_', ' ');
    formatted = formatted.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
    
    formatted = formatted
        .replaceAll('Lf', 'LF')
        .replaceAll('Ia', 'IA')
        .replaceAll('Bigdata', 'Big Data')
        .replaceAll('Genie', 'Génie')
        .replaceAll('Mecanique', 'Mécanique')
        .replaceAll('Electrique', 'Électrique');
    
    return formatted;
  }

  Future<String> _copyAssetToTempFile(String assetPath, BuildContext context) async {
    try {
      debugPrint('Chargement du PDF: $assetPath');
      
      final byteData = await DefaultAssetBundle.of(context).load(assetPath);
      
      if (byteData.lengthInBytes == 0) {
        throw Exception('Fichier vide ou introuvable');
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${assetPath.split('/').last}_$timestamp.pdf';
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      
      debugPrint('PDF sauvegardé à: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Erreur lors de la copie du fichier: $e');
      rethrow;
    }
  }

  Future<void> _viewPdf(BuildContext context, String pdfPath, String pdfName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final tempFilePath = await _copyAssetToTempFile(pdfPath, context);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(
              title: pdfName,
              filePath: tempFilePath,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de visualisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, String pdfPath, String pdfName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final byteData = await DefaultAssetBundle.of(context).load(pdfPath);
      final downloadsDir = await getDownloadsDirectory();
      final file = File('${downloadsDir?.path}/$pdfName');

      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      await OpenFile.open(file.path);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF téléchargé avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête informatif
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.1), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDisplayName(filiere),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semestre: ${_formatDisplayName(semestre)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${pdfs.length} PDF(s) disponible(s)',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
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
                        Icon(Icons.picture_as_pdf, size: 60, color: Colors.grey.shade400),
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
                      final pdfPath = '$folder/$pdfName';
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.filePdf,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            _formatDisplayName(pdfName.replaceAll('.pdf', '')),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${(pdfName.length / 1024).toStringAsFixed(1)} KB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye, color: primaryColor),
                                onPressed: () => _viewPdf(context, pdfPath, pdfName),
                                tooltip: 'Voir le PDF',
                              ),
                              IconButton(
                                icon: Icon(Icons.download, color: accentColor),
                                onPressed: () => _downloadPdf(context, pdfPath, pdfName),
                                tooltip: 'Télécharger',
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.2);
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