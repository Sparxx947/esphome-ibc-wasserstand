🇬🇧 [English version](README.en.md)

# IBC-Wasserstand und Überlaufschutz (ESPHome + Home Assistant)

Füllstandsmessung für einen 1000-l-IBC-Regenwassercontainer mit Pumpensteuerung, damit er nicht überläuft.
Zwei ESPHome-Knoten auf Wemos D1 mini, die Pumpenlogik läuft in Home Assistant.

> **Stand: 13.10.2026.** Quellen: Projektnotizen (04.–13.10.2026), Firmware aus dem ESPHome Builder, SCAD-Dateien, Helfer und Automationen aus Home Assistant (gelesen 13.10.2026).
> Was nicht gemessen oder bestätigt ist, steht als *(ungeprüft)* oder *(Annahme)* im Text.

> **Nachbauen:** Die Dateien bilden eine konkrete Anlage ab. Vor eigener Verwendung:
> - Eigene `secrets.yaml` aus [`firmware/secrets.example.yaml`](firmware/secrets.example.yaml) anlegen (WLAN, API-Schlüssel, Fallback-AP-Passwörter).
> - In [`firmware/ibc-b.yaml`](firmware/ibc-b.yaml) unter `manual_ip` eine eigene feste IP eintragen (IP, Gateway, Subnetz, DNS) oder den `manual_ip`-Block entfernen, dann gilt DHCP.
> - In [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml) die Entitäten-IDs an die eigene Anlage anpassen (Pumpen-Steckdose, Leistungssensor, ESPHome-Entitäten) und `notify.mobile_app_dein_handy` durch den eigenen Notify-Dienst ersetzen.
>   Die Datei ist der ursprüngliche Paketentwurf. Die laufende Fassung weicht davon ab (UI-Automationen, zwei zusätzliche Helfer), siehe Abschnitt 8.
> - `abstand_leer_mm` / `abstand_voll_mm` (Knoten A) und `adc_faktor` (Knoten B) selbst einmessen, siehe [`docs/einmessen.md`](docs/einmessen.md).

---

## 1. Kurzbeschreibung

**Aufbau vor Ort:** Drei IBC-Container (je 1000 l, auf Palette) stehen ebenerdig draußen unter einem Dach.

| Container | Rolle | Was dort sitzt |
|---|---|---|
| **A** | Sammelbehälter. Zulauf von oben über ein HT-Rohr DN50 (Regenrinne) | Tauchpumpe mittig am Boden (Steigrohr ragt aus dem Einfüllstutzen), **Knoten A `ibc-wasser`** mit Ultraschallsensor auf der Oberseite |
| **B** | Zielbehälter, 2–3 m höher angefahren | **Knoten B `ibc-b`** (Solar, Tiefschlaf) mit Schwimmerschalter im Einfüllstutzen |
| **C** | Zielbehälter | unten per Schlauch mit B verbunden, steht daher gleich hoch wie B, braucht keinen eigenen Sensor |

**Prinzip:**

1. **Knoten A** misst mit einem wasserdichten Ultraschallsensor (A02YYUW, UART) von oben den Abstand zur Wasseroberfläche
   und rechnet daraus Füllstand in % und Inhalt in Litern. Ein IBC ist annähernd ein Quader, deshalb ist die Umrechnung linear
   (≈ 10 l pro cm).
2. **Knoten B** meldet über einen Schwimmerschalter, ob B/C voll sind. Er läuft auf einem 18650-Akku mit kleinem Solarpanel,
   wacht alle 15 min auf und bleibt wach, solange die Pumpe läuft.
3. **Home Assistant** schaltet die vorhandene Pumpe in A über eine Zigbee-Steckdose mit Leistungsmessung:
   an bei A ≥ 90 %, aus bei A ≤ 70 %, sofort aus bei „Ziel voll“. Dazu kommen Sicherungen gegen Trockenlauf, zu lange Laufzeit,
   Ausfall der Sensoren und ein stummer Knoten B.

**Ausfallrichtung:** Ein offener Schwimmereingang, also auch ein abgerissenes Kabel, gilt als „Ziel voll“ und sperrt die Pumpe.
Meldet sich Knoten B nicht, startet die Pumpe nicht. Nach einem Stromausfall bleibt die Steckdose aus.

---

## 2. Status (Stand 13.10.2026)

