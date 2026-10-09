🇩🇪 [Deutsche Version](README.md)

# IBC water level and overflow protection (ESPHome + Home Assistant)

Level measurement for a 1000 l IBC (intermediate bulk container) used as a rainwater tank, with pump control so that it does not overflow.
Two ESPHome nodes on Wemos D1 mini boards; the pump logic runs in Home Assistant.

> **As of: 08.10.2026.** Sources: project notes (04.–08.10.2026), firmware from the ESPHome Builder, SCAD files, HA package draft.
> Anything not measured or confirmed is marked in the text as *(unverified)* or *(assumption)*.

> **Rebuilding this project:** The files reflect one specific installation. Before using them yourself:
> - Create your own `secrets.yaml` from [`firmware/secrets.example.yaml`](firmware/secrets.example.yaml) (Wi-Fi, API keys, fallback AP passwords).
> - In [`firmware/ibc-b.yaml`](firmware/ibc-b.yaml) set your own static IP under `manual_ip` (IP, gateway, subnet, DNS) or remove the `manual_ip` block to use DHCP.
> - In [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml) adjust the entity IDs to your installation (pump plug, power sensor, ESPHome entities) and replace `notify.mobile_app_dein_handy` ("your phone") with your own notify service.
> - Calibrate `abstand_leer_mm` / `abstand_voll_mm` (node A) and `adc_faktor` (node B) yourself, see [`docs/einmessen.en.md`](docs/einmessen.en.md).

---

## 1. Overview

**On-site setup:** Three IBC containers (1000 l each, on pallets) stand at ground level outdoors under a roof.

| Container | Role | What is located there |
|---|---|---|
| **A** | Collection tank. Inflow from above through an HT pipe DN50 (rain gutter) | Submersible pump in the middle on the bottom (riser pipe sticks out of the filler neck), **node A `ibc-wasser`** with ultrasonic sensor on the top surface |
| **B** | Target tank, fed 2–3 m higher | **Node B `ibc-b`** (solar, deep sleep) with float switch in the filler neck |
| **C** | Target tank | connected to B by a hose at the bottom, therefore at the same level as B, needs no sensor of its own |

**Principle:**

1. **Node A** uses a waterproof ultrasonic sensor (A02YYUW, UART) to measure the distance to the water surface from above
   and calculates the fill level in % and the content in litres from it. An IBC is approximately a cuboid, so the conversion is linear
   (≈ 10 l per cm).
2. **Node B** reports via a float switch whether B/C are full. It runs on an 18650 battery with a small solar panel,
   wakes up every 15 min and stays awake as long as the pump is running.
3. **Home Assistant** switches the existing pump in A via a Zigbee plug with power metering:
   on at A ≥ 90 %, off at A ≤ 70 %, immediately off on "target full". In addition there are safeguards against dry running, excessive run time,
   sensor failure and a silent node B.

**Fail-safe direction:** An open float input, i.e. also a torn cable, counts as "target full" and locks the pump.
If node B does not report, the pump does not start. After a power failure the plug stays off.

---

## 2. Status (as of 09.10.2026)

| Area | Status | Date / note |
|---|---|---|
| Ultrasonic sensor A02YYUW | ✅ delivered, bench-tested (room ceiling 1.37–1.47 m, hand detected immediately) | 06.10. |
| Node A flashed, in the Builder and in HA | ✅ done | 06.10. ~20:15 |
| Combined enclosure A (sensor + D1 mini) | ✅ printed (2nd revision, see section 5) | 07.10. |
| M12 cable glands | 🟡 ordered (Amazon), delivery Fri 09.10.; will be glued in with hot glue | 09.10. 18:00 |
| Mounting A on the IBC + calibration | ⬜ open | by 22.10. |
| Remove float input from firmware A | ⬜ open (during calibration) | — |
| Pump plug (Nous Zigbee) | ✅ in HA, power-outage memory = off; **currently unplugged** | 07.10. |
| Node B flashed (static IP), in the Builder and in HA | ✅ done, "keep awake"/deep sleep tested | 07.10. ~21:30–21:45 |
| Node B internal wiring (D0–RST, A0 divider, float) | ✅ done, bench test of float passed | 08.10. 17:32 |
| Float holder B | ✅ printed | 08.10. |
| Enclosure B | ⬜ ready to print, not yet printed | — |
| Lid gasket B (TPU) | ✅ designed, collision-checked; ⬜ not printed | 09.10. |
| Lid screws B 3 × 12 | ⬜ missing, to buy | — |
| Battery B | 🟡 e-cigarette battery in self-discharge test (reference 4.137 V) | evaluation 09.10. 14:30 |
| Solar panel, Zener diode, EVE battery, panel cable | ⬜ not ordered, reichelt order planned | 02.11. |
| HA pump package `ha/ibc-pumpe.yaml` | ⬜ draft, **not deployed** (no IBC automation exists in HA yet) | — |
| Normal pump power, dry-run threshold | ⬜ open, only measurable at the first pump run | — |

