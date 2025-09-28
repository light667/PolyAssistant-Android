import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

from matplotlib import rc

#créer un tableau X qui nous servira d’absices
# Valeur minimale -2, Valeur maximale -2
# le nombre de point  25

x = 

def f1(x):
    return np.exp(X)

def f2(x):
    return X**2

def f3(x):
    return 2*np.sin(X) + 4

#créer 3 tableaux représentant les ordonnées relatives à X pour 3 fonctions.

Y1 = _____
Y2 = _____
Y3 = _____

plt.figure(1)

plt.plot(___, ___, 'b-', label = r'$ e^x $')
plt.plot(___, ___, 'r+', label = r'$x^{2}$')
plt.plot(___, ___, 'ks--', linewidth = 2, label = r'$2 \times sin(x) + 4$')

#Nommer les axes X et Y de votre figure

...
# La legende
...

plt.grid('True')# grille 
plt.show()