| Bereich | Status | Datum / Hinweis |
|---|---|---|
| Ultraschallsensor A02YYUW | ✅ geliefert, am Tisch getestet (Zimmerdecke 1,37–1,47 m, Hand sofort erkannt) | 06.10. |
| Knoten A geflasht, im Builder und in HA | ✅ fertig | 06.10. ~20:15 |
| Kombi-Gehäuse A (Sensor + D1 mini) | ✅ gedruckt (2. Fassung, siehe Abschnitt 5) | 07.10. |
| Kabelverschraubungen M12 | ✅ mit Heißkleber eingeklebt | bis 11.10. |
| Montage A auf dem IBC | ✅ montiert | 10.10. |
| Einmessen A (Leer-Wert noch geschätzt) | ⬜ offen | bis 22.10. |
| Schwimmer-Eingang aus Firmware A entfernen | ✅ entfernt und per OTA geflasht | 10.10. |
| Neustart-Diagnose A (`debug`: Neustart-Grund, freier Speicher) | ✅ geflasht; A startete bis dahin ~1×/h neu, Ursache offen | 11.10. |
| Neustarts A ausgewertet | ✅ 14 echte Neustarts in ~20 h (11.10. 16:57 – 12.10. 13:15), alle „Hardware Watchdog“; das WLAN-Signal erklärt die Häufung nicht | 12.10. |
| Netzteil-Gegenprobe A | 🔄 Netzteil getauscht 13.10. 17:47, A ab 17:48:20 wieder online (Grund „External System“ = Einschalten); **Ergebnis offen**, Auswertung 14.10. 18:00 | 13.10. |
| Pumpen-Steckdose (Nous Zigbee) | ✅ in HA, Power-outage-memory = off; eingesteckt und erreichbar (13.10.), Pumpe lief darüber noch nie | 07.10. / 13.10. |
| Knoten B geflasht (feste IP), im Builder und in HA | ✅ fertig, „wach halten“/Tiefschlaf getestet | 07.10. ~21:30–21:45 |
| Knoten B Innenverdrahtung (D0–RST, A0-Teiler, Schwimmer) | ✅ fertig, Tischtest Schwimmer bestanden | 08.10. 17:32 |
| Schwimmerhalter B | ✅ gedruckt | 08.10. |
| Gehäuse B | ✅ gedruckt, Knoten B eingebaut | 10.10. |
| Knoten B am Standort | ✅ verbaut, meldet im ~15-min-Takt; mit fester IP keine Aussetzer mehr (vorher mit DHCP ~10 %) | 11.10. |
| Aussetzer B mit fester IP | ✅ 0 von ~121 Weckvorgängen verloren (11.10. 13:12 – 12.10. 18:06, Takt 14,3 min) | 12.10. |
| Schwimmertest B am Standort | ✅ bestanden: zwei Durchgänge, „Zielcontainer voll“ jeweils sofort an und wieder aus, kein Prellen | 12.10. 18:21–18:23 |
| Deckeldichtung B (TPU) | ✅ konstruiert, Kollision geprüft; ⬜ nicht gedruckt | 09.10. |
| Deckelschrauben B 3 × 12 | ⬜ fehlen, kaufen | — |
| Akku B | ✅ E-Zigarettenakku, Selbstentladetest bestanden (im Betrieb 4,12 V) | 11.10. |
| Solarpanel, Z-Diode, EVE-Akku, Panelkabel | ⬜ nicht bestellt, reichelt-Bestellung geplant | 02.11. |
| Pumpenlogik in HA | ✅ **aktiv** seit 12.10. ~18:45 als UI-Helfer + 10 UI-Automationen (Abschnitt 8); ⬜ im echten Pumpenlauf **noch ungetestet** | 12.10. |
| Pumpen-Normalleistung, Trockenlauf-Schwelle | ✅ Probelauf 14.10.: **175 W** normal → Schwelle **105 W** (Helfer). Leistung bei echtem Trockenlauf ungemessen | — |

---

## 3. Stückliste

Preise und Artikelnummern nur dort, wo sie in den Notizen belegt sind. „—“ = nicht notiert.

### Knoten A (`ibc-wasser`, Container A)

| Teil | Menge | Bezeichnung / Typ | Bezugsquelle, Art.-Nr., Preis | Status |
|---|---|---|---|---|
| Mikrocontroller | 1 | Wemos D1 mini V3.0.0 (ESP8266, USB-Seriell CH340) | Bestand (früheres WLAN-Testgerät) | vorhanden, geflasht |
| Ultraschallsensor | 1 | A02YYUW-Typ, UART 9600, 3–450 cm, wasserdicht (IP67), 60° Abstrahlwinkel; Rechteckgehäuse 84,6 × 29,6 × 18,5 mm (Datenblatt DFRobot SEN0311), Kabel ~32 cm mit JST-PH-Stecker | Amazon B0CM1F4KFS, 21,95 € | geliefert 06.10. |
| Gehäuse + Deckel | 1 + 1 | `ibc_kombi_gehaeuse.stl` + `ibc_kombi_deckel.stl` | Eigendruck, PETG | gedruckt 07.10. |
| Kabelverschraubung | 2 | M12, Klemmbereich 3–6,5 mm, IP67, schwarz (Seki, 10er-Pack, für A und B) | Amazon B083V8V9TR, 5,49 € / 10 Stk | bestellt, Lieferung 09.10. |
| Blechschrauben Befestigung | 4 | Edelstahl 4,2 × 16 (im IBC 3,2 mm vorbohren) | — | *ungeklärt* |
| Blechschrauben Deckel | 4 | 3 × 16 | — | *ungeklärt* |
| Dichtband | 1 | zwischen Flansch und IBC-Oberseite | — | *ungeklärt* |
| Silikon | etwas | Raupe unter dem Sensor und im Kabelschlitz der Trennwand | — | *ungeklärt* |
| Heißkleber | etwas | Gegenmuttern der M12-Verschraubungen innen sichern | — | vorhanden *(Annahme)* |
| Stromversorgung | 1 | langes USB-Kabel, an 5V/G des D1 mini angelötet, plus USB-Netzteil | — | *ungeklärt* |
| Kabelbinder | einige | optional zusätzlich an der Käfigstrebe | — | — |

### Knoten B (`ibc-b`, Container B)