---

## 3. Bill of materials

Prices and part numbers only where documented in the notes. "—" = not noted.

### Node A (`ibc-wasser`, container A)

| Part | Qty | Designation / type | Source, part no., price | Status |
|---|---|---|---|---|
| Microcontroller | 1 | Wemos D1 mini V3.0.0 (ESP8266, USB serial CH340) | stock (former Wi-Fi test device) | available, flashed |
| Ultrasonic sensor | 1 | A02YYUW type, UART 9600, 3–450 cm, waterproof (IP67), 60° beam angle; rectangular housing 84.6 × 29.6 × 18.5 mm (datasheet DFRobot SEN0311), cable ~32 cm with JST-PH connector | Amazon B0CM1F4KFS, €21.95 | delivered 06.10. |
| Enclosure + lid | 1 + 1 | `ibc_kombi_gehaeuse.stl` + `ibc_kombi_deckel.stl` | self-printed, PETG | printed 07.10. |
| Cable gland | 2 | M12, clamping range 3–6.5 mm, IP67, black (Seki, pack of 10, for A and B) | Amazon B083V8V9TR, €5.49 / 10 pcs | ordered, delivery 09.10. |
| Self-tapping screws, mounting | 4 | stainless steel 4.2 × 16 (pre-drill 3.2 mm in the IBC) | — | *unresolved* |
| Self-tapping screws, lid | 4 | 3 × 16 | — | *unresolved* |
| Sealing tape | 1 | between flange and IBC top surface | — | *unresolved* |
| Silicone | some | bead under the sensor and in the cable slot of the partition wall | — | *unresolved* |
| Hot glue | some | secure the lock nuts of the M12 glands on the inside | — | available *(assumption)* |
| Power supply | 1 | long USB cable, soldered to 5V/G of the D1 mini, plus USB power adapter | — | *unresolved* |
| Cable ties | a few | optional, additionally on the cage strut | — | — |

### Node B (`ibc-b`, container B)

