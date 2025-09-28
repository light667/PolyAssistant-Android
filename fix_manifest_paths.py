import json
import os

def fix_manifest_paths():
    """Corrige les chemins dans le manifest JSON"""
    
    with open('assets/resources_manifest.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # Correction des chemins
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                current_folder = matiere['folder']
                
                # Supprimer le double "assets/assets"
                if current_folder.startswith('assets/assets/'):
                    corrected_folder = current_folder.replace('assets/assets/', 'assets/')
                    matiere['folder'] = corrected_folder
                    print(f"✅ Corrigé: {current_folder} → {corrected_folder}")
                
                # Vérifier que le chemin existe
                if not os.path.exists(matiere['folder']):
                    print(f"❌ Chemin introuvable: {matiere['folder']}")
    
    # Sauvegarder le manifest corrigé
    with open('assets/resources_manifest.json', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print("✅ Manifest corrigé avec succès!")

if __name__ == "__main__":
    fix_manifest_paths()