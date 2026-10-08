🇬🇧 [English version](einmessen.en.md)

# Einmessen und Kalibrieren

Zurück zur [README](../README.md). Stand 08.10.2026.

Eingemessen werden vier Dinge:

1. Knoten A: Leer- und Vollabstand des Ultraschallsensors, also 0 % und 100 %
2. Knoten B: ADC-Faktor der Akkuspannung
3. Knoten B: Schaltrichtung des Schwimmers
4. Pumpe: Normalleistung und daraus die Trockenlauf-Schwelle in HA

Dazu kommt der Selbstentladetest des Akkus vor dem Einbau.

---

## 1. Knoten A: Füllstand einmessen

**Wann:** erst **nach der Montage** des Kombi-Gehäuses auf dem IBC, denn gemessen wird ab der tatsächlichen Wandlerfläche.

### Grundlagen

- Der Sensor misst den Abstand **Wandlerfläche → Wasseroberfläche** in mm (`sensor.ibc_wasser_abstand_wasser`).
- Die Wandlerfläche liegt ~1,5 mm **unter** der IBC-Oberseite. Das ist für die Rechnung vernachlässigbar.
- Der Sensor ist unterhalb von ~30 mm blind (A02YYUW: Mindestabstand 3 cm). Deshalb ist „voll“ nicht randvoll.
- Container A hat **keinen Überlauf**. Als 100 % gilt deshalb **50 mm unter der Oberseite**: Entscheidung vom 07.10., als Annahme festgelegt, nicht aus einem Überlaufmaß abgeleitet.

### Formeln (so stehen sie in der Firmware)

```
Füllstand_% = (abstand_leer_mm − Abstand) / (abstand_leer_mm − abstand_voll_mm) × 100      → auf 0…100 begrenzt
Inhalt_L    = Füllstand_% / 100 × volumen_l                                                (volumen_l = 1000)
Liter pro cm = volumen_l / ((abstand_leer_mm − abstand_voll_mm) / 10)                       (≈ 10 l/cm)
```

### Schritt für Schritt

1. **Ruhiges Wasser:** Pumpe aus, kein Regen-Zulauf. Etwa eine Minute warten, denn der Medianfilter braucht 10 neue Werte, und gesendet wird höchstens alle 30 s.
2. **Sensorwert ablesen:** `IBC Wasser Abstand Wasser` in HA, z. B. `d = 612 mm`. Zwei, drei Werte abwarten, sie sollten sich höchstens um wenige mm unterscheiden.
3. **Wassertiefe messen:** Zollstock an der Einfüllöffnung senkrecht bis auf den Boden, Wasserlinie ablesen, z. B. `h = 395 mm`.
   - Die Pumpe steht mittig am Boden. Den Zollstock daneben ansetzen, nicht auf der Pumpe.
4. **Leerwert rechnen:**
   ```
   abstand_leer_mm = d + h          Beispiel: 612 + 395 = 1007
   ```
5. **Vollwert setzen:** `abstand_voll_mm = 50`.
6. **Im ESPHome Builder** die YAML von `ibc-wasser` öffnen (der Builder ist führend) und dort:
   - `abstand_leer_mm` und `abstand_voll_mm` eintragen,
   - **den ganzen `binary_sensor`-Block „Zielcontainer voll“ (GPIO14) löschen**, denn der Schwimmer sitzt an Knoten B. Sonst meldet A dauerhaft „Ziel voll“,
   - den Kopfkommentar („mittig im Deckel“, „Schwimmer … D5“) aktualisieren,
   - *Install → Wirelessly*.
7. **Kontrolle:** Der Füllstand sollte jetzt `h / (leer − 50) × 100` entsprechen. Im Beispiel: 395 / 957 × 100 ≈ 41 %, also ≈ 413 L.
8. In HA die verwaiste Entität `binary_sensor.ibc_wasser_zielcontainer_voll` entfernen.
9. Die neue Builder-YAML ins Repo übernehmen (`firmware/ibc-wasser.yaml`).

### Gegenprobe (empfohlen)

Bei einem anderen Wasserstand, etwa nach dem nächsten Regen oder einem Pumpenlauf, Schritte 2–3 wiederholen und `d + h` erneut bilden.
Weicht das um mehr als ~10 mm vom eingetragenen Leerwert ab, gibt es mehrere mögliche Ursachen. **Keine davon ist geprüft:**
- Der IBC-Boden ist nicht eben. Viele IBC haben ein Gefälle zum Auslass, dann hängt `h` vom Messort ab.
- Echos von Steigrohr, Wellschlauch oder Wand, weil der Schallkegel 60° breit ist.
- Der Zollstock wurde schräg gehalten.

### Hinweise

- Das reale Volumen eines „1000-l“-IBC wurde **nicht** nachgemessen. Stimmt der Literwert nicht, `volumen_l` anpassen. Der %-Wert bleibt davon unberührt.
- Bei fast leerem Container sind wegen des 60°-Kegels **Wandechos** möglich. Werte unter ~10 % mit Vorsicht lesen.
- Die Pumpenlogik nutzt nur % (Schwellen 70/90/97 %). Ein Fehler im Leerwert verschiebt diese Schwellen.

---

## 2. Knoten B: Akkuspannung abgleichen (ADC-Faktor)

**Hintergrund:** Der D1 mini hat an A0 intern einen Teiler 220 kΩ / 100 kΩ, der ADC-Endwert liegt bei 1,0 V. Davor sitzen 100 kΩ + 22 kΩ in Reihe, gemessen zusammen **121,5 kΩ**.