| Part | Qty | Designation / type | Source, part no., price | Status |
|---|---|---|---|---|
| Microcontroller | 1 | Wemos D1 mini (ESP8266, CH340) | stock | available, flashed |
| Battery shield | 1 | "18650 Battery Shield V3", **right-hand variant** (input jack U1 not populated, diode SS24 present). Components probably TC4056A + DW01/8205 + FP6298 *(derived from the layout, markings illegible)* | stock | available, polarity checked |
| Battery (variant 1) | 1 | 18650 from an e-cigarette, probably an unprotected high-drain cell | stock | in self-discharge test until 09.10. |
| Battery (variant 2) | 1 | EVE 18650-33V, flat top | reichelt, €6.82 | not ordered (02.11.) |
| Solar panel | 1 | Seeed DEBO SOLAR 1.0W, 5.5 V / ~170 mA, **open-circuit up to 8.2 V** | reichelt, €6.20 (available from 23.10.) | not ordered (02.11.) |
| Zener diode | 2 (1 + spare) | BZX 85C6V2, 6.2 V / 1.3 W | reichelt, €0.06/pc | not ordered (02.11.) |
| Panel cable | ~3 m | H05RN-F 2 × 0.75 mm² (outdoor) | reichelt, — | not ordered (02.11.) |
| Resistors | 2 | 100 kΩ + 22 kΩ in series (measured together 121.5 kΩ) | assortment | installed 08.10. |
| Wire jumper | 1 | D0 (GPIO16) → RST, for deep sleep | — | installed 08.10. |
| Float switch | 1 | side-mount float switch with hinged float (reed, 2 wires, ~3 mm cable), thread Ø 19 mm × 19.5 mm, sealing ring + nut; arrow on the body = mounting orientation | stock | available |
| Float holder | 1 | `ibc_schwimmer_halter.stl` | self-printed, PETG | printed 08.10. |
| Enclosure + lid | 1 + 1 | `ibc_b_gehaeuse.stl` + `ibc_b_deckel.stl` (outside 130 × 74 × 32 mm + tabs) | self-printed, PETG | ready to print, not printed |
| Cable gland | 2 | M12 from the Seki pack (see above): float + panel | see above | ordered |
| Screws, lid | 4 | 3 × 12, self-tapping **or** chipboard screw (bites into the PETG bosses with 2.5 mm hole), stainless A2 or zinc-plated | — | missing, to buy |
| Lid gasket | 1 | `ibc_b_dichtung.stl`, TPU 95A (~2.8 g). Alternative: self-adhesive EPDM foam tape ~3 mm wide, 2–3 mm thick | self-printed | designed 09.10., not printed |
| Terminal inside | 1 | screw terminal/connector for float and panel (extension inside the enclosure, not outside) | — | open |
| Mounting | — | cable ties (up to 5 mm) or 4 mm screw through the tabs onto the cage | — | — |
| External antenna | — | only if the Wi-Fi test at the location is poor (fallback: D1 mini Pro with antenna socket) | — | deliberately not bought |

### Pump, plug, miscellaneous

| Part | Qty | Designation / type | Source, price | Status |
|---|---|---|---|---|
| Pump | 1 | existing submersible pump in A, riser pipe → stainless-steel corrugated hose → ball valve → garden hose to B/C. Type/power **unknown** | stock | available |
| Zigbee plug | 1 | Nous smart plug with power metering (Zigbee2MQTT). **Indoor device** → under the roof or in a protective box | stock | available, currently unplugged |
| Connection B ↔ C | 1 | hose at the bottom between B and C | stock | available |
| Multimeter | 1 | UNI-T UT139C (µA range, for quiescent current and ADC calibration) | Amazon B00KKLW35O, €49.50 | ordered, delivery 09.10. |
| Filament | — | PETG (ASA in direct sun) | stock | available |

> The alternative 4× Hilpress ECO 50010 from the first reichelt basket has been replaced by the Seki pack.
> The colour of the Seki delivery is uncertain: the shop also describes the "black" variant as "grey (RAL7035)".

---

## 4. Pinout and wiring

### Node A (`ibc-wasser`)

| From | Wire / signal | D1 mini | GPIO | Note |
|---|---|---|---|---|
| A02YYUW | red, VCC | 3V3 | — | at 3.3 V the TX level is also 3.3 V, so ESP-safe |
| A02YYUW | black, GND | G | — | |
| A02YYUW | white, TX (sensor transmits) | D7 | GPIO13 | UART RX, 9600 baud, packet every ~100 ms: `0xFF, Hi, Lo, Summe` (sum) |
| A02YYUW | yellow, RX / mode | **leave unconnected** | — | pulled to ground, the sensor switches to a different output mode |
| USB power adapter | +5 V / GND | 5V / G | — | cable soldered on, through one M12 gland |
| ~~Float~~ | ~~2 wires~~ | ~~D5 + G~~ | ~~GPIO14~~ | **dropped**, the float now sits at node B. Still in the firmware and will be removed during calibration |

The wire colours come from the workshop notes and are not separately documented against the delivered sensor. Please check before soldering.

### Node B (`ibc-b`) – schematic: [`plaene/ibc-b-schaltplan.pdf`](plaene/ibc-b-schaltplan.pdf)