| Teil | Menge | Bezeichnung / Typ | Bezugsquelle, Art.-Nr., Preis | Status |
|---|---|---|---|---|
| Mikrocontroller | 1 | Wemos D1 mini (ESP8266, CH340) | Bestand | vorhanden, geflasht |
| Akku-Shield | 1 | „18650 Battery Shield V3“, **rechte Ausführung** (Input-Buchse U1 nicht bestückt, Diode SS24 vorhanden). Bestückung vermutlich TC4056A + DW01/8205 + FP6298 *(nach Layout abgeleitet, Aufdrucke unlesbar)* | Bestand | vorhanden, Polung geprüft |
| Akku (Variante 1) | 1 | 18650 aus einer E-Zigarette, vermutlich ungeschützte Hochstromzelle | Bestand | im Selbstentladetest bis 09.10. |
| Akku (Variante 2) | 1 | EVE 18650-33V, Flat-Top | reichelt, 6,82 € | nicht bestellt (02.11.) |
| Solarpanel | 1 | Seeed DEBO SOLAR 1.0W, 5,5 V / ~170 mA, **Leerlauf bis 8,2 V** | reichelt, 6,20 € (lieferbar ab 23.10.) | nicht bestellt (02.11.) |
| Z-Diode | 2 (1 + Reserve) | BZX 85C6V2, 6,2 V / 1,3 W | reichelt, 0,06 €/Stk | nicht bestellt (02.11.) |
| Panelkabel | ~3 m | H05RN-F 2 × 0,75 mm² (außen) | reichelt, — | nicht bestellt (02.11.) |
| Widerstände | 2 | 100 kΩ + 22 kΩ in Reihe (gemessen zusammen 121,5 kΩ) | Sortiment | eingebaut 08.10. |
| Drahtbrücke | 1 | D0 (GPIO16) → RST, für den Tiefschlaf | — | eingebaut 08.10. |
| Schwimmerschalter | 1 | seitlicher Einbau-Schwimmer mit Klappschwimmer (Reed, 2 Adern, ~3 mm Kabel), Gewinde Ø 19 mm × 19,5 mm, Dichtring + Mutter; Pfeil am Körper = Einbaulage | Bestand | vorhanden |
| Schwimmerhalter | 1 | `ibc_schwimmer_halter.stl` | Eigendruck, PETG | gedruckt 08.10. |
| Gehäuse + Deckel | 1 + 1 | `ibc_b_gehaeuse.stl` + `ibc_b_deckel.stl` (außen 130 × 74 × 32 mm + Laschen) | Eigendruck, PETG | gedruckt, Knoten B eingebaut (10.10.) |
| Kabelverschraubung | 2 | M12 aus dem Seki-Pack (s. o.): Schwimmer + Panel | s. o. | bestellt |
| Schrauben Deckel | 4 | 3 × 12, Blech- **oder** Spanplattenschraube (beißt in PETG-Dome mit 2,5-mm-Loch), Edelstahl A2 oder verzinkt | — | fehlen, kaufen |
| Deckeldichtung | 1 | `ibc_b_dichtung.stl`, TPU 95A (~2,8 g). Alternative: selbstklebendes EPDM-Moosgummiband ~3 mm breit, 2–3 mm dick | Eigendruck | konstruiert 09.10., nicht gedruckt |
| Klemme innen | 1 | Schraubklemme/Stecker für Schwimmer und Panel (Verlängerung innen im Gehäuse, nicht draußen) | — | offen |
| Befestigung | — | Kabelbinder (bis 5 mm) oder Schraube 4 mm durch die Laschen an den Käfig | — | — |
| Externe Antenne | — | erst, wenn der WLAN-Test am Standort schlecht ist (Reserve: D1 mini Pro mit Antennenbuchse) | — | bewusst nicht gekauft |

### Pumpe, Steckdose, Sonstiges

| Teil | Menge | Bezeichnung / Typ | Bezugsquelle, Preis | Status |
|---|---|---|---|---|
| Pumpe | 1 | vorhandene Tauchpumpe in A, Steigrohr → Edelstahl-Wellschlauch → Kugelhahn → Gartenschlauch zu B/C. Typ/Leistung **unbekannt** | Bestand | vorhanden |
| Zigbee-Steckdose | 1 | Nous Smart Plug mit Leistungsmessung (Zigbee2MQTT). **Innengerät** → unter Dach bzw. in Schutzbox | Bestand | vorhanden, eingesteckt (13.10.) |
| Verbindung B ↔ C | 1 | Schlauch unten zwischen B und C | Bestand | vorhanden |
| Multimeter | 1 | UNI-T UT139C (µA-Bereich, für Ruhestrom und ADC-Abgleich) | Amazon B00KKLW35O, 49,50 € | bestellt, Lieferung 09.10. |
| Filament | — | PETG (ASA bei direkter Sonne) | Bestand | vorhanden |

> Die alternative 4× Hilpress ECO 50010 aus dem ersten reichelt-Korb ist durch das Seki-Pack ersetzt.
> Die Farbe der Seki-Lieferung ist unsicher: Der Shop beschreibt auch die Variante „Schwarz“ als „grau (RAL7035)“.

---

## 4. Pinbelegung und Verdrahtung

### Knoten A (`ibc-wasser`)

| Von | Ader / Signal | D1 mini | GPIO | Hinweis |
|---|---|---|---|---|
| A02YYUW | rot, VCC | 3V3 | — | an 3,3 V liegt auch der TX-Pegel bei 3,3 V, also ESP-sicher |
| A02YYUW | schwarz, GND | G | — | |
| A02YYUW | weiß, TX (Sensor sendet) | D7 | GPIO13 | UART RX, 9600 Bd, Paket alle ~100 ms: `0xFF, Hi, Lo, Summe` |
| A02YYUW | gelb, RX / Modus | **frei lassen** | — | auf Masse schaltet der Sensor in einen anderen Ausgabemodus |
| USB-Netzteil | +5 V / GND | 5V / G | — | Kabel angelötet, durch eine M12-Verschraubung |
| ~~Schwimmer~~ | ~~2 Adern~~ | ~~D5 + G~~ | ~~GPIO14~~ | **entfällt**, der Schwimmer sitzt jetzt an Knoten B. Aus der Firmware entfernt (10.10.) |

Die Aderfarben stammen aus dem Werkstattbuch und sind gegen den gelieferten Sensor nicht gesondert dokumentiert. Vor dem Anlöten bitte nachsehen.

### Knoten B (`ibc-b`) – Schaltplan: [`plaene/ibc-b-schaltplan.pdf`](plaene/ibc-b-schaltplan.pdf)

