import os
import json
import shutil
import unicodedata

def sanitize_name(name):
    """Nettoie les noms pour Flutter"""
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    name = name.replace(' ', '_').replace('/', '_').replace('\\', '_')
    name = ''.join(c for c in name if c.isalnum() or c in ['_', '-', '.'])
    return name.lower()

def fix_all_names(manifest_path, resources_path='assets/resources'):
    """Solution ultime : corrige tout sur place en une passe"""
    
    # Sauvegarde
    if os.path.exists(resources_path + '_backup'):
        shutil.rmtree(resources_path + '_backup')
    shutil.copytree(resources_path, resources_path + '_backup')
    
    # Charger le manifest
    with open(manifest_path, 'r', encoding='utf-8') as f:
        manifest = json.load(f)
    
    new_manifest = {"filieres": []}
    
    for filiere in manifest['filieres']:
        old_filiere_name = filiere['name']
        new_filiere_name = sanitize_name(old_filiere_name)
        
        # Renommer filière
        old_path = os.path.join(resources_path, old_filiere_name)
        new_path = os.path.join(resources_path, new_filiere_name)
        if os.path.exists(old_path) and old_filiere_name != new_filiere_name:
            os.rename(old_path, new_path)
        
        new_filiere = {"name": new_filiere_name, "semestres": []}
        
        for semestre in filiere['semestres']:
            old_semestre_name = semestre['name']
            new_semestre_name = sanitize_name(old_semestre_name)
            
            # Renommer semestre
            old_path = os.path.join(new_path, old_semestre_name)
            new_path_semestre = os.path.join(new_path, new_semestre_name)
            if os.path.exists(old_path) and old_semestre_name != new_semestre_name:
                os.rename(old_path, new_path_semestre)
            
            new_semestre = {"name": new_semestre_name, "matieres": []}
            
            for matiere in semestre['matieres']:
                old_matiere_name = matiere['name']
                new_matiere_name = sanitize_name(old_matiere_name)
                
                # Renommer matière
                old_path = os.path.join(new_path_semestre, old_matiere_name)
                new_path_matiere = os.path.join(new_path_semestre, new_matiere_name)
                if os.path.exists(old_path) and old_matiere_name != new_matiere_name:
                    os.rename(old_path, new_path_matiere)
                
                new_matiere = {
                    "name": new_matiere_name,
                    "folder": f"assets/resources/{new_filiere_name}/{new_semestre_name}/{new_matiere_name}",
                    "pdfs": []
                }
                
                # Renommer PDFs
                if os.path.exists(new_path_matiere):
                    for pdf in os.listdir(new_path_matiere):
                        if pdf.lower().endswith('.pdf'):
                            old_pdf_name = pdf
                            new_pdf_name = sanitize_name(pdf)
                            
                            old_pdf_path = os.path.join(new_path_matiere, old_pdf_name)
                            new_pdf_path = os.path.join(new_path_matiere, new_pdf_name)
                            
                            if old_pdf_name != new_pdf_name:
                                os.rename(old_pdf_path, new_pdf_path)
                            
                            new_matiere['pdfs'].append(new_pdf_name)
                
                new_semestre['matieres'].append(new_matiere)
            
            new_filiere['semestres'].append(new_semestre)
        
        new_manifest['filieres'].append(new_filiere)
    
    # Écraser l'ancien manifest
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(new_manifest, f, indent=2, ensure_ascii=False)
    
    print("✅ Correction terminée ! Aucune modification Flutter nécessaire.")

# UTILISATION ULTRA-SIMPLE
if __name__ == "__main__":
    fix_all_names("assets/resources_manifest.json")