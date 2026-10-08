🇬🇧 [English version](einbau.en.md)

# Aufbau, Inbetriebnahme, Einbau und Test

Zurück zur [README](../README.md). Stand 08.10.2026. Einmessen siehe [einmessen.md](einmessen.md).

---

## Teil A: Knoten `ibc-wasser` (Container A)

### A1. Aufbau am Tisch

1. Gehäuse vorbereiten: M12-Verschraubungen einkleben (siehe README Abschnitt 5, Bestückung A).
2. Sensor anschließen: rot → 3V3, schwarz → G, weiß → D7, **gelb frei**.
   Zum Testen gehen Jumperkabel in den JST-PH-Stecker (2 mm Raster), draußen besser anlöten.
   Das Sensorkabel ist nur ~32 cm lang, deshalb sitzt der D1 mini direkt daneben im Kombi-Gehäuse. Das Kabel **nicht** verlängern. Bei UART 9600 ginge es zwar über mehrere Meter, ist aber unnötig.
3. Stromkabel: langes USB-Kabel durch eine Verschraubung, Adern an **5V** und **G** anlöten.
4. Funktionstest am Tisch: einschalten, in HA `IBC Wasser Abstand Wasser` beobachten, Sensor gegen die Zimmerdecke halten.
   Beim Test am 06.10. ergab das 1,37–1,47 m, und eine Hand darunter wurde sofort erkannt.
5. Sensor mit Silikonraupe ins Fenster setzen, Kabelschlitz der Trennwand abdichten, D1 mini fixieren.
   Den Deckel erst nach dem Aushärten aufsetzen (4 × 3 × 16).

### A2. Stelle auf dem IBC

Foto mit Markierung: [`fotos/ibc-sensorposition.jpg`](../fotos/ibc-sensorposition.jpg)

- auf der IBC-**Oberseite neben** der Einfüllöffnung, **nicht** im Schraubdeckel. Dort sitzen das HT-Rohr DN50 und das Pumpensteigrohr
- vorderes Feld zwischen den beiden Längsstreben des Stahlkäfigs, links neben der senkrechten Mulde („Rinne meiden“), vor der Pressschrift
- Abstand **≥ 30 cm zur Pumpe** (aus dem Foto ~35 cm geschätzt) und **≥ 20 cm zur Seitenwand**, wegen des 60°-Schallkegels
- die Stelle ist eben (Jens, 07.10.). Platzbedarf auf dem IBC ~111 × 99 mm. Ob das zwischen die Streben passt, hat Jens gemessen, ein Ergebnis ist **nicht notiert**

### A3. Montage

1. Mit dem Gehäuse als Schablone das **Fenster unten (68 × 33)** anzeichnen und einen Ausschnitt **70 × 35 mm** in die IBC-Oberseite schneiden.
   Späne aus dem Container fischen.
2. Die 4 Flanschlöcher anzeichnen, im IBC **3,2 mm vorbohren**.
3. **Dichtband** unter den Flansch. Randvoll steht Wasser am Flansch an, und PE lässt sich schlecht kleben.
4. Mit **4 Edelstahl-Blechschrauben 4,2 × 16** festschrauben. Muttern wären innen nicht erreichbar.
5. Optional die Kabel mit Kabelbindern an der Käfigstrebe sichern. USB-Netzteil an eine Steckdose unter Dach.
6. Einmessen → [einmessen.md](einmessen.md), Abschnitt 1. Dabei den Schwimmer-Block aus der Firmware A entfernen.

---

## Teil B: Knoten `ibc-b` (Container B)

### B1. Stand der Innenverdrahtung (08.10.)

Fertig und getestet: D0–RST-Brücke, A0-Teiler (100 k + 22 k = 121,5 kΩ gemessen), Schwimmer an D5/G. Schaltplan: [`plaene/ibc-b-schaltplan.pdf`](../plaene/ibc-b-schaltplan.pdf).

### B2. Akku und Shield

1. Akku nur einsetzen, wenn er den Selbstentladetest bestanden hat ([einmessen.md](einmessen.md), Abschnitt 4).
2. Polung: Der Aufdruck am Halter stimmt bei **beiden** Shields. Geprüft am 07.10.: „+“ piept gegen die Spule 3R3, „−“ nicht.
   Bei dieser Platinenserie ist ein Layoutfehler mit vertauschter Halterpolung bekannt, bei einem anderen Shield deshalb erneut messen.
3. Akku einlegen, dann am Shield **5V/GND** und **3V/GND** messen und notieren.
4. Shield **5V → D1 5V**, **GND → G**. **Kein USB am D1 mini gleichzeitig.**
5. ADC-Abgleich → [einmessen.md](einmessen.md), Abschnitt 2.

