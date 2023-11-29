import pandas as pd
from scipy import stats
import statistics
import math
import matplotlib.pyplot as plt


burden_estimates = pd.read_csv("MDR_RR_TB_burden_estimates_2023-11-29.csv")
print(burden_estimates['e_rr_in_notified_labconf_pulm_hi'].describe())

height = pd.read_csv("wzrost.csv", header=None).values.flatten().tolist()
print(f"""
Dane dla wzrost.csv:
    mean: {statistics.mean(height)}
    fmean: {statistics.fmean(height)}
    median: {statistics.median(height)}
    median_low: {statistics.median_low(height)}
    median_high: {statistics.median_high(height)}
    st_dev: {statistics.stdev(height)}
    variance: {statistics.variance(height)}

Odchylenie standardowe to pierwisatek z warciancji
{round(math.sqrt(round(statistics.variance(height), 2)), 2)} == {round(statistics.stdev(height), 2)}
""")

brain_data = pd.read_csv("brain_size.csv", delimiter=';')
fsiq_stats = stats.describe(brain_data['FSIQ'].dropna())
print(f"""
Dane dla brain_size.csv:
    Średnia FSIQ: {fsiq_stats.mean}
    Odchylenie standardowe FSIQ: {fsiq_stats.variance**0.5}
    Minimum FSIQ: {fsiq_stats.minmax[0]}
    Maximum FSIQ: {fsiq_stats.minmax[1]}
""")

# Średnia VIQ
viq_mean = brain_data['VIQ'].mean()
print(f"Średnia VIQ: {viq_mean}")

# Ile kobiet i mężczyzn jest wyróżnionych w pliku
gender_counts = brain_data['Gender'].value_counts()
print("Liczba kobiet i mężczyzn:")
print(gender_counts)

# histogramy dla zmiennych VIQ, PIQ, FSIQ
brain_data[['VIQ', 'PIQ', 'FSIQ']].hist(bins=15, figsize=(10, 6))
plt.suptitle('Histogramy VIQ, PIQ, FSIQ')
plt.show()

# histogramy trzech kolumn tylko dla kobiet
brain_data[brain_data['Gender'] == 'Female'][['VIQ', 'PIQ', 'FSIQ']].hist(bins=15, figsize=(10, 6))
plt.suptitle('Histogramy VIQ, PIQ, FSIQ dla kobiet')
plt.show()