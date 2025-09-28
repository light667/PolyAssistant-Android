import os
import json

def verify_assets_structure():
    """Vérifie que tous les fichiers PDF existent"""
    
    print("🔍 Vérification de la structure des assets...")
    
    # Vérifier la structure de base
    base_path = "assets/resources"
    if not os.path.exists(base_path):
        print(f"❌ Dossier introuvable: {base_path}")
        return False
    
    # Vérifier le manifest
    manifest_path = "assets/resources_manifest.json"
    if not os.path.exists(manifest_path):
        print(f"❌ Manifest introuvable: {manifest_path}")
        return False
    
    with open(manifest_path, 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    missing_files = []
    
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                folder_path = matiere['folder']
                
                # Vérifier que le dossier existe
                if not os.path.exists(folder_path):
                    print(f"❌ Dossier manquant: {folder_path}")
                    missing_files.append(folder_path)
                    continue
                
                # Vérifier chaque PDF
                for pdf in matiere['pdfs']:
                    pdf_path = os.path.join(folder_path, pdf)
                    if not os.path.exists(pdf_path):
                        print(f"❌ PDF manquant: {pdf_path}")
                        missing_files.append(pdf_path)
                    else:
                        print(f"✅ PDF trouvé: {pdf_path}")
    
    if missing_files:
        print(f"\n🚨 {len(missing_files)} fichiers manquants!")
        return False
    else:
        print("✅ Tous les fichiers sont présents!")
        return True

if __name__ == "__main__":
    verify_assets_structure()