### B3. Solarpanel (nach der Lieferung ab 02.11.)

1. Vor dem Löten ein **Foto der Pads der fehlenden USB-Buchse U1** machen und klären, welches Pad VBUS ist.
2. **Z-Diode BZX 85C6V2 parallel** an den Eingang, **Ring (Kathode) an +**.
   Grund: Das Panel liefert im Leerlauf bis 8,2 V, der Shield-Eingang verträgt laut Händler nur 6,5 V. Das Panel ist strombegrenzt, die Z-Diode wird nur bei vollem Akku und Sonne warm.
3. Panelkabel H05RN-F 2 × 0,75 (~2–3 m) durch die zweite M12-Verschraubung. Das Panel hängt **außen am Schuppen**.

### B4. Gehäuse und Montage

1. Gehäuse B drucken (`ibc_b_gehaeuse.stl` + `ibc_b_deckel.stl`).
2. Shield und D1 einsetzen (Antennenende nach oben), Widerstände in die Klemmleiste.
3. Schwimmer- und Panelkabel unten durch die M12. Reicht ein Kabel nicht, **innen** an einer Klemme verlängern, nicht draußen.
4. Gehäuse **senkrecht hängend** an den Käfig von B, Verschraubungen **nach unten**, Deckel nach vorn. Befestigung per Kabelbinder durch die Laschenschlitze oder Schraube 4 mm.

### B5. Schwimmer einbauen

1. Schwimmer in den Halter: Gewinde durch das 19,5-mm-Loch (Platte 6 mm), Dichtring, Mutter. Das Gewinde ist 19,5 mm lang, es bleiben ~11 mm Rest.
   **Pfeil beachten** → Schaltrichtung „öffnet bei Wasser“ ([einmessen.md](einmessen.md), Abschnitt 3).
2. Kabel mit Kabelbindern durch die Schlitze am Steg.
3. Den Halter mit dem Haken über den Rand des Einfüllstutzens von B hängen (Stutzenwand 11,1 mm, innen 220,3 mm). Der Schwimmer zeigt waagrecht ins Innere.
   **B bleibt ohne Deckel**, denn der äußere Hakenschenkel sitzt über dem Gewinde.

### B6. WLAN am Standort

Ein Außen-AP ist ~10 m Luftlinie entfernt. Bei Problemen vorher testen: D1 per Powerbank an B, `IBC B WLAN-Signal` beobachten. Am PC waren es −57 dBm, in HA zuletzt −55 bis −63.
Eine externe Antenne (bzw. ein D1 mini Pro) wird erst gekauft, wenn das Ergebnis schlecht ist.

---

## Teil C: Pumpe und Home Assistant

1. Nous-Zigbee-Steckdose unter Dach bzw. in einer Schutzbox, denn sie ist ein Innengerät. Power-outage-memory muss **off** bleiben.
2. Pumpe einstecken, Normalleistung messen ([einmessen.md](einmessen.md), Abschnitt 5).
3. `ha/ibc-pumpe.yaml` anpassen (Leistungsschwelle) und einspielen (README Abschnitt 8).

---

## Teil D: Abnahmetest

| # | Test | Erwartung |
|---|---|---|
| 1 | Füllstand A plausibel (Zollstock-Gegenprobe) | Abweichung ≤ ~1 % |
| 2 | Knoten B meldet regelmäßig | `sensor.ibc_b_akku` alle ~15 min neu (`last_reported`) |
| 3 | Schwimmer B hochklappen (von Hand) | „Zielcontainer voll“ an → bei laufender Pumpe sofort aus + Push. B ist dabei wach, weil die Pumpe läuft. Schläft B, wird das erst beim nächsten Aufwachen erkannt |
| 4 | Schwimmerkabel abziehen | „voll“ = an, Pumpe gesperrt |
| 5 | Pumpe von Hand starten, Knoten B stromlos machen | nach > 180 s ohne Meldung: Pumpe aus + Push |
| 6 | Laufzeitgrenze (in HA testweise `for` verkürzen) | nach Ablauf aus + Sperre + Push; Sperre nur von Hand lösen |
| 7 | Knoten A stromlos | nach 15 min: Pumpe aus + Push |
| 8 | Regulärer Lauf A ≥ 90 % → ≤ 70 % | Start beim nächsten B-Aufwachen, Stopp bei 70 %, B schläft danach wieder |
| 9 | Akkuverlauf B über einige Tage | kein stetiger Abfall bei Sonne. Sonst ist der Ruhestrom zu hoch, etwa durch eine schlechte Shield-Charge |

Tests 3–7 **vor** der Abwesenheit ab 23.10. durchführen, oder die Steckdose bis November ausgesteckt lassen.