| From | To | Note |
|---|---|---|
| Solar panel + | Zener diode cathode (ring) → shield pads U1 **VBUS** | Zener diode **in parallel** with the input. Before soldering, take a photo of the pads and determine which pad is VBUS |
| Solar panel − | Zener diode anode → shield pads U1 **GND** | |
| Shield **5V** | D1 mini **5V** | Do **not** use the shield's 3V output (XC6206 without output capacitor, unstable) |
| Shield GND | D1 mini G | |
| Battery + (holder contact, wire soldered on) | 100 kΩ + 22 kΩ in series → **A0** | together with the D1 mini's internal 220k/100k divider this gives a full-scale value of ~4.4 V and a continuous current of ~10 µA |
| D0 (GPIO16) | RST | wire jumper for waking from deep sleep |
| Float wire 1 | D5 (GPIO14) | internal pull-up |
| Float wire 2 | G | |
| — | GPIO2 | blue status LED on the module |

**Float B switching logic:** mounted so that it **opens with water**. Closed means "water low", `Zielcontainer voll` (target container full) = off.
Open means "B full" **or** "cable detached", `Zielcontainer voll` = on, the pump is locked.

**Never connect D1 USB and the shield at the same time.**

### Further plans

- [`plaene/ibc-messblatt.pdf`](plaene/ibc-messblatt.pdf) / `.html`: measurement sheet from 06.10. It is **partly outdated**: it still assumes a round
  sensor head in the screw cap and the float at A. Fields 4–6 (calibration) still apply, analogously for the new sensor location.
- [`plaene/ibc_b_plan.py`](plaene/ibc_b_plan.py): source of schematic B (matplotlib). Regenerate with `python3 ibc_b_plan.py ausgabe.pdf`.

---

## 5. Enclosures

Sources: [`gehaeuse/ibc-gehaeuse.scad`](gehaeuse/ibc-gehaeuse.scad) (A and float holder) and
[`gehaeuse/ibc-b-gehaeuse.scad`](gehaeuse/ibc-b-gehaeuse.scad) (node B). In OpenSCAD set `TEIL = "..."` (part), press F6, export as STL.

| STL | Purpose | Status | Remark |
|---|---|---|---|
| `ibc_kombi_gehaeuse.stl` | **A:** sensor and D1 mini in one enclosure, 111 × 99 × 28 mm incl. flange | printed 07.10. (2nd revision) | two chambers, partition wall with cable slot; window 60 × 25 facing down with 45° flare; 4 holes Ø 4.4 in the flange; 2× M12 in the outer wall of the D1 chamber; 2 mm condensation drain hole |
| `ibc_kombi_deckel.stl` | lid for A | printed | lip against driving rain, 2 pressure ribs on the back of the sensor (0.4 mm preload). Print: lid plate down |
| `ibc_schwimmer_halter.stl` | **B:** hangs on the filler neck, carries the float switch | printed 08.10. | web 32 wide/5 thick, hook over neck wall 11.1 + 0.8 clearance, hole Ø 19.5 at 120 mm depth, plate 6 mm there; cable slots for cable ties. Print lying flat |
| `ibc_b_gehaeuse.stl` | **B:** shield + D1 mini | ready to print, **not printed** | outside 130 × 74 × 32 + tabs, wall 3 mm, 2× M12 in the **lower** end wall, drain Ø 2.5, rails for shield (99.28 × 29.46, USB 6.74, height 25 – measured) and D1, terminal strip for the resistors |
| `ibc_b_deckel.stl` | lid for B | ready to print | lip, 4× self-tapping screw 3 × 12. Print: lid plate down |
| `ibc_b_dichtung.stl` | lid gasket for B (TPU) | designed 09.10., not printed | frame 1.6 mm on the 3 mm wall top, bead 0.8 × 0.6 on the wall centre, 4 corner ears Ø 7.4 with Ø 3.4 hole over the bosses. Print: TPU 95A, flat (bead up), 100 % infill, ~20 mm/s |
| `ibc_sensor_halter.stl`, `ibc_sensor_abdeckung.stl` | separate holder for the sensor (flange 104 × 60) | **replaced** by the combined enclosure | do not print any more |
| `vorschau_ibc.png` | preview image | **outdated** | still shows the round flange and the old D1 box |

The SCAD also contains `d1_box`/`d1_deckel` (separate D1 box). They have been replaced by the combined enclosure.

**Material and printing:** PETG (ASA in direct sun), 0.2 mm layer height, no supports. The location is outdoors but roofed.
Infill and wall count are not noted for the IBC parts (for the Optolink box it was 3 walls).

