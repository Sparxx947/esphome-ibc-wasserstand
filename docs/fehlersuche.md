🇬🇧 [English version](fehlersuche.en.md)

# Fehlersuche

Zurück zur [README](../README.md). Bekannte Fehlerbilder aus dem Projektverlauf (04.–08.10.2026). Was nur vorbeugend beschrieben ist, steht als *(vorbeugend)* da.

## Knoten A (`ibc-wasser`)

| Fehlerbild | Ursache | Lösung |
|---|---|---|
| `Zielcontainer voll` an A ist dauernd **an** | Der Schwimmereingang GPIO14 ist offen (interner Pull-up). Der Schwimmer sitzt seit 07.10. an Knoten B | Den `binary_sensor`-Block aus der Builder-YAML A löschen und die verwaiste Entität in HA entfernen |
| Füllstand springt oder zeigt bei fast leerem Container Unsinn *(vorbeugend)* | 60°-Schallkegel: Echos von Wand, Steigrohr der Pumpe oder Wellschlauch | Stelle ≥ 30 cm von der Pumpe und ≥ 20 cm von der Wand; der Medianfilter (15) fängt Einzelechos ab |
| Kein Wert / `nan` bei sehr vollem Container | Der Sensor ist unter ~30 mm blind | 100 % liegt deshalb bei 50 mm. Ab 97 % kommt ein Push |
| Sensor liefert andere Daten / Werte nur auf Anforderung | Die gelbe Ader (RX/Modus) liegt auf Masse | gelb frei lassen |
| Füllstand stimmt nicht mit dem Zollstock überein | Leerwert falsch, Boden uneben *(ungeprüft)*, Zollstock schräg | neu einmessen, siehe [einmessen.md](einmessen.md) |
| Feuchtigkeit in der D1-Kammer *(vorbeugend)* | Tankluft durch den Kabelschlitz der Trennwand oder am Sensor vorbei | Silikonraupe unter dem Sensor und im Schlitz; 2-mm-Kondenswasserloch frei halten |
| Wasser am Sensorflansch | A ist randvoll, weil kein Überlauf vorhanden ist | Dichtband unter dem Flansch; HA meldet ab 97 % |
| Verschraubung fasst nicht | Die gedruckte Wand ist an den M12 6,4 mm dick (2. Fassung) | Mutter innen so weit es geht aufdrehen, mit Heißkleber sichern; oder innen Ø 22–25 aussenken; oder Neudruck der aktuellen STL (3 mm Restwand) |

## Knoten B (`ibc-b`)

