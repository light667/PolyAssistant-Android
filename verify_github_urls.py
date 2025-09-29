import json
import requests

def verify_github_urls():
    """Vérifie que toutes les URLs GitHub sont accessibles"""
    
    with open('assets/resources_manifest_online.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    print("🔍 Vérification des URLs GitHub...")
    
    accessible = 0
    errors = []
    
    for filiere in manifest['filieres']:
        print(f"\n📚 Filière: {filiere['name']}")
        
        for semestre in filiere['semestres']:
            print(f"  📅 Semestre: {semestre['name']}")
            
            for matiere in semestre['matieres']:
                print(f"    📖 Matière: {matiere['name']}")
                
                for pdf in matiere['pdfs']:
                    url = pdf['url']
                    try:
                        response = requests.head(url, timeout=10)
                        if response.status_code == 200:
                            print(f"      ✅ {pdf['name']}")
                            accessible += 1
                        else:
                            print(f"      ❌ {pdf['name']} - HTTP {response.status_code}")
                            errors.append({
                                'file': pdf['name'],
                                'url': url,
                                'error': f'HTTP {response.status_code}'
                            })
                    except Exception as e:
                        print(f"      ❌ {pdf['name']} - {str(e)}")
                        errors.append({
                            'file': pdf['name'],
                            'url': url,
                            'error': str(e)
                        })
    
    print(f"\n📊 RÉSULTATS:")
    print(f"   ✅ {accessible} fichiers accessibles")
    print(f"   ❌ {len(errors)} fichiers avec erreurs")
    
    if errors:
        print(f"\n🚨 Fichiers avec erreurs:")
        for error in errors[:10]:  # Afficher seulement les 10 premiers
            print(f"   • {error['file']}")
            print(f"     {error['url']}")
            print(f"     Erreur: {error['error']}")
            print()

if __name__ == "__main__":
    verify_github_urls()