```
adc_faktor (theoretisch) = (R_vor + 220k + 100k) / 100k
                         = (122 + 220 + 100) / 100 = 4,42          (in der Firmware)
                         = (121,5 + 220 + 100) / 100 = 4,415       (mit gemessenem R_vor)
Messbereich ≈ 4,42 V
```

Die internen Widerstände des D1 mini haben Toleranzen. Deshalb wird gegen ein Multimeter abgeglichen.

### Schritt für Schritt

1. Voraussetzungen: Der Akku hat den Selbstentladetest bestanden (Abschnitt 4), Shield-5V/GND hängt am D1 mini, **kein USB am D1 mini**.
2. In HA `IBC B wach halten` **ein**schalten und auf das nächste Aufwachen warten. Nach Einstecken oder Reset ist er ohnehin 10 min wach.
3. Mit dem Multimeter die Spannung **am Halterkontakt Akku+ gegen GND** messen: `U_mm`.
4. Gleichzeitig in HA `sensor.ibc_b_akku` ablesen: `U_ha`. Er wird im Wachzustand alle 60 s aktualisiert.
5. Neuer Faktor:
   ```
   adc_faktor_neu = adc_faktor_alt × U_mm / U_ha
   Beispiel: 4,42 × 3,95 / 4,01 = 4,354
   ```
6. Im Builder `adc_faktor` in `ibc-b` ändern → OTA (solange „wach halten“ an ist).
7. Kontrolle nach dem Neustart, dann „wach halten“ **aus**schalten.

### Akku-Ladung (%)

Die Firmware rechnet grob linear: `% = (U − 3,3) / (4,15 − 3,3) × 100`, begrenzt auf 0…100. Das ist nur ein Richtwert, denn die Li-Ion-Kennlinie ist nicht linear.

### Schwellen

| Spannung | Wirkung |
|---|---|
| < 3,4 V | Push „Akku schwach“ (HA) |
| < 3,3 V | Knoten schläft 2 h statt 15 min (Firmware) |
| 2,4 V | Tiefentladeschutz des Shields (DW01, laut Recherche) |
| 4,20 V | Ladeschluss TC4056 |

---

## 3. Knoten B: Schwimmer-Schaltrichtung

Ziel: **„öffnet bei Wasser“**. Ein offener Kontakt bedeutet dann voll **oder** Kabelbruch, und beides sperrt die Pumpe.

1. Am Schwimmerkörper ist ein Pfeil, er zeigt die Einbaulage. Um 180° gedreht kehrt sich die Schaltrichtung um.
2. Vor dem Einbau am Tisch prüfen: Knoten B wach halten, Schwimmer anschließen.
   - Klappschwimmer **hängt** (kein Wasser) → Kontakt muss **geschlossen** sein → `IBC B Zielcontainer voll` = **aus**.
   - Klappschwimmer **hochgeklappt** (Wasser) → Kontakt **offen** → nach 2 s **an**.
3. Stimmt es nicht, Schwimmer im Halter um 180° drehen. **Nicht** die Firmware invertieren, denn dann würde ein Kabelbruch als „leer“ gelesen.

Tischtest vom 08.10. (Drahtbrücke statt Schwimmer): Kurzschluss → aus (17:32:35), offen → an (17:32:40). Bestanden.

**Schaltpunkt:** Der Halter setzt das Gewindeloch 120 mm unter den Stutzenrand. Der Schwimmer schaltet etwa auf Lochhöhe *(ungefähr, nicht ausgemessen)*.

---

## 4. Akku-Selbstentladetest (vor dem Einbau)

Gilt für den E-Zigarettenakku. Er war tief entladen (2,78 V), wurde im linken Shield per Micro-USB beaufsichtigt geladen und ruht seitdem außerhalb des Shields.

| Zeitpunkt | Spannung |
|---|---|
| 07.10. ~21:05 (Ladebeginn) | 2,78 V |
| 08.10. 14:25 (Bezugswert, lose außerhalb des Shields) | **4,137 V** |
| 09.10. ~14:30 (Bewertung) | ≥ 4,09 V gut · 4,04–4,09 V grenzwertig · < 4,04 V aussortieren |

Vorher prüfen: Folie unbeschädigt, Aufdruck/Typ notieren. Li-Ion **nicht unter 0 °C laden**. Für den Winterbetrieb draußen ist das bislang nicht gelöst *(offen)*.

Fällt der Akku durch, kommt der EVE 18650-33V aus der reichelt-Bestellung am 02.11.

---

## 5. Pumpe: Normalleistung und Trockenlauf-Schwelle

1. Steckdose einstecken. Beim **ersten echten Lauf** (A gut gefüllt, Schlauch zu B offen) die Leistung `sensor.steckdose_ibc_wassercontainer_pumpe_power` nach ~1 min ablesen: `P_normal`.
2. Schwelle rechnen: `P_schwelle ≈ 0,6 × P_normal`, z. B. 350 W → 210 W.
3. In `ha/ibc-pumpe.yaml`, Automation `ibc_pumpe_sicherung`, `below: 20` durch `P_schwelle` ersetzen.
4. **Fördermenge prüfen:** Die Regel „nach 10 min weniger als 2 % gesunken → Sperre“ setzt mindestens ~2 l/min voraus, denn 2 % ≈ 20 l.
   Den Füllstand von A nach 10 min Laufzeit ablesen. Fördert die Pumpe nahe dieser Grenze, Schwelle oder Zeit anpassen.
5. Prüfen, ob A in 30 min (Laufzeitgrenze) von 90 % auf 70 % kommt, also ~200 l. Sonst greift jedes Mal die 30-min-Sperre.
