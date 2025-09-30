import json

def check_manifest_urls():
    """Vérifie rapidement les URLs dans le manifeste généré"""
    
    with open('assets/resources_manifest_online.json', 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    print("🔍 Vérification rapide des URLs dans le manifeste...")
    
    for filiere in manifest['filieres'][:1]:  # Vérifier seulement la première filière
        print(f"\n📚 Filière: {filiere['name']}")
        
        for semestre in filiere['semestres'][:1]:  # Premier semestre
            print(f"  📅 Semestre: {semestre['name']}")
            
            for matiere in semestre['matieres'][:1]:  # Première matière
                print(f"    📖 Matière: {matiere['name']}")
                
                for pdf in matiere['pdfs'][:1]:  # Premier PDF
                    url = pdf['url']
                    print(f"      📄 {pdf['name']}")
                    print(f"      🔗 {url}")
                    
                    # Vérifier si l'URL contient le bon chemin
                    if 'assets/resources/' in url:
                        print("      ✅ Chemin 'assets/resources/' trouvé dans l'URL")
                    else:
                        print("      ❌ CHEMAN INCORRECT: 'assets/resources/' manquant")
                    
                    if 'media.githubusercontent.com' in url:
                        print("      ✅ Domaine media.githubusercontent.com correct")
                    else:
                        print("      ❌ Domaine incorrect")
                    
                    return  # On s'arrête après le premier PDF

if __name__ == "__main__":
    check_manifest_urls()