| Von | Nach | Hinweis |
|---|---|---|
| Solarpanel + | Z-Diode Kathode (Ring) → Shield-Pads U1 **VBUS** | Z-Diode **parallel** zum Eingang. Vor dem Löten Foto der Pads machen und klären, welches Pad VBUS ist |
| Solarpanel − | Z-Diode Anode → Shield-Pads U1 **GND** | |
| Shield **5V** | D1 mini **5V** | **Nicht** den 3V-Ausgang des Shields nehmen (XC6206 ohne Ausgangskondensator, instabil) |
| Shield GND | D1 mini G | |
| Akku + (Halterkontakt, Draht angelötet) | 100 kΩ + 22 kΩ in Reihe → **A0** | mit dem internen Teiler 220k/100k des D1 mini ergibt sich ein Endwert von ~4,4 V und ein Dauerstrom von ~10 µA |
| D0 (GPIO16) | RST | Drahtbrücke für das Aufwachen aus dem Tiefschlaf |
| Schwimmer Ader 1 | D5 (GPIO14) | interner Pull-up |
| Schwimmer Ader 2 | G | |
| — | GPIO2 | blaue Status-LED auf dem Modul |

**Schaltlogik Schwimmer B:** eingebaut so, dass er **bei Wasser öffnet**. Geschlossen heißt „Wasser unten“, `Zielcontainer voll` = aus.
Offen heißt „B voll“ **oder** „Kabel ab“, `Zielcontainer voll` = an, die Pumpe ist gesperrt.

**Niemals D1-USB und Shield gleichzeitig anschließen.**

### Weitere Pläne

- [`plaene/ibc-messblatt.pdf`](plaene/ibc-messblatt.pdf) / `.html`: Messblatt vom 06.10. Es ist **teilweise überholt**: Es geht noch von einem runden
  Sensorkopf im Schraubdeckel und dem Schwimmer an A aus. Die Felder 4–6 (Einmessen) gelten weiter, sinngemäß für die neue Sensorstelle.
- [`plaene/ibc_b_plan.py`](plaene/ibc_b_plan.py): Quelle des Schaltplans B (matplotlib). Neu erzeugen mit `python3 ibc_b_plan.py ausgabe.pdf`.

---

## 5. Gehäuse

Quellen: [`gehaeuse/ibc-gehaeuse.scad`](gehaeuse/ibc-gehaeuse.scad) (A und Schwimmerhalter) und
[`gehaeuse/ibc-b-gehaeuse.scad`](gehaeuse/ibc-b-gehaeuse.scad) (Knoten B). In OpenSCAD `TEIL = "..."` setzen, F6, als STL exportieren.

| STL | Wofür | Status | Bemerkung |
|---|---|---|---|
| `ibc_kombi_gehaeuse.stl` | **A:** Sensor und D1 mini in einem Gehäuse, 111 × 99 × 28 mm inkl. Flansch | gedruckt 07.10. (2. Fassung) | zwei Kammern, Trennwand mit Kabelschlitz; Fenster 60 × 25 nach unten mit 45°-Aufweitung; 4 Löcher Ø 4,4 im Flansch; 2× M12 in der Außenwand der D1-Kammer; 2-mm-Kondenswasserloch |
| `ibc_kombi_deckel.stl` | Deckel zu A | gedruckt | Lippe gegen Schlagregen, 2 Druckrippen auf dem Sensorrücken (0,4 mm Vorspannung). Druck: Deckelplatte unten |
| `ibc_schwimmer_halter.stl` | **B:** hängt am Einfüllstutzen, trägt den Schwimmerschalter | gedruckt 08.10. | Steg 32 breit/5 dick, Haken über Stutzenwand 11,1 + 0,8 Luft, Loch Ø 19,5 in 120 mm Tiefe, Platte dort 6 mm; Kabelschlitze für Kabelbinder. Flach liegend drucken |
| `ibc_b_gehaeuse.stl` | **B:** Shield + D1 mini | gedruckt (10.10.) | außen 130 × 74 × 32 + Laschen, Wand 3 mm, 2× M12 in der **unteren** Stirnwand, Ablauf Ø 2,5, Leisten für Shield (99,28 × 29,46, USB 6,74, Höhe 25 – gemessen) und D1, Klemmleiste für die Widerstände |
| `ibc_b_deckel.stl` | Deckel zu B | gedruckt | Lippe, 4× Blechschraube 3 × 12. Druck: Deckelplatte unten |
| `ibc_b_dichtung.stl` | Deckeldichtung zu B (TPU) | konstruiert 09.10., nicht gedruckt | Rahmen 1,6 mm auf der 3-mm-Wandoberkante, Wulst 0,8 × 0,6 auf Wandmitte, 4 Eckohren Ø 7,4 mit Loch Ø 3,4 über den Domen. Druck: TPU 95A, liegend (Wulst oben), 100 % Füllung, ~20 mm/s |
| `ibc_sensor_halter.stl`, `ibc_sensor_abdeckung.stl` | Einzelhalter für den Sensor (Flansch 104 × 60) | **ersetzt** durch das Kombi-Gehäuse | nicht mehr drucken |
| `vorschau_ibc.png` | Vorschaubild | **veraltet** | zeigt noch den runden Flansch und die alte D1-Box |

Im SCAD stehen außerdem `d1_box`/`d1_deckel` (getrennte D1-Box). Sie sind durch das Kombi-Gehäuse ersetzt.

**Material und Druck:** PETG (ASA bei direkter Sonne), 0,2 mm Schicht, ohne Stützen. Der Standort ist draußen, aber überdacht.
Füllung und Wandzahl sind für IBC nicht notiert (bei der Optolink-Box waren es 3 Wände).