| Fehlerbild | Ursache | Lösung |
|---|---|---|
| Knoten wacht nach dem Tiefschlaf **nie** auf | D0–RST-Brücke fehlt oder hat keinen Kontakt | Brücke prüfen; bis dahin hilft nur die Reset-Taste |
| Flashen per USB scheitert | Die D0–RST-Brücke stört den Auto-Reset | Brücke kurz abziehen |
| Knoten meldet sich nur alle 2 h | Akku < 3,3 V, oder A0 unbeschaltet (07.10.: 0,01 V) bzw. ohne Akku (08.10.: 0,41 V) | Akku/Teiler prüfen; nach Reset ist er 10 min wach |
| OTA-Update kommt nicht an | Der Knoten schläft | In HA `IBC B wach halten` an, bis zu 15 min (bzw. 2 h) warten, flashen, danach wieder **aus** |
| Akku leert sich schnell | „wach halten“ vergessen; Ruhestrom des Shields zu hoch (schlechte Charge mit SW6115/IP3005A: ~100 mA statt ~0,3 mA); Panel verschattet | Helfer aus; Akkuverlauf in HA ansehen; Shield tauschen; Panel reinigen und ausrichten |
| D1 mini startet unzuverlässig *(vorbeugend)* | vom 3V-Ausgang des Shields versorgt (XC6206 ohne Kondensator) | immer Shield **5V** → D1 **5V** |
| Shield-Eingang zerstört *(vorbeugend)* | Leerlaufspannung des Panels bis 8,2 V > 6,5 V Eingangsgrenze | Z-Diode 6,2 V parallel, Ring an + |
| Rauch/Wärme beim Akku-Einlegen *(vorbeugend)* | Halterpolung vertauscht (bekannter Layoutfehler dieser Shield-Serie) | vorher messen: + piept an Spule 3R3. Bei den beiden vorhandenen geprüft ✔ |
| Komisches Verhalten beim Testen | D1-USB und Shield gleichzeitig angeschlossen | **niemals** beides gleichzeitig |
| `Zielcontainer voll` = an, obwohl B leer ist | Schwimmerkabel ab/offen oder Schwimmer falsch herum eingebaut | Kabel prüfen; Pfeil am Schwimmer, um 180° drehen (Firmware **nicht** invertieren) |
| Hotspot-Passwort oder API-Schlüssel stimmt nach dem Flashen nicht | Ein Prüfbuild mit Dummy-Secrets wurde geflasht (`esphome upload` kompiliert nicht neu) | immer `esphome run` mit echten Secrets; danach API-Gegenprobe |
| Akku lädt im Winter nicht *(vorbeugend)* | Li-Ion darf unter 0 °C nicht geladen werden | offen. Der Lader hat laut Notizen keine Temperaturüberwachung *(nicht belegt)* |

## Pumpe / Home Assistant

| Fehlerbild | Ursache | Lösung |
|---|---|---|
| A > 90 %, aber Pumpe startet nicht sofort | **Absicht:** Start erst, wenn B sich frisch gemeldet hat (< 120 s), also beim nächsten Aufwachen (≤ 15 min) | abwarten; sonst Sperre, „Ziel voll“ und Lebenszeichen von B prüfen |
| Pumpe startet gar nicht mehr | `IBC-Pumpe gesperrt` ist an (nach Trockenlauf oder 30 min) | Ursache vor Ort ansehen, dann die Sperre **von Hand** ausschalten |
| Push „Pumpe gesperrt – Leistung zu niedrig“, obwohl alles gefördert hat | Die Schwelle `below: 20` ist noch ein Platzhalter | auf ~60 % der Normalleistung setzen |
| Push „A sinkt nicht“ | Leitung zu, Pumpe zieht Luft, Kugelhahn zu; oder die Pumpe fördert weniger als ~2 l/min | Leitung und Hahn prüfen; ggf. Regel anpassen |
| Push „Knoten B meldet sich nicht“ | Akku leer, WLAN, Knoten hängt im Tiefschlaf ohne D0–RST | Akku/Panel, WLAN-Signal, Reset |
| Pumpe läuft nach Stromausfall an *(vorbeugend)* | Power-outage-memory der Steckdose nicht `off` | auf `off` setzen (seit 07.10. so eingestellt) |
| Steckdose `unavailable` | Sie ist ausgesteckt (seit 07.10. 18:33), oder es gibt keinen Zigbee-Empfang | einstecken; Empfang am Standort prüfen |

## Bestellung / Teile

| Problem | Hinweis |
|---|---|
| Seki-M12 hat falsche Farbe | Die Angebote sind vertauscht: B083V943WD ist trotz „schwarz“ im Titel **grau**, gewählt wurde B083V8V9TR. Auch dort steht in der Beschreibung „grau (RAL7035)“, die Lieferung bitte prüfen |
| Lapp SKINTOP ST-M M12 dichtet das Schwimmerkabel nicht | Klemmbereich erst ab 3,5 mm, das Schwimmerkabel hat ~3 mm. Deshalb Typen mit 3–6,5 mm |
| Panel mit 6 V Nennspannung | ungeeignet (Leerlauf ~7,7 V). Nur 5-V-/5,5-V-Panels mit Z-Diode |
