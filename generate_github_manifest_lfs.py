import json
import os
import urllib.parse

def generate_github_manifest_lfs():
    """Génère un manifeste avec les URLs GitHub compatibles LFS"""
    
    # Configuration GitHub
    GITHUB_USERNAME = "light667"
    GITHUB_REPO = "PolyAssistant-Android"
    GITHUB_BRANCH = "main"
    
    # Deux options pour Git LFS :
    # Option 1: URL raw standard (peut ne pas fonctionner avec LFS)
    GITHUB_RAW_URL = f"https://raw.githubusercontent.com/{GITHUB_USERNAME}/{GITHUB_REPO}/{GITHUB_BRANCH}"
    
    # Option 2: URL de téléchargement GitHub (meilleure pour LFS)
    GITHUB_DOWNLOAD_URL = f"https://github.com/{GITHUB_USERNAME}/{GITHUB_REPO}/raw/{GITHUB_BRANCH}"
    
    print("🔗 Configuration GitHub:")
    print(f"   👤 Utilisateur: {GITHUB_USERNAME}")
    print(f"   📦 Dépôt: {GITHUB_REPO}")
    print(f"   🌿 Branche: {GITHUB_BRANCH}")
    print(f"   🔗 URL Raw: {GITHUB_RAW_URL}")
    print(f"   ⬇️  URL Download: {GITHUB_DOWNLOAD_URL}")
    
    # Charger le manifeste existant
    with open('assets/resources_manifest.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # Mettre à jour le manifeste avec les URLs GitHub
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                pdfs_with_urls = []
                folder = matiere['folder']
                
                # CORRECTION : S'assurer que le chemin commence par assets/
                if not folder.startswith('assets/'):
                    folder = 'assets/' + folder
                
                for pdf_name in matiere['pdfs']:
                    # Encoder le nom du fichier pour l'URL
                    encoded_pdf_name = urllib.parse.quote(pdf_name)
                    
                    # Utiliser l'URL de téléchargement GitHub (meilleure pour LFS)
                    pdf_url = f"{GITHUB_DOWNLOAD_URL}/{folder}/{encoded_pdf_name}"
                    
                    # Alternative: URL raw standard
                    # pdf_url = f"{GITHUB_RAW_URL}/{folder}/{encoded_pdf_name}"
                    
                    pdfs_with_urls.append({
                        "name": pdf_name,
                        "url": pdf_url,
                        "source": "github_lfs"
                    })
                
                # Remplacer la liste simple par la liste avec URLs
                matiere['pdfs'] = pdfs_with_urls
    
    # Sauvegarder le nouveau manifeste
    with open('assets/resources_manifest_online.json', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print("✅ Manifeste GitHub LFS généré avec succès!")

if __name__ == "__main__":
    generate_github_manifest_lfs()