**Assembly A:**
1. Screw in the M12 glands from the outside. Thread the lock nut on the inside as far as possible, roughen and degrease the surface, then secure all around on the inside with hot glue.
   Reason: in the printed part the wall at the holes is 6.4 mm thick, and the standard gland only grips ~3 mm.
   The current SCAD/STL has a Ø 22 recess on the inside leaving 3 mm of wall. With a reprint the gluing is no longer needed.
2. Set the sensor onto the support rim of the window with a **bead of silicone**. The tabs stay free, the cable grommet runs through the slot in the partition wall; seal the slot with silicone as well.
   This keeps the humid tank air out of the D1 chamber.
3. Place the D1 mini on the support rails of the D1 chamber, fix it with double-sided tape or hot glue.
4. USB cable through one gland, solder to 5V/G. The second gland stays free or is a spare.
5. Lid with 4 self-tapping screws 3 × 16.

**Assembly B:** Shield on the longitudinal rails (leave the 14 mm nut zone in front of the glands free), D1 mini next to it with the antenna end **facing up**, away from battery and cage.
Resistors into the terminal strip. Float and panel through the two M12 at the bottom, extensions only inside at a terminal.
Mounting orientation: hanging, glands facing down, lid facing forward.

**Gasket B:** Place the TPU frame on the enclosure rim with the bead facing up, put the lid on, tighten the 4 screws 3 × 12 evenly
crosswise until the bead is compressed (do not overtighten, the bosses can crack). With lid 2.4 mm and gasket ~2 mm a 12 mm screw
still grips ~7.5 mm in the boss. The gasket leaves the inside free for the lid lip (0.35 mm clearance, 0.3 mm at the corner ears).
Instead of the printed gasket, self-adhesive EPDM foam tape (~3 mm wide) on the wall top also works.
**No acetic-cure silicone** (bathroom silicone) inside the enclosure: it outgasses acetic acid and corrodes contacts. If silicone,
then neutral-cure and only for joints that stay closed (do not glue the lid shut).

**Lessons from the design:**
- The sensor is **not** a round head but a rectangular housing with two transducers and two tabs. The initial assumption of Ø 24.5 was wrong; the holders were redesigned.
- One window for both transducers instead of two holes: then the transducer spacing does not matter.
- Check for collisions before STL export: lid lip vs. partition wall (cut-out needed), nuts vs. wall thickness, boss screws vs. lip.
  In the combined enclosure only contact surfaces remain.
  For gasket B this is proven by intersection (export `TEIL = "pruef_gehaeuse"` / `"pruef_deckel"` and measure the volume):
  enclosure 0 mm³ (contact only), lid only the bead (~186 mm³ = intended compression).
- Circles that touch an edge only tangentially produce a non-manifold mesh (slicer warning), so the corner ears overlap 0.2 mm into the wall.
- Wall thickness at glands: a standard M12 has ~8–9 mm of thread; wall plus nut may be at most ~3 mm thick.
- The thread length of the Seki glands is not stated in the listing. Measure after delivery, then adjust `k_m12_wand` in the SCAD if necessary.

---

## 6. Firmware

| | Node A | Node B |
|---|---|---|
| File | [`firmware/ibc-wasser.yaml`](firmware/ibc-wasser.yaml) | [`firmware/ibc-b.yaml`](firmware/ibc-b.yaml) |
| Device name / friendly name | `ibc-wasser` / "IBC Wasser" | `ibc-b` / "IBC B" |
| Board | `d1_mini` (ESP8266) | `d1_mini` (ESP8266) |
| IP | 192.168.178.189 (DHCP, permanently reserved in the FRITZ!Box) | 192.168.178.196 (`manual_ip` in the YAML **and** reserved in the FRITZ!Box) |
| Hostname | `ibc-wasser.local` | `ibc-b.local` |
| Fallback AP | `IBC-Fallback` | `IBC-B-Fallback` (2 min timeout) |
| Secrets | `wifi_ssid`, `wifi_password`, `ibc_api_key`, `ibc_ap_password` | `wifi_ssid`, `wifi_password`, `ibc_b_api_key`, `ibc_b_ap_password` |

