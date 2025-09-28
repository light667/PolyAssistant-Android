
def saisir():
    new = "O"  # O -> oui ; N -> non
    fichier = open("concours.txt", "a")
    decision = {"a": "admis(e)", "r": "refuse(e)", "aj": "ajourne(e)"}
    while new == "O":
        cin = input("Saisir le Numero CIN : ")
        nom = input("Saisir le Nom : ")
        prenom = input("Saisir le prenom : ")
        age = input("saisir l age ")
        dec = input("saisir la decision a(admis(e))
                    r(refuse(e))
                    aj(ajourne(e)): ")
        ligne = cin+";"+nom+";"+prenom+";"+age+";"+decision[dec]+"\n"
        fichier.write(ligne)
        new = input("Saisir un nouveau candidat, (O / N) ?")
    fichier.close()
 
 
def admis():
    fichier = open("concours.txt","r")
    dest = open("admis.txt", "a")
    for ligne in fichier.readlines() :
        L = ligne.split(";")
        if L[4].strip() == "admis(e)":
            dest.write(ligne)
    fichier.close()
    dest.close()
 
 
def attente():
    fichier = open("admis.txt")
    dest = open("attente.txt", "a")
    for ligne in fichier.readlines():
        L = ligne.split(";")
        if int(L[3]) >= 30:
            enreg = L[0]+";"+L[1]+";"+L[2]+"\n"
            dest.write(enreg)
    fichier.close()
    dest.close()
 
 
def statistiques(dec):
    fichier = open("concours.txt")
    L = fichier.readlines()
    fichier.close()
    L1 = []  # candidats admis
    L2 = []  # candidats refuses
    L3 = []  # candidats ajournes
    for ligne in L:
        l = ligne.split(";")
        if l[4].strip() == "admis(e)":
            L1.append(ligne)
        elif l[4].strip() == "refuse(e)":
            L2.append(ligne)
        else:
            L3.append(ligne)
    if dec == "admis":
        return (len(L1)/len(L))*100
    elif dec == "refuse":
        return (len(L2)/len(L))*100
    else:
        return (len(L3)/len(L))*100
 
 
def supprimer():
    fichier = open("admis.txt")
    candidat = []  # contient les candidats restants
    for ligne in fichier:
        L = ligne.split(";")
        if int(L[3]) < 30:
            candidat.append(ligne)
    fichier.close()
    # reecrire la nouvelle liste
    fichier = open("admis.txt", "w")
    fichier.writelines(candidat)
    fichier.close()