**Bestückung A:**
1. M12-Verschraubungen von außen eindrehen. Die Gegenmutter innen so weit wie möglich aufdrehen, die Fläche anrauen und entfetten, dann innen rundum mit Heißkleber sichern.
   Grund: Im gedruckten Teil ist die Wand an den Bohrungen 6,4 mm dick, und die Standard-Verschraubung fasst nur ~3 mm.
   Die aktuelle SCAD/STL hat innen eine Ø-22-Aussparung auf 3 mm Restwand. Bei einem Neudruck entfällt das Einkleben.
2. Sensor mit einer **Silikonraupe** auf den Auflagerand des Fensters setzen. Die Laschen bleiben frei, die Kabeltülle läuft durch den Schlitz der Trennwand, den Schlitz ebenfalls mit Silikon schließen.
   Das hält die feuchte Tankluft aus der D1-Kammer fern.
3. D1 mini auf die Auflageleisten der D1-Kammer, mit Doppelklebeband oder Heißkleber fixieren.
4. USB-Kabel durch eine Verschraubung, an 5V/G anlöten. Die zweite Verschraubung bleibt frei bzw. ist Reserve.
5. Deckel mit 4 Blechschrauben 3 × 16.

**Bestückung B:** Shield auf die Längsleisten (14 mm Mutterzone vor den Verschraubungen frei lassen), D1 mini daneben mit dem Antennenende **nach oben**, weg von Akku und Käfig.
Widerstände in die Klemmleiste. Schwimmer und Panel durch die beiden M12 unten, Verlängerungen nur innen an einer Klemme.
Einbaulage: hängend, Verschraubungen nach unten, Deckel nach vorn.

**Dichtung B:** TPU-Rahmen mit dem Wulst nach oben auf den Gehäuserand legen, Deckel darauf, die 4 Schrauben 3 × 12 über Kreuz
gleichmäßig anziehen, bis der Wulst gequetscht ist (nicht überdrehen, sonst reißen die Dome). Mit Deckel 2,4 mm und Dichtung ~2 mm
greift eine 12-mm-Schraube noch ~7,5 mm im Dom. Die Dichtung ist innen frei für die Deckellippe (0,35 mm Luft, an den Eckohren 0,3 mm).
Statt der gedruckten Dichtung geht auch selbstklebendes EPDM-Moosgummiband (~3 mm breit) auf der Wandoberkante.
**Kein essigvernetzendes Silikon** (Bad-Silikon) im Gehäuse: Es gast Essigsäure aus und lässt Kontakte korrodieren. Wenn Silikon,
dann neutralvernetzend und nur für Fugen, die zu bleiben (nicht den Deckel verkleben).

**Lehren aus der Konstruktion:**
- Der Sensor ist **kein** runder Kopf, sondern ein Rechteckgehäuse mit zwei Wandlern und zwei Laschen. Die anfängliche Annahme Ø 24,5 war falsch, die Halter wurden neu konstruiert.
- Ein Fenster für beide Wandler statt zweier Löcher: Dann spielt der Wandlerabstand keine Rolle.
- Vor dem STL-Export Kollisionen prüfen: Deckellippe gegen Trennwand (Aussparung nötig), Muttern gegen Wandstärke, Domschrauben gegen Lippe.
  Für die Dichtung B per Schnittmenge belegt (`TEIL = "pruef_gehaeuse"` / `"pruef_deckel"` exportieren und das Volumen messen):
  Gehäuse 0 mm³ (nur Berührung), Deckel nur der Wulst (~186 mm³ = gewollte Quetschung).
- Kreise, die eine Kante nur tangential berühren, ergeben ein nicht-manifoldes Netz (Slicer-Warnung). Deshalb überlappen die Eckohren 0,2 mm in die Wand.
  Beim Kombi-Gehäuse sind nur Berührflächen übrig.
- Wandstärke an Verschraubungen: Standard-M12 hat ~8–9 mm Gewinde, die Wand darf samt Mutter höchstens ~3 mm dick sein.
- Die Gewindelänge der Seki-Verschraubungen ist im Angebot nicht angegeben. Nach Lieferung messen, dann ggf. `k_m12_wand` im SCAD anpassen.

---

## 6. Firmware

| | Knoten A | Knoten B |
|---|---|---|
| Datei | [`firmware/ibc-wasser.yaml`](firmware/ibc-wasser.yaml) | [`firmware/ibc-b.yaml`](firmware/ibc-b.yaml) |
| Gerätename / Friendly | `ibc-wasser` / „IBC Wasser“ | `ibc-b` / „IBC B“ |
| Board | `d1_mini` (ESP8266) | `d1_mini` (ESP8266) |
| IP | 192.168.178.189 (DHCP, in der FRITZ!Box fest reserviert) | 192.168.178.196 (`manual_ip` in der YAML **und** in der FRITZ!Box reserviert) |
| Hostname | `ibc-wasser.local` | `ibc-b.local` |
| Fallback-AP | `IBC-Fallback` | `IBC-B-Fallback` (2 min Timeout) |
| Secrets | `wifi_ssid`, `wifi_password`, `ibc_api_key`, `ibc_ap_password` | `wifi_ssid`, `wifi_password`, `ibc_b_api_key`, `ibc_b_ap_password` |

Die Dateien in `firmware/` sind der Stand aus dem **ESPHome Builder**, und der Builder ist führend (abgeglichen 13.10.2026).
`abstand_voll_mm` steht seit 09.10. auch im Builder auf `50`; mit den OTA-Updates vom 10. und 11.10. ist der Wert auch auf dem Gerät.

### Wichtige Substitutions

**A (`ibc-wasser`)**

| Name | Wert | Bedeutung |
|---|---|---|
| `abstand_leer_mm` | `1050` (Platzhalter) | Abstand Sensor → Boden = 0 %. **Einmessen** |
| `abstand_voll_mm` | `50` | Abstand Sensor → höchster Stand = 100 %. 100 % = 50 mm unter der IBC-Oberseite, weil A keinen Überlauf hat |
| `volumen_l` | `1000` | Nennvolumen, lineare Umrechnung |

