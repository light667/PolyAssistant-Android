import json
import os

def fix_web_manifest():
    """Corrige le manifeste pour le web"""
    
    with open('assets/resources_manifest.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # Correction des chemins pour le web
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                # Le chemin actuel est "assets/resources/..." mais sur le web c'est juste "resources/..."
                current_folder = matiere['folder']
                if current_folder.startswith('assets/'):
                    corrected_folder = current_folder.replace('assets/', '')
                    matiere['folder'] = corrected_folder
                    print(f"✅ Corrigé: {current_folder} → {corrected_folder}")
    
    # Sauvegarder le manifeste corrigé
    with open('assets/resources_manifest.json', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print("✅ Manifeste corrigé pour le web!")

if __name__ == "__main__":
    fix_web_manifest()