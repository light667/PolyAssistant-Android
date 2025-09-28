import os
import json
import unicodedata
import re

def simple_sanitize(name):
    """Version ultra-simple et fiable de sanitize"""
    if not name:
        return "unknown"
    
    # Convertir en minuscules
    name = name.lower()
    
    # Remplacer les espaces par underscores
    name = name.replace(' ', '_')
    
    # Remplacer les caractères accentués
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    
    # Garder seulement les caractères autorisés
    name = re.sub(r'[^a-z0-9_\.]', '', name)
    
    # Nettoyer les underscores multiples
    name = re.sub(r'_+', '_', name)
    name = name.strip('_')
    
    return name if name else "unknown"

def quick_fix_structure(resources_path):
    """Correction rapide et fiable"""
    print("🔧 Correction rapide de la structure...")
    
    for root, dirs, files in os.walk(resources_path, topdown=False):
        # Renommer les fichiers
        for file in files:
            if file.endswith('.pdf'):
                old_path = os.path.join(root, file)
                new_name = simple_sanitize(file)
                new_path = os.path.join(root, new_name)
                
                if old_path != new_path and os.path.exists(old_path):
                    try:
                        os.rename(old_path, new_path)
                        print(f"📄 {file} → {new_name}")
                    except:
                        pass
        
        # Renommer les dossiers
        for dir_name in dirs:
            old_path = os.path.join(root, dir_name)
            new_name = simple_sanitize(dir_name)
            new_path = os.path.join(root, new_name)
            
            if old_path != new_path and os.path.exists(old_path):
                try:
                    os.rename(old_path, new_path)
                    print(f"📁 {dir_name} → {new_name}")
                except:
                    pass

def generate_simple_manifest(resources_path):
    """Génération simple du manifest"""
    manifest = {"filieres": []}
    
    for filiere in sorted(os.listdir(resources_path)):
        filiere_path = os.path.join(resources_path, filiere)
        if not os.path.isdir(filiere_path):
            continue
            
        filiere_data = {"name": filiere, "semestres": []}
        
        for semestre in sorted(os.listdir(filiere_path)):
            semestre_path = os.path.join(filiere_path, semestre)
            if not os.path.isdir(semestre_path):
                continue
                
            semestre_data = {"name": semestre, "matieres": []}
            
            for matiere in sorted(os.listdir(semestre_path)):
                matiere_path = os.path.join(semestre_path, matiere)
                if not os.path.isdir(matiere_path):
                    continue
                    
                pdfs = [f for f in sorted(os.listdir(matiere_path)) if f.lower().endswith('.pdf')]
                if pdfs:
                    semestre_data["matieres"].append({
                        "name": matiere,
                        "folder": f"assets/resources/{filiere}/{semestre}/{matiere}",
                        "pdfs": pdfs
                    })
            
            if semestre_data["matieres"]:
                filiere_data["semestres"].append(semestre_data)
        
        if filiere_data["semestres"]:
            manifest["filieres"].append(filiere_data)
    
    return manifest

# EXÉCUTION RAPIDE
if __name__ == "__main__":
    resources_path = "assets/resources"
    
    print("🚀 CORRECTION RAPIDE")
    quick_fix_structure(resources_path)
    
    print("\n📋 GÉNÉRATION DU MANIFEST")
    manifest = generate_simple_manifest(resources_path)
    
    with open("assets/resources_manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2, ensure_ascii=False)
    
    print("✅ TERMINÉ !")