Filter: `filter_out: nan` → Median (Fenster 15, alle 10 Werte, erster nach 5) → `throttle: 30s`. Damit fallen einzelne Fehlechos von Wand oder Tropfen weg.

**B (`ibc-b`)**

| Name | Wert | Bedeutung |
|---|---|---|
| `schlaf` | `15min` | Tiefschlaf zwischen zwei Meldungen |
| `schlaf_akku_schwach` | `120min` | bei Akku < `akku_schwach_v` |
| `akku_schwach_v` | `3.3` | Schwelle für den Sparbetrieb |
| `adc_faktor` | `4.42` | (122k + 220k + 100k)/100k. Mit dem gemessenen 121,5 kΩ wären es 4,415. **Gegen Multimeter abgleichen** |
| `pumpe` | `switch.steckdose_ibc_wassercontainer_pumpe` | läuft die Pumpe, bleibt B wach |
| `wach_halten` | `input_boolean.ibc_b_wach_halten` | Helfer für OTA und Tests |
| `einrichtung_dauer` | `10min` | Einrichtungsfenster nach Strom/Reset (nicht nach Tiefschlaf) |
| `max_wach` | `3000` s | spätestens nach 50 min trotzdem schlafen |

Ablauf B: aufwachen → WLAN mit fester IP (`fast_connect`) → nach der API-Verbindung 3 s auf die Zustände von Pumpe und „wach halten“ warten →
Akku messen und melden → schlafen oder wach bleiben. Notbremse: `run_duration: 30s`, wenn HA nicht erreichbar ist. `reboot_timeout: 0s`.

### Entitäten in Home Assistant (geprüft 13.10.2026)

| Knoten | Entität | Bedeutung |
|---|---|---|
| A | `sensor.ibc_wasser_abstand_wasser` | Rohabstand in mm (Diagnose) |
| A | `sensor.ibc_wasser_fullstand` | Füllstand % |
| A | `sensor.ibc_wasser_inhalt` | Inhalt in L |
| A | `sensor.ibc_wasser_wlan_signal`, `sensor.ibc_wasser_laufzeit` | Diagnose |
| A | `sensor.garten_ibc_wasser_neustart_grund`, `sensor.garten_ibc_wasser_freier_speicher` | Diagnose (`debug`): Grund des letzten Neustarts, freier Heap. Präfix `garten_`, weil die Entitäten erst am 11.10. neu angelegt wurden |
| B | `binary_sensor.ibc_b_zielcontainer_voll` | an = Schwimmer offen = B voll oder Kabel ab |
| B | `sensor.ibc_b_akku` | Akkuspannung V, `force_update` = Lebenszeichen (`last_reported`) |
| B | `sensor.ibc_b_akku_ladung` | grob linear 3,3 V = 0 % … 4,15 V = 100 % |
| B | `sensor.ibc_b_wlan_signal`, `sensor.ibc_b_wach_seit` | Diagnose |
| HA | `input_boolean.ibc_b_wach_halten` | UI-Helfer (angelegt 07.10.), setzt seit 12.10. auch die Pumpenautomation |
| HA | `input_boolean.ibc_pumpe_gesperrt`, `input_datetime.ibc_pumpe_startzeit`, `input_number.ibc_a_stand_bei_pumpenstart`, `input_number.ibc_pumpe_trockenlauf_schwelle` | Helfer der Pumpenlogik (12.10.), siehe Abschnitt 8 |
| Zigbee | `switch.steckdose_ibc_wassercontainer_pumpe`, `sensor.steckdose_ibc_wassercontainer_pumpe_power` | Pumpe und Leistung |

### Secrets

`firmware/secrets.example.yaml` ist nur eine Vorlage. **Echte Werte stehen ausschließlich im ESPHome Builder** (`secrets.yaml`) und nie im Repo.
`.gitignore` schließt `secrets.yaml` und `secrets.*.yaml` aus. API-Schlüssel erzeugen: `openssl rand -base64 32`.

### Flashen

- **Normalfall: Builder, OTA.** YAML im Builder ändern → *Install* → *Wirelessly*.
  - Bei **B** vorher in HA `IBC B wach halten` einschalten und bis zum nächsten Aufwachen warten (max. 15 min, bei schwachem Akku bis 2 h).
    Danach wieder ausschalten, sonst bleibt B wach und leert den Akku.
- **Erstflash per USB** (am PC, Container `ghcr.io/esphome/esphome:<version>`), immer mit `esphome run <datei>.yaml --device /dev/ttyUSB0` **und den echten Secrets**.
  Im Log auf „Successfully compiled“ achten und danach per API mit dem echten Schlüssel gegenprüfen.
  Bei B: Klappt das Flashen per USB nicht, die D0–RST-Brücke kurz abziehen.
- ⚠️ **Falle:** **Nie einen Prüfbuild mit Dummy-Secrets flashen.** `esphome upload` kompiliert nicht neu, sondern nimmt blind den letzten Build aus `.esphome/`.
  So landeten am 06.10. bei einem anderen Projekt Dummy-Hotspot-Passwort und falscher API-Schlüssel auf dem Gerät. Prüfbuilds danach löschen.

---

## 7. Anleitungen

Die ausführlichen Schritt-für-Schritt-Anleitungen stehen in `docs/`:

