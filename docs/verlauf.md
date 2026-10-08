🇬🇧 [English version](verlauf.en.md)

# Projektverlauf und Entscheidungen

Zurück zur [README](../README.md). Zusammengefasst aus den Projektnotizen.

| Datum | Ereignis / Entscheidung |
|---|---|
| 04.10. | Idee: Füllstand A per Ultraschall + vorhandener Schwimmer als „Ziel voll“. Sensor A02YYUW bestellt (JSN-SR04T verworfen, oben ~20–25 cm blind). Geklärt: 3 Container ebenerdig, Weg zu B/C 2–3 m hoch → vorhandene Pumpe. Pumpe über freie Zigbee-Steckdose mit Leistungsmessung. Firmware A und HA-Paket entworfen und kompiliert (RAM 38,7 %, Flash 40,5 %) |
| 06.10. | Sensor geliefert. D1 mini als `ibc-wasser` geflasht (.189, feste Zuordnung in der FRITZ!Box), im Builder und in HA. Messblatt gedruckt |
| 07.10. nachm. | Sensor vermessen: **Rechteckgehäuse**, kein runder Kopf → Halter neu. Lage in A geklärt: Pumpe mittig im Stutzen, HT-Rohr im Stutzen → Sensor **neben** die Öffnung auf die Oberseite. A hat keinen Überlauf → 100 % = 50 mm unter Oberseite. Sensorkabel nur ~32 cm → **Kombi-Gehäuse** Sensor + D1 |
| 07.10. | Pumpen-Steckdose gefunden (Nous, Z2M), Power-outage-memory → off. B und C sind unten verbunden → **ein** Schwimmer in B reicht. B ist zu weit von A → **eigener Knoten**, Wunsch Solar + Akku |
| 07.10. | Teure Variante (FireBeetle 2 ESP32-C5 + Panel + Zellen, ~87 €) abgelehnt („muss billiger gehen“). **Spar-Variante:** vorhandener D1 mini + vorhandenes 18650 Battery Shield V3 (rechtes, ohne U1-Buchse) + 1-W-Panel + Z-Diode. Kein Schwimmer-Wecken; dafür startet HA die Pumpe nur bei frischer B-Meldung, und B bleibt wach, solange die Pumpe läuft |
| 07.10. | Schwimmer vermessen (Gewinde 19, Stutzenwand 11,1, Schalthöhe 120), B bleibt ohne Deckel → Schwimmerhalter druckfertig. Shield-Polung an beiden Shields geprüft. Kombi-Gehäuse A **gedruckt** (2. Fassung, Wand an M12 6,4 mm) → Heißkleber statt Aussenken |
| 07.10. abends | Gehäuse B, Schaltplan B, Firmware B fertig. Knoten B **geflasht** (.196 fest), in HA aufgenommen, Helfer `ibc_b_wach_halten` angelegt, Test wach halten / Tiefschlaf ✔. ESPHome Builder lässt sich per API steuern. Amazon-Korb (Multimeter UT139C, M12) von Jens bestellt; reichelt-Rest auf **02.11.** verschoben (Abwesenheit 23.10.–01.11.) |
| 08.10. | E-Zig-Akku geladen, Bezugswert 4,137 V. 100 k + 22 k vorhanden. Schwimmerhalter **gedruckt**. Innenverdrahtung B fertig, Tischtest Schwimmer ✔ (17:32) |

## Verworfene Wege

| Idee | Warum nicht |
|---|---|
| Sensor im Schraubdeckel von A | Im Stutzen sitzen HT-Rohr und Pumpensteigrohr, beides im Schallkegel |
| Schwallrohr DN110 mit Sensor obendrauf | nicht nötig, weil die Oberseite neben der Öffnung eben und frei ist |
| Durch die IBC-Wand bohren (Schwimmer) | Hängehalter im Einfüllstutzen statt Bohrung |
| Zigbee-Türkontakt als Schwimmerknoten | Jens wollte einen Solar-ESP mit späterer Option auf einen Füllstand in B |
| FireBeetle 2 ESP32-C5/C6 | zu teuer (Gesamtkorb ~87 €) |
| 6-V-Panel | Leerlauf ~7,7 V > 6,5 V Shield-Eingang |
| Shield-3V-Ausgang für den D1 | XC6206 ohne Ausgangskondensator, instabil |
| µA-Messung des Schlafstroms | ersetzt durch Beobachtung des Akkuspannungsverlaufs in HA |
