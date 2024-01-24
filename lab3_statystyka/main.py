import numpy as np
import pandas as pd
from scipy import stats

# Cwiczenie 1
srednia_rozkładu = 2
odchylenie_rozkładu = 30
liczba_elementow = 200

probka_losowa = np.random.normal(srednia_rozkładu, odchylenie_rozkładu, liczba_elementow)

hipoteza_srednia = 2.5
statystyka, p_wartosc = stats.ttest_1samp(probka_losowa, hipoteza_srednia)

print("Cwiczenie 1:")
print("Statystyka t:", statystyka)
print("Wartość p:", p_wartosc)
print("Hipoteza o średniej równa", hipoteza_srednia, ":", "Odrzucana" if p_wartosc < 0.05 else "Nie odrzucana")

# Cwiczenie 2
df_napoje = pd.read_csv('napoje.csv', delimiter=";")
hipoteza_lech = 60500
hipoteza_cola = 222000
hipoteza_regionalne = 43500
stat_lech, p_lech = stats.ttest_1samp(df_napoje['lech'], hipoteza_lech)
stat_cola, p_cola = stats.ttest_1samp(df_napoje['cola'], hipoteza_cola)
stat_regionalne, p_regionalne = stats.ttest_1samp(df_napoje['regionalne'], hipoteza_regionalne)

print("\nCwiczenie 2:")
print("Statystyka t dla piwa Lech:", stat_lech, "p-wartość:", p_lech)
print("Statystyka t dla coli:", stat_cola, "p-wartość:", p_cola)
print("Statystyka t dla piw regionalnych:", stat_regionalne, "p-wartość:", p_regionalne)

# Cwiczenie 3
normalne_zmienne = [var for var in df_napoje.columns if stats.normaltest(df_napoje[var])[1] > 0.05]
print("\nCwiczenie 3:")
print("Zmienne wykazujące normalność:", normalne_zmienne)

# Cwiczenie 4
stat_okocim_lech, p_okocim_lech = stats.ttest_rel(df_napoje['okocim'], df_napoje['lech'])
stat_fanta_regionalne, p_fanta_regionalne = stats.ttest_rel(df_napoje['fanta'], df_napoje['regionalne'])
stat_cola_pepsi, p_cola_pepsi = stats.ttest_rel(df_napoje['cola'], df_napoje['pepsi'])

print("\nCwiczenie 4:")
print("Statystyka t dla Okocim - Lech:", stat_okocim_lech, "p-wartość:", p_okocim_lech)
print("Statystyka t dla Fanta - Regionalne:", stat_fanta_regionalne, "p-wartość:", p_fanta_regionalne)
print("Statystyka t dla Cola - Pepsi:", stat_cola_pepsi, "p-wartość:", p_cola_pepsi)

# Cwiczenie 5
stat_okocim_lech_var, p_okocim_lech_var = stats.levene(df_napoje['okocim'], df_napoje['lech'])
stat_zywiec_fanta_var, p_zywiec_fanta_var = stats.levene(df_napoje['żywiec'], df_napoje['fanta'])
stat_regionalne_cola_var, p_regionalne_cola_var = stats.levene(df_napoje['regionalne'], df_napoje['cola'])

print("\nCwiczenie 5:")
print("Statystyka Levene dla Okocim - Lech:", stat_okocim_lech_var, "p-wartość:", p_okocim_lech_var)
print("Statystyka Levene dla Żywiec - Fanta:", stat_zywiec_fanta_var, "p-wartość:", p_zywiec_fanta_var)
print("Statystyka Levene dla Regionalne - Cola:", stat_regionalne_cola_var, "p-wartość:", p_regionalne_cola_var)

# Cwiczenie 6
stat_regionalne_2001_2015, p_regionalne_2001_2015 = stats.ttest_ind(df_napoje.loc[df_napoje['rok'] == 2001, 'regionalne'],
                                                                     df_napoje.loc[df_napoje['rok'] == 2015, 'regionalne'])

print("\nCwiczenie 6:")
print("Statystyka t dla piw regionalnych (2001 vs. 2015):", stat_regionalne_2001_2015, "p-wartość:", p_regionalne_2001_2015)

# Cwiczenie 7
df_napoje_po_reklamie = pd.read_csv('napoje_po_reklamie.csv', delimiter=";")

common_rows = min(len(df_napoje), len(df_napoje_po_reklamie))
df_napoje = df_napoje.head(common_rows)
df_napoje_po_reklamie = df_napoje_po_reklamie.head(common_rows)

stat_cola_2016, p_cola_2016 = stats.ttest_rel(df_napoje['cola'], df_napoje_po_reklamie['cola'])
stat_fanta_2016, p_fanta_2016 = stats.ttest_rel(df_napoje['fanta'], df_napoje_po_reklamie['fanta'])
stat_pepsi_2016, p_pepsi_2016 = stats.ttest_rel(df_napoje['pepsi'], df_napoje_po_reklamie['pepsi'])

print("\nCwiczenie 7:")
print("Statystyka t dla Cola (2016 vs. po reklamie):", stat_cola_2016, "p-wartość:", p_cola_2016)
print("Statystyka t dla Pepsi (2016 vs. po reklamie):", stat_pepsi_2016, "p-wartość:", p_pepsi_2016)