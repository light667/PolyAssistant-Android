import os
import json

def generate_manifest(root_dir='assets/resources', output_file='assets/resources_manifest.json'):
    manifest = {"filieres": []}
    
    # Parcourir les filières
    for filiere in sorted(os.listdir(root_dir)):
        filiere_path = os.path.join(root_dir, filiere)
        if os.path.isdir(filiere_path):
            filiere_data = {"name": filiere, "semestres": []}
            
            # Parcourir les semestres
            for semestre in sorted(os.listdir(filiere_path)):
                semestre_path = os.path.join(filiere_path, semestre)
                if os.path.isdir(semestre_path):
                    semestre_data = {"name": semestre, "matieres": []}
                    
                    # Parcourir les matières
                    for matiere in sorted(os.listdir(semestre_path)):
                        matiere_path = os.path.join(semestre_path, matiere)
                        if os.path.isdir(matiere_path):
                            # Lister les PDFs
                            pdfs = [
                                f for f in sorted(os.listdir(matiere_path))
                                if f.lower().endswith('.pdf')
                            ]
                            matiere_data = {
                                "name": matiere,
                                "folder": f"assets/resources/{filiere}/{semestre}/{matiere}",
                                "pdfs": pdfs
                            }
                            semestre_data["matieres"].append(matiere_data)
                    
                    if semestre_data["matieres"]:
                        filiere_data["semestres"].append(semestre_data)
        
            if filiere_data["semestres"]:
                manifest["filieres"].append(filiere_data)
    
    # Écrire le JSON
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print(f"Manifeste généré : {output_file}")
    print(f"Nombre de filières : {len(manifest['filieres'])}")

if __name__ == "__main__":
    generate_manifest()