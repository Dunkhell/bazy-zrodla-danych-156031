import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import bernoulli, binom, poisson, describe, norm
from scipy import stats

# zad 1
wartosci = np.array([1, 2, 3, 4, 5, 6])
prawdopodobienstwo = np.array([1/6, 1/6, 1/6, 1/6, 1/6, 1/6])

srednia = np.sum(wartosci * prawdopodobienstwo)

wariancja = np.sum((wartosci - srednia)**2 * prawdopodobienstwo)

odchylenie_standardowe = np.sqrt(wariancja)

odchylenie_przecietne = np.sum(np.abs(wartosci - srednia) * prawdopodobienstwo)


print(f"Średnia: {srednia}")
print(f"Wariancja: {wariancja}")
print(f"Odchylenie standardowe: {odchylenie_standardowe}")
print(f"Odchylenie przeciętne: {odchylenie_przecietne}")

np.random.seed(42)
n = 100

# zad 2
p_bernoulli = 0.3
p_binomial = 0.5
lambda_poisson = 10.0

samples_bernoulli = bernoulli.rvs(p_bernoulli, size=n)
samples_binomial = binom.rvs(n, p_binomial, size=n)
samples_poisson = poisson.rvs(lambda_poisson, size=n)

stats_bernoulli = describe(samples_bernoulli)
stats_binomial = describe(samples_binomial)
stats_poisson = describe(samples_poisson)

# zad 3
print("Statystyki dla rozkładu Bernoulliego:")
print(stats_bernoulli)

print("\nStatystyki dla rozkładu Dwumianowego:")
print(stats_binomial)

print("\nStatystyki dla rozkładu Poissona:")
print(stats_poisson)

# zad 4
fig, axes = plt.subplots(3, 1, figsize=(8, 12))
axes[0].hist(samples_bernoulli, bins=[0, 1, 2], align='left', edgecolor='black')
axes[0].set_title('Rozkład Bernoulliego (p={})'.format(p_bernoulli))

x_binomial = np.arange(0, n+1)
axes[1].hist(samples_binomial, bins=x_binomial - 0.5, align='mid', edgecolor='black')
axes[1].set_title('Rozkład Dwumianowy (n={}, p={})'.format(n, p_binomial))

x_poisson = np.arange(0, 10)
axes[2].hist(samples_poisson, bins=x_poisson - 0.5, align='mid', edgecolor='black')
axes[2].set_title('Rozkład Poissona (lambda={})'.format(lambda_poisson))

plt.tight_layout()
plt.show()

# zad 5
n = 20
p = 0.4

k_values = np.arange(0, n+1)
binomial_pmf = binom.pmf(k_values, n, p)

sum_probabilities = np.sum(binomial_pmf)

plt.bar(k_values, binomial_pmf, align='center', alpha=0.7)
plt.title('Rozkład prawdopodobieństwa Dwumianowego (n={}, p={})'.format(n, p))
plt.xlabel('k (Liczba sukcesów)')
plt.ylabel('Prawdopodobieństwo')
plt.show()

print("Suma prawdopodobieństw:", sum_probabilities)

# zad 6
srednia = 0
odchylenie_standardowe = 2
liczba_danych = 100

dane = np.random.normal(srednia, odchylenie_standardowe, liczba_danych)
srednia_danych = np.mean(dane)
mediana_danych = np.median(dane)
odchylenie_standardowe_danych = np.std(dane)
kwartyl1, kwartyl3 = np.percentile(dane, [25, 75])
rozstep_miedzykwartylowy = stats.iqr(dane)

print("Statystyki teoretyczne:")
print("Średnia teoretyczna:", srednia)
print("Mediana teoretyczna:", srednia)
print("Odchylenie standardowe teoretyczne:", odchylenie_standardowe)

print("\nStatystyki danych wygenerowanych:")
print("Średnia danych:", srednia_danych)
print("Mediana danych:", mediana_danych)
print("Odchylenie standardowe danych:", odchylenie_standardowe_danych)
print("Kwartyl 1:", kwartyl1)
print("Kwartyl 3:", kwartyl3)
print("Rozstęp międzykwartylowy:", rozstep_miedzykwartylowy)

# Zad 7
srednia1, odchylenie_standardowe1 = 1, 2
srednia2, odchylenie_standardowe2 = -1, 0.5

dane1 = np.random.normal(srednia1, odchylenie_standardowe1, 1000)
dane2 = np.random.normal(srednia2, odchylenie_standardowe2, 1000)

plt.hist(dane1, bins=30, density=True, alpha=0.5, color='blue', label='N(1, 2)')
plt.hist(dane2, bins=30, density=True, alpha=0.5, color='green', label='N(-1, 0.5)')


x_range = np.linspace(-5, 5, 1000)
plt.plot(x_range, norm.pdf(x_range, srednia1, odchylenie_standardowe1), color='blue', linestyle='dashed', label='Gęstość N(1, 2)')
plt.plot(x_range, norm.pdf(x_range, srednia2, odchylenie_standardowe2), color='green', linestyle='dashed', label='Gęstość N(-1, 0.5)')

plt.legend()
plt.title('Histogram i wykres gęstości dla różnych rozkładów normalnych')
plt.xlabel('Wartość')
plt.ylabel('Gęstość')

plt.show()
