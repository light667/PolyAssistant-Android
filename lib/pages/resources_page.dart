import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key, required this.title});
  final String title;

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<dynamic> _filieres = [];
  String _selectedFiliere = 'LF_Génie_Mécanique';
  String _selectedSemester = 'Semestre_1';

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
            _selectedSemester = _getSemestersForFiliere(_selectedFiliere)[0];
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du manifeste : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des ressources : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> _getSemestersForFiliere(String filiereName) {
    final filiere = _filieres.firstWhere(
      (f) => f['name'] == filiereName,
      orElse: () => {'semestres': []},
    );
    return (filiere['semestres'] as List)
        .map((s) => s['name'] as String)
        .toList();
  }

  List<Map<String, dynamic>> _getMatieresForFiliereAndSemester(
    String filiereName,
    String semesterName,
  ) {
    final filiere = _filieres.firstWhere(
      (f) => f['name'] == filiereName,
      orElse: () => {'semestres': []},
    );
    final semester = (filiere['semestres'] as List).firstWhere(
      (s) => s['name'] == semesterName,
      orElse: () => {'matieres': []},
    );
    return (semester['matieres'] as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final semesters = _getSemestersForFiliere(_selectedFiliere);
    final matieres = _getMatieresForFiliereAndSemester(
      _selectedFiliere,
      _selectedSemester,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ressources"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _filieres.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ressources pédagogique',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedFiliere,
                    decoration: InputDecoration(
                      labelText: 'Choisir une filière',
                      prefixIcon: const FaIcon(
                        FontAwesomeIcons.graduationCap,
                        color: Color(0xFF1E3A8A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: _filieres.map<DropdownMenuItem<String>>((filiere) {
                      return DropdownMenuItem<String>(
                        value: filiere['name'],
                        child: Text(filiere['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFiliere = value!;
                        _selectedSemester = _getSemestersForFiliere(
                          _selectedFiliere,
                        )[0];
                      });
                    },
                  ).animate().fadeIn(duration: 800.ms).slideY(),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSemester,
                    decoration: InputDecoration(
                      labelText: 'Choisir un semestre',
                      prefixIcon: const FaIcon(
                        FontAwesomeIcons.calendar,
                        color: Color(0xFF1E3A8A),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: semesters.map<DropdownMenuItem<String>>((semester) {
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
                  ).animate().fadeIn(duration: 1000.ms).slideY(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: matieres.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune matière disponible pour cette sélection.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: matieres.length,
                            itemBuilder: (context, index) {
                              final matiere = matieres[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const FaIcon(
                                    FontAwesomeIcons.book,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                  title: Text(
                                    matiere['name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: const Text(
                                    'Cliquez pour voir les PDFs',
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
                                          pdfs: List<String>.from(
                                            matiere['pdfs'],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ).animate().fadeIn(duration: 1200.ms).slideY();
                            },
                          ),
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

  Future<String> _copyAssetToTempFile(
    String assetPath,
    BuildContext context,
  ) async {
    try {
      debugPrint('Tentative de chargement: $assetPath');

      // Essayer le chemin original
      try {
        final byteData = await DefaultAssetBundle.of(context).load(assetPath);
        return await _writeTempFile(byteData, assetPath);
      } catch (e) {
        debugPrint('Échec avec le chemin original: $e');
      }

      // Essayer avec un chemin nettoyé
      final cleanPath = _cleanAssetPath(assetPath);
      debugPrint('Essai avec chemin nettoyé: $cleanPath');

      final byteData = await DefaultAssetBundle.of(context).load(cleanPath);
      return await _writeTempFile(byteData, cleanPath);
    } catch (e) {
      debugPrint('Erreur détaillée: $e');
      rethrow;
    }
  }

  String _cleanAssetPath(String path) {
    // Remplacer les espaces par des underscores
    path = path.replaceAll(' ', '_');
    // Supprimer les caractères spéciaux
    path = path.replaceAll(RegExp(r'[^a-zA-Z0-9/_\.-]'), '');
    return path.toLowerCase();
  }

  Future<String> _writeTempFile(ByteData byteData, String originalPath) async {
    if (byteData.lengthInBytes == 0) {
      throw Exception('Fichier vide');
    }

    final fileName = originalPath.split('/').last;
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    return file.path;
  }

  // Méthode pour visualiser
  Future<void> _viewPdf(
    BuildContext context,
    String pdfPath,
    String pdfName,
  ) async {
    try {
      final tempFilePath = await _copyAssetToTempFile(pdfPath, context);
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de visualisation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Méthode pour télécharger
  Future<void> _downloadPdf(
    BuildContext context,
    String pdfPath,
    String pdfName,
  ) async {
    try {
      final byteData = await DefaultAssetBundle.of(context).load(pdfPath);
      final downloadsDir = await getDownloadsDirectory();
      final file = File('${downloadsDir?.path}/$pdfName');

      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      // Ouvrir le fichier avec une app par défaut
      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF téléchargé: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(matiere),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filière: $filiere',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Semestre: $semestre',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'PDFs pour $matiere',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: pdfs.isEmpty
                  ? const Center(
                      child: Text('Aucun PDF disponible pour cette matière.'),
                    )
                  : ListView.builder(
                      itemCount: pdfs.length,
                      itemBuilder: (context, index) {
                        final pdfName = pdfs[index];
                        final pdfPath = '$folder/$pdfName';
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const FaIcon(
                              FontAwesomeIcons.filePdf,
                              color: Colors.red,
                            ),
                            title: Text(pdfName),
                            trailing: const Icon(
                              Icons.download,
                              color: Color(0xFFFBBF24),
                            ),
                            onTap: () async {
                              try {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Ouvrir le PDF'),
                                    content: const Text(
                                      'Choisissez une action:',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _viewPdf(
                                            context,
                                            pdfPath,
                                            pdfName,
                                          );
                                        },
                                        child: const Text('Voir'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _downloadPdf(
                                            context,
                                            pdfPath,
                                            pdfName,
                                          );
                                        },
                                        child: const Text('Télécharger'),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY();
                      },
                    ),
            ),
          ],
        ),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