| Anleitung | Inhalt |
|---|---|
| [`docs/einbau.md`](docs/einbau.md) | Aufbau, Inbetriebnahme am Tisch, Montage A und B vor Ort, Pumpe, Test |
| [`docs/einmessen.md`](docs/einmessen.md) | **Einmessen A** (leer/voll, Formeln, Builder), ADC-Abgleich B, Akkutest, Pumpen-Normalleistung und Trockenlauf-Schwelle, Schwimmer-Schaltrichtung |
| [`docs/fehlersuche.md`](docs/fehlersuche.md) | bekannte Fehlerbilder mit Ursache und Lösung |
| [`docs/verlauf.md`](docs/verlauf.md) | Projektverlauf 04.–13.10.2026 und Entscheidungen |

Kurzfassung Einmessen A (Details in `docs/einmessen.md`):

```
abstand_leer_mm = Sensorwert "Abstand Wasser" (mm) + Wassertiefe mit Zollstock an der Öffnung (mm)
abstand_voll_mm = 50                     (100 % = 50 mm unter der IBC-Oberseite)
Füllstand %     = (leer − Abstand) / (leer − voll) × 100     (auf 0…100 begrenzt)
Inhalt L        = Füllstand % / 100 × 1000
```

---

## 8. Home-Assistant-Anbindung

**Seit 12.10.2026 ~18:45 aktiv.** Die Logik läuft als **UI-Helfer und 10 UI-Automationen** (IDs `ibc_*`), weil diese HA-Installation keine
`packages:` nutzt. [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml) ist der ursprüngliche Paketentwurf und dient nur noch als **Referenz**; ihr Kopf listet die
Abweichungen der Live-Fassung. Push geht nur an Jens' Handy (`notify.mobile_app_dein_handy`).
**Probelauf 14.10. bestanden** (von Hand geschaltet, ~66 s): 175–176 W konstant, Förderung A → B sichtbar, A 46,3 → 45,4 %, „Pumpenlauf merken“ setzte Startzeit und Stand. Den automatischen Start bei A ≥ 90 % hat noch kein echter Lauf ausgelöst.

**Helfer**

| Helfer | Zweck |
|---|---|
| `input_boolean.ibc_pumpe_gesperrt` | Sperre nach Trockenlauf, 30 min Laufzeit oder „A sinkt nicht“. Nur von Hand lösen |
| `input_boolean.ibc_b_wach_halten` | hält Knoten B wach (schon seit 07.10. vorhanden); setzt jetzt auch die Pumpenautomation |
| `input_datetime.ibc_pumpe_startzeit` | Startzeit des laufenden Pumpenlaufs (neu ggü. Entwurf) |
| `input_number.ibc_a_stand_bei_pumpenstart` | Stand A beim Pumpenstart (im Entwurf `ibc_a_startstand`) |
| `input_number.ibc_pumpe_trockenlauf_schwelle` | Leistungsschwelle für Trockenlauf, **105 W** = 60 % von 175 W (Probelauf 14.10.; neu ggü. Entwurf) |

**Automationen (live, gelesen 13.10.2026)**

| Automation (ID) | Auslöser | Wirkung |
|---|---|---|
| `ibc_pumpe_ein` | A > 90 %, B meldet sich (`sensor.ibc_b_wach_seit` ändert sich), Sperre → aus, Ziel voll → aus | Wenn A > 90 %, Ziel nicht voll, keine Sperre, Pumpe aus: zuerst `IBC B wach halten` an; Pumpe an nur bei frischer B-Meldung (`sensor.ibc_b_akku` < 120 s alt), sonst beim nächsten Melden |
| `ibc_pumpe_lauf` | Pumpe aus → an / an → aus (auch von Hand) | an: Startzeit und Stand A merken. aus: `IBC B wach halten` aus, B darf schlafen |
| `ibc_pumpe_aus_normal` | A < 70 % | Pumpe aus |
| `ibc_pumpe_aus_ziel_voll` | Ziel voll → an | Lief die Pumpe: aus + Push. Immer: `IBC B wach halten` aus |
| `ibc_pumpe_sicherung` | jede Minute, solange die Pumpe läuft; Leistung unter dem Schwellen-Helfer für 20 s | Laufzeit ≥ 30 min, nach 10 min weniger als 2 % gesunken oder Leistung zu niedrig → aus + **Sperre** + Push mit Grund. Laufzeit aus `input_datetime`, nicht per `for:` |
| `ibc_sensor_ausfall` | Füllstand A 15 min `unavailable` | Pumpe aus + Push. Kurze Watchdog-Neustarts von A (Sekunden) lösen das nicht aus |
| `ibc_pumpe_aus_b_stumm` | Pumpe an und B > 180 s ohne Meldung bzw. Schwimmer `unavailable`/`unknown` | Pumpe aus + Push |
| `ibc_b_lebenszeichen` | B > 40 min still | Push (Pumpe startet so lange nicht) |
| `ibc_b_akku_schwach` | Akku B < 3,4 V | Push |
| `ibc_a_uebervoll` | A > 97 % für 2 min | Push (A hat keinen Überlauf) |

**Warum anders als im Entwurf:** Knoten B entscheidet nur ~1 s nach dem Melden, ob er wieder schläft. Der Entwurf hätte die Pumpe zwar beim
Melden gestartet, B aber schon wieder schlafen lassen. Deshalb setzt die EIN-Automation erst „wach halten“, und die Pumpe startet bei der
nächsten frischen Meldung. Die Laufzeit kommt aus einem `input_datetime`, damit ein HA-Neustart oder ein Funkaussetzer die 30-min-Grenze
nicht zurücksetzt *(Begründung aus der Planung, im Betrieb noch nicht beobachtet)*.

**Noch zu tun:**
1. ~~Probelauf~~ erledigt 14.10.: 175 W, Schwelle 105 W
   (siehe `docs/einmessen.md`). Prüfen, ob „Pumpenlauf merken“ Startzeit und Stand A setzt und ob A sichtbar sinkt.
2. Power-outage-memory der Steckdose muss `off` bleiben (geprüft 13.10.).