The files in `firmware/` are the state from the **ESPHome Builder**, and the Builder is the authoritative source.
A local working copy of A already has `abstand_voll_mm: "50"`. The Builder still has `80`; this will be updated during calibration.

### Important substitutions

**A (`ibc-wasser`)**

| Name | Value | Meaning |
|---|---|---|
| `abstand_leer_mm` | `1050` (placeholder) | distance sensor → bottom = 0 %. **Calibrate** |
| `abstand_voll_mm` | `80` (Builder), target `50` | distance sensor → highest level = 100 %. 100 % = 50 mm below the IBC top surface, because A has no overflow |
| `volumen_l` | `1000` | nominal volume, linear conversion |

Filter: `filter_out: nan` → median (window 15, every 10 values, first after 5) → `throttle: 30s`. This removes isolated false echoes from the wall or drops.

**B (`ibc-b`)**

| Name | Value | Meaning |
|---|---|---|
| `schlaf` | `15min` | deep sleep between two reports |
| `schlaf_akku_schwach` | `120min` | when battery < `akku_schwach_v` |
| `akku_schwach_v` | `3.3` | threshold for power-saving mode |
| `adc_faktor` | `4.42` | (122k + 220k + 100k)/100k. With the measured 121.5 kΩ it would be 4.415. **Calibrate against a multimeter** |
| `pumpe` | `switch.steckdose_ibc_wassercontainer_pumpe` | while the pump runs, B stays awake |
| `wach_halten` | `input_boolean.ibc_b_wach_halten` | helper for OTA and tests ("keep awake") |
| `einrichtung_dauer` | `10min` | setup window after power-on/reset (not after deep sleep) |
| `max_wach` | `3000` s | go to sleep after 50 min at the latest anyway |

Sequence B: wake up → Wi-Fi with static IP (`fast_connect`) → after the API connection wait 3 s for the states of pump and "keep awake" →
measure and report the battery → sleep or stay awake. Emergency brake: `run_duration: 30s` if HA is unreachable. `reboot_timeout: 0s`.

### Entities in Home Assistant (checked 08.10.2026)

| Node | Entity | Meaning |
|---|---|---|
| A | `sensor.ibc_wasser_abstand_wasser` | raw distance in mm (diagnostics) |
| A | `sensor.ibc_wasser_fullstand` | fill level % |
| A | `sensor.ibc_wasser_inhalt` | content in L |
| A | `sensor.ibc_wasser_wlan_signal`, `sensor.ibc_wasser_laufzeit` | diagnostics (Wi-Fi signal, uptime) |
| A | `binary_sensor.ibc_wasser_zielcontainer_voll` | **legacy**, disappears when the float is removed from firmware A |
| B | `binary_sensor.ibc_b_zielcontainer_voll` | on = float open = B full or cable detached |
| B | `sensor.ibc_b_akku` | battery voltage V, `force_update` = sign of life (`last_reported`) |
| B | `sensor.ibc_b_akku_ladung` | roughly linear 3.3 V = 0 % … 4.15 V = 100 % (battery charge) |
| B | `sensor.ibc_b_wlan_signal`, `sensor.ibc_b_wach_seit` | diagnostics (Wi-Fi signal, awake since) |
| HA | `input_boolean.ibc_b_wach_halten` | UI helper (created 07.10.) |
| Zigbee | `switch.steckdose_ibc_wassercontainer_pumpe`, `sensor.steckdose_ibc_wassercontainer_pumpe_power` | pump and power |

### Secrets

`firmware/secrets.example.yaml` is only a template. **Real values exist only in the ESPHome Builder** (`secrets.yaml`) and never in the repo.
`.gitignore` excludes `secrets.yaml` and `secrets.*.yaml`. Generate API keys with: `openssl rand -base64 32`.

### Flashing

- **Normal case: Builder, OTA.** Change the YAML in the Builder → *Install* → *Wirelessly*.
  - For **B**, first switch on `IBC B wach halten` (keep awake) in HA and wait until the next wake-up (max. 15 min, with a weak battery up to 2 h).
    Switch it off again afterwards, otherwise B stays awake and drains the battery.
