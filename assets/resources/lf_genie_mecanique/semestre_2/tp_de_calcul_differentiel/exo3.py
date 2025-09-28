import matplotlib.pyplot as plt
import numpy as np
import math

# Définition des fonctions
def factoriel(k):
    if k >= 0:
        if k == 1 or k == 0:
            return 1
        else:
            return k * factoriel(k - 1)
    else:
        return float('nan')

def S(x, n):
    sum_result = 0
    for k in range(n + 1):
        sum_result += x ** k / factoriel(k)
    return sum_result

# Génération des valeurs de x
x_values = np.linspace(0, 10, 400)

# Calcul des valeurs de f2, f3, f4 et exp pour chaque x
f2_values = [S(x, 2) for x in x_values]
f3_values = [S(x, 3) for x in x_values]
f4_values = [S(x, 4) for x in x_values]
f10_values = [S(x, 10) for x in x_values]
exp_values = [math.exp(x) for x in x_values]

# Tracé des graphiques
plt.figure(figsize=(12, 8))

plt.plot(x_values, f2_values, label='f2(x)')
plt.plot(x_values, f3_values, label='f3(x)')
plt.plot(x_values, f4_values, label='f4(x)')
plt.plot(x_values, f10_values, label='f10(x)', linestyle='--')
plt.plot(x_values, exp_values, label='exp(x)', linestyle=':')

plt.xlabel('x')
plt.ylabel('y')
plt.title('Comparaison des fonctions f2(x), f3(x), f4(x), f10(x) et exp(x)')
plt.legend()
plt.grid(True)
plt.show()