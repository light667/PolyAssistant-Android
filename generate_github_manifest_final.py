import json
import os
import urllib.parse

def generate_github_manifest_final():
    
    GITHUB_USERNAME = "light667"
    GITHUB_REPO = "PolyAssistant-Android"
    GITHUB_BRANCH = "main"
    GITHUB_DOSSIER = "assets"
    
    GITHUB_MEDIA_URL = f"https://media.githubusercontent.com/media/{GITHUB_USERNAME}/{GITHUB_REPO}/{GITHUB_BRANCH}/{GITHUB_DOSSIER}"
    
    print("🔗 Configuration GitHub FINALE (LFS Compatible):")
    print(f"   👤 Utilisateur: {GITHUB_USERNAME}")
    print(f"   📦 Dépôt: {GITHUB_REPO}")
    print(f"   🌿 Branche: {GITHUB_BRANCH}")
    print(f"   📡 URL Media: {GITHUB_MEDIA_URL}")
    
    with open('assets/resources_manifest.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    # Mettre à jour le manifeste avec les URLs media GitHub
    for filiere in manifest['filieres']:
        for semestre in filiere['semestres']:
            for matiere in semestre['matieres']:
                pdfs_with_urls = []
                folder = matiere['folder']
                
                # ✅ CORRECTION CRITIQUE : NE PAS MODIFIER LE DOSSIER !
                # Le dossier dans le manifeste est déjà correct : "assets/resources/..."
                # NE PAS enlever le préfixe 'assets/' !
                
                print(f"\n📚 {filiere['name']} -> {semestre['name']} -> {matiere['name']}")
                print(f"   📁 Dossier: {folder}")
                
                for pdf_name in matiere['pdfs']:
                    # Encoder le nom du fichier pour l'URL
                    encoded_pdf_name = urllib.parse.quote(pdf_name)
                    
                    # ✅ CORRECTION : Utiliser le dossier COMPLET sans modification
                    pdf_url = f"{GITHUB_MEDIA_URL}/{folder}/{encoded_pdf_name}"
                    
                    pdfs_with_urls.append({
                        "name": pdf_name,
                        "url": pdf_url,
                        "source": "github_media_lfs"
                    })
                    
                    print(f"   📄 {pdf_name}")
                    print(f"   🔗 {pdf_url}")
                
                matiere['pdfs'] = pdfs_with_urls
    
    # Sauvegarder le nouveau manifeste
    with open('assets/resources_manifest_online.json', 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    total_pdfs = sum(len(m['pdfs']) for f in manifest['filieres'] for s in f['semestres'] for m in s['matieres'])
    print(f"\n✅ Manifeste FINAL (LFS Compatible) généré avec succès!")
    print(f"📊 Total de {total_pdfs} PDFs configurés")
    
    return True

if __name__ == "__main__":
    generate_github_manifest_final()