- **First flash via USB** (on the PC, container `ghcr.io/esphome/esphome:<version>`), always with `esphome run <datei>.yaml --device /dev/ttyUSB0` **and the real secrets**.
  Watch for "Successfully compiled" in the log and afterwards verify via the API with the real key.
  For B: if flashing via USB does not work, briefly remove the D0–RST jumper.
- ⚠️ **Pitfall:** **Never flash a test build with dummy secrets.** `esphome upload` does not recompile but blindly takes the last build from `.esphome/`.
  That is how, on 06.10. in another project, a dummy hotspot password and a wrong API key ended up on the device. Delete test builds afterwards.

---

## 7. Guides

The detailed step-by-step guides are in `docs/`:

| Guide | Content |
|---|---|
| [`docs/einbau.en.md`](docs/einbau.en.md) | Assembly, bench commissioning, mounting A and B on site, pump, test |
| [`docs/einmessen.en.md`](docs/einmessen.en.md) | **Calibrating A** (empty/full, formulas, Builder), ADC calibration B, battery test, normal pump power and dry-run threshold, float switching direction |
| [`docs/fehlersuche.en.md`](docs/fehlersuche.en.md) | known failure patterns with cause and solution |
| [`docs/verlauf.en.md`](docs/verlauf.en.md) | project history 04.–08.10.2026 and decisions |

Short version of calibrating A (details in `docs/einmessen.en.md`):

```
abstand_leer_mm = Sensorwert "Abstand Wasser" (mm) + Wassertiefe mit Zollstock an der Öffnung (mm)
abstand_voll_mm = 50                     (100 % = 50 mm unter der IBC-Oberseite)
Füllstand %     = (leer − Abstand) / (leer − voll) × 100     (auf 0…100 begrenzt)
Inhalt L        = Füllstand % / 100 × 1000
```

(In English: empty distance = sensor value "Abstand Wasser" (water distance) + water depth measured with a folding rule at the opening; full distance = 50 mm below the IBC top; fill level % = (empty − distance) / (empty − full) × 100, clamped to 0…100; content L = fill level % / 100 × 1000.)

---

## 8. Home Assistant integration

File: [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml), **draft, not yet deployed**. It is an HA package with `input_boolean.ibc_pumpe_gesperrt` (pump locked),
`input_number.ibc_a_startstand` (start level of A) and 9 automations. Push notifications go only to Jens' phone (`notify.mobile_app_dein_handy`).

| Automation | Trigger | Effect |
|---|---|---|
| `ibc_pumpe_ein` | A > 90 % **or** B reports (new battery value) | pump on if A > 90 %, B report < 120 s old, target not full, no lock and pump off. Remembers the start level |
| `ibc_pumpe_aus_normal` | A < 70 % | pump off |
| `ibc_pumpe_aus_ziel_voll` | target full → on | pump off + push |
| `ibc_pumpe_sicherung` | 30 min run time / power < 20 W for 20 s / dropped less than 2 % after 10 min | off + **lock** + push with reason |
| `ibc_sensor_ausfall` | fill level A `unavailable` for 15 min | pump off + push |
| `ibc_pumpe_aus_b_stumm` | pump on and B > 180 s without a report, or float unavailable | pump off + push |
| `ibc_b_lebenszeichen` | B silent > 40 min | push (pump will not start in the meantime) |
| `ibc_b_akku_schwach` | battery B < 3.4 V | push |
| `ibc_a_uebervoll` | A > 97 % for 2 min | push (A has no overflow) |

The lock is released **only manually**: switch off `IBC-Pumpe gesperrt` (IBC pump locked).

**Before deploying:**
1. Replace the threshold `below: 20` in `ibc_pumpe_sicherung` with ~60 % of the measured normal power (see `docs/einmessen.en.md`).
2. The entity IDs match (checked 08.10.). `input_boolean.ibc_b_wach_halten` already exists as a UI helper and must **not** be defined again in the package.
3. Decide on the method: as a YAML package (`packages:` in the HA configuration) or create the automations via UI/API. This is still open.
4. Plug the pump plug back in; power-outage memory must stay `off`.

---

## 9. Open items, next steps, dates

