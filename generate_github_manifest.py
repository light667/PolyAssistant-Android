# generate_github_manifest.py
import json
import os

def generate_github_manifest():
    """Génère un manifeste avec les URLs GitHub pour tous les PDFs"""
    
    # Charger le manifeste existant
    with open('assets/resources_manifest.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # Configuration GitHub
    GITHUB_USERNAME = "light667"
    REPO_NAME = "PolyAssistant-Android"
    BRANCH = "main"  # ou "master" selon votre repo
    BASE_URL = f"https://raw.githubusercontent.com/{GITHUB_USERNAME}/{REPO_NAME}/{BRANCH}"
    
    print("🚀 Génération du manifeste GitHub...")
    
    # Mettre à jour le manifeste avec les URLs GitHub
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                current_folder = matiere['folder']
                
                # Convertir le chemin local en URL GitHub
                # Exemple: "assets/resources/lf_genie_civil/semestre_1/algebre_lineaire"
                # → "https://raw.githubusercontent.com/light667/PolyAssistant-Android/main/assets/resources/lf_genie_civil/semestre_1/algebre_lineaire"
                github_folder = current_folder
                
                pdfs_with_urls = []
                
                for pdf_name in matiere['pdfs']:
                    # Construire l'URL GitHub complète
                    pdf_url = f"{BASE_URL}/{github_folder}/{pdf_name}"
                    
                    pdfs_with_urls.append({
                        "name": pdf_name,
                        "url": pdf_url
                    })
                
                # Remplacer la liste simple par la liste avec URLs
                matiere['pdfs'] = pdfs_with_urls
                
                print(f"✅ {matiere['name']}: {len(pdfs_with_urls)} PDFs")
    
    # Sauvegarder le nouveau manifeste
    with open('assets/resources_manifest_github.json', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print(f"\n🎉 Manifeste GitHub généré avec succès!")
    print(f"📁 Fichier: assets/resources_manifest_github.json")
    print(f"🔗 Base URL: {BASE_URL}")
    print(f"📚 Total filières: {len(manifest['filieres'])}")

if __name__ == "__main__":
    generate_github_manifest()