**Rückweg:** die Automationen `ibc_*` in HA deaktivieren; die Steckdose bleibt dann, wie sie ist (nach Stromausfall aus).

---

## 9. Offene Punkte, nächste Schritte, Termine

| Wann | Was | Wer |
|---|---|---|
| ~~Fr 09.10. 14:30~~ | ~~E-Zig-Akku Selbstentladetest~~ → erledigt: Akku steckt in B, meldet im Betrieb 4,11–4,15 V (11./12.10.) | Jens |
| offen | A0 von B gegen Multimeter abgleichen (`adc_faktor`) – bisher nicht gemacht | Jens |
| ~~—~~ | ~~WLAN-Test am Standort B~~ → erledigt durch den Betrieb: −60…−73 dBm, mit fester IP keine Aussetzer. Externe Antenne derzeit nicht nötig | — |
| ~~Mi 14.10. 17:30~~ | ✅ **Pumpe Probelauf erledigt:** 175 W, Schwelle 105 W, Förderung A → B sichtbar, Startzeit/Stand A gesetzt | — |
| **Mi 14.10. 18:00** | **Netzteil-Gegenprobe A auswerten:** Neustarts (`sensor.garten_ibc_wasser_neustart_grund`, Laufzeit) seit 13.10. 17:48:20 gegen 14 Watchdog-Neustarts in ~20 h mit altem Netzteil. 0–1 Neustarts → Netzteil war die Ursache | — |
| Sa 18.10. 12:00 | Akkutrend B nach einer Woche (Tagesmittel 11.–18.10., mV/Tag) → reicht der Akku über die Abwesenheit bis zum Panel? | — |
| bis 22.10. | A einmessen (Leer-Wert ist noch geschätzt) | Jens |
| **23.10.–01.11.** | **Jens nicht zu Hause.** Keine Lieferungen, keine Handgriffe. Die Pumpenlogik ist seit 12.10. aktiv; sie soll nur weiterlaufen, wenn der Probelauf vorher klappt. Sonst die Automationen `ibc_*` deaktivieren | — |
| Mo 02.11. 18:00 | reichelt bestellen: Seeed Solar 1 W, 2× BZX 85C6V2, EVE 18650-33V, H05RN-F 2 × 0,75 ~3 m. Vorher Preise und Lieferbarkeit neu prüfen (Stand 07.10. ~19–20 €) | Jens |
| nach Lieferung | Panel + Z-Diode an die U1-Pads (vorher Pad-Foto) | Jens |
| später | Schlafstrom über den Akkuspannungsverlauf in HA bewerten (keine µA-Messung geplant) | — |
| ~~offen~~ | ~~Länge des Schwimmerkabels~~ → erledigt: Schwimmer am Standort eingebaut und getestet (12.10.) | — |
| offen | Länge und Querschnitt des USB-Kabels von A (für die Neustart-Frage, falls das Netzteil es nicht war) | Jens |
| offen | Pumpentyp und Fördermenge (wichtig für die „10 min < 2 %“-Regel) | Jens |
| später, optional | zweiter A02YYUW für einen Füllstand in B (Konzept mit FireBeetle verworfen, zu teuer) | — |

---

## 10. Dateiübersicht

```
.
├── README.md                     diese Datei
├── README.en.md                  englische Fassung
├── .gitignore                    schließt secrets*.yaml, .esphome/, Backups aus
├── docs/                         jede Anleitung auch als <name>.en.md (Englisch)
│   ├── einbau.md                 Aufbau, Montage, Inbetriebnahme, Test
│   ├── einmessen.md              Kalibrieren A und B, Pumpenschwelle
│   ├── fehlersuche.md            bekannte Fehlerbilder
│   └── verlauf.md                Projektverlauf und Entscheidungen
├── firmware/
│   ├── ibc-wasser.yaml           Knoten A (Builder-Stand)
│   ├── ibc-b.yaml                Knoten B (Builder-Stand)
│   └── secrets.example.yaml      Vorlage, keine echten Werte
├── gehaeuse/
│   ├── ibc-gehaeuse.scad         Kombi-Gehäuse A, Schwimmerhalter, ältere Einzelteile
│   ├── ibc-b-gehaeuse.scad       Gehäuse Knoten B
│   ├── ibc_kombi_gehaeuse.stl    A – Gehäuse            (gedruckt)
│   ├── ibc_kombi_deckel.stl      A – Deckel             (gedruckt)
│   ├── ibc_schwimmer_halter.stl  B – Schwimmerhalter    (gedruckt)
│   ├── ibc_b_gehaeuse.stl        B – Gehäuse            (gedruckt)
│   ├── ibc_b_deckel.stl          B – Deckel             (gedruckt)
│   ├── ibc_b_dichtung.stl        B – Deckeldichtung TPU (konstruiert)
│   ├── ibc_sensor_halter.stl     ersetzt, nicht drucken
│   ├── ibc_sensor_abdeckung.stl  ersetzt, nicht drucken
│   └── vorschau_ibc.png          veraltete Vorschau
├── ha/
│   └── ibc-pumpe.yaml            Pumpenlogik als HA-Paket (Referenz, live als UI-Automationen)
├── plaene/
│   ├── ibc-b-schaltplan.pdf      Schaltplan Knoten B
│   ├── ibc_b_plan.py             Quelle des Schaltplans
│   ├── ibc-messblatt.pdf/.html   Messblatt 06.10. (teilweise überholt)
└── fotos/
    ├── ibc-sensorposition.jpg    vorgeschlagene Sensorstelle auf A (~35 cm zur Pumpe)
    ├── shield-vorderseite-kontakte.jpg
    └── shield-rueckseite-spule.jpg   Polungstest (+ piept an Spule 3R3)
```