| When | What | Who |
|---|---|---|
| Fri 09.10. 14:30 | E-cig battery self-discharge test: measure (outside the shield). Reference 08.10. 14:25 = 4.137 V. ≥ 4.09 V good, 4.04–4.09 borderline, < 4.04 V discard. Then measure 3V/5V on the right-hand shield | Jens |
| Fri 09.10. 18:00 | Glue the M12 glands into combined enclosure A, check the colour of the delivery, measure thread length and nut height | Jens |
| after battery test | Shield 5V + battery to node B, calibrate A0 against multimeter (`adc_faktor`) | Jens |
| — | Print enclosure B | Jens |
| — | Wi-Fi test at location B (D1 on a power bank) → decides on external antenna | Jens |
| by 22.10. | Mount A (cut-out 70 × 35, self-tapping screws 4.2 + sealing tape) and calibrate; remove the float from the Builder YAML A | Jens |
| by 22.10. | Run the pump for the first time → normal power; adapt and deploy the HA package | Jens |
| **23.10.–01.11.** | **Jens away from home.** No deliveries, no manual work. The pump logic may only run during this time if it has been tested beforehand. Otherwise the plug stays unplugged | — |
| Mon 02.11. 18:00 | Order from reichelt: Seeed Solar 1 W, 2× BZX 85C6V2, EVE 18650-33V, H05RN-F 2 × 0.75 ~3 m. Re-check prices and availability first (as of 07.10. ~€19–20) | Jens |
| after delivery | Panel + Zener diode to the U1 pads (photo of the pads first), mount node B, install float holder | Jens |
| later | Assess sleep current via the battery voltage curve in HA (no µA measurement planned) | — |
| open | Length of the float cable up to enclosure B (if not long enough: extend inside with H05RN-F) | Jens |
| open | Distance plug ↔ enclosure A (USB cable length), Zigbee reception at the location | Jens |
| open | Pump type and flow rate (important for the "10 min < 2 %" rule) | Jens |
| later, optional | second A02YYUW for a fill level in B (concept with FireBeetle rejected, too expensive) | — |

---

## 10. File overview

```
.
├── README.md                     German README
├── README.en.md                  this file
├── .gitignore                    excludes secrets*.yaml, .esphome/, backups
├── docs/                         each guide also as <name>.en.md (English)
│   ├── einbau.md                 assembly, mounting, commissioning, test
│   ├── einmessen.md              calibrating A and B, pump threshold
│   ├── fehlersuche.md            known failure patterns
│   └── verlauf.md                project history and decisions
├── firmware/
│   ├── ibc-wasser.yaml           node A (Builder state)
│   ├── ibc-b.yaml                node B (Builder state)
│   └── secrets.example.yaml      template, no real values
├── gehaeuse/
│   ├── ibc-gehaeuse.scad         combined enclosure A, float holder, older single parts
│   ├── ibc-b-gehaeuse.scad       enclosure node B
│   ├── ibc_kombi_gehaeuse.stl    A – enclosure          (printed)
│   ├── ibc_kombi_deckel.stl      A – lid                (printed)
│   ├── ibc_schwimmer_halter.stl  B – float holder       (printed)
│   ├── ibc_b_gehaeuse.stl        B – enclosure          (ready to print)
│   ├── ibc_b_deckel.stl          B – lid                (ready to print)
│   ├── ibc_b_dichtung.stl        B – lid gasket TPU     (designed)
│   ├── ibc_sensor_halter.stl     replaced, do not print
│   ├── ibc_sensor_abdeckung.stl  replaced, do not print
│   └── vorschau_ibc.png          outdated preview
├── ha/
│   └── ibc-pumpe.yaml            HA package pump logic (draft)
├── plaene/
│   ├── ibc-b-schaltplan.pdf      schematic node B
│   ├── ibc_b_plan.py             source of the schematic
│   ├── ibc-messblatt.pdf/.html   measurement sheet 06.10. (partly outdated)
└── fotos/
    ├── ibc-sensorposition.jpg    proposed sensor location on A (~35 cm from the pump)
    ├── shield-vorderseite-kontakte.jpg
    └── shield-rueckseite-spule.jpg   polarity test (+ beeps at coil 3R3)
```
