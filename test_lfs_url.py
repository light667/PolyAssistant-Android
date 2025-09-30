import requests

def test_lfs_urls():
    """Teste différentes URLs pour contourner Git LFS"""
    
    test_files = [
        "examen_math101.pdf",
        "exercices_corriges_application_lineaire_et_determinants.pdf"
    ]
    
    base_path = "assets/resources/lf_genie_civil/semestre_1/algebre_lineaire"
    
    urls_to_test = [
        # URL raw (ne fonctionne pas avec LFS)
        f"https://raw.githubusercontent.com/light667/PolyAssistant-Android/main/{base_path}/{{file}}",
        # URL download (devrait fonctionner)
        f"https://github.com/light667/PolyAssistant-Android/raw/main/{base_path}/{{file}}",
        # URL media (alternative)
        f"https://media.githubusercontent.com/media/light667/PolyAssistant-Android/main/{base_path}/{{file}}"
    ]
    
    for test_file in test_files:
        print(f"\n🔍 Test de: {test_file}")
        print("=" * 50)
        
        for url_template in urls_to_test:
            url = url_template.format(file=test_file)
            try:
                response = requests.head(url, timeout=10, allow_redirects=True)
                print(f"🌐 {url}")
                print(f"   Status: {response.status_code}")
                print(f"   Content-Type: {response.headers.get('content-type', 'N/A')}")
                print(f"   Content-Length: {response.headers.get('content-length', 'N/A')}")
                
                if response.status_code == 200:
                    # Tester le contenu
                    content_response = requests.get(url, timeout=5)
                    if content_response.text.startswith("version https://git-lfs.github.com"):
                        print("   ⚠️  POINTEUR LFS DÉTECTÉ")
                    else:
                        print("   ✅ FICHIER RÉEL DÉTECTÉ")
                
            except Exception as e:
                print(f"   ❌ Erreur: {e}")
            print()

if __name__ == "__main__":
    test_lfs_urls()