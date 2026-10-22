🇩🇪 [Deutsche Version](README.md)

# IBC water level and overflow protection (ESPHome + Home Assistant)

Level measurement for a 1000 l IBC (intermediate bulk container) used as a rainwater tank, with pump control so that it does not overflow.
Two ESPHome nodes on Wemos D1 mini boards; the pump logic runs in Home Assistant.

> **As of: 13.10.2026.** Sources: project notes (04.–13.10.2026), firmware from the ESPHome Builder, SCAD files, helpers and automations read from Home Assistant (13.10.2026).
> Anything not measured or confirmed is marked in the text as *(unverified)* or *(assumption)*.

> **Rebuilding this project:** The files reflect one specific installation. Before using them yourself:
> - Create your own `secrets.yaml` from [`firmware/secrets.example.yaml`](firmware/secrets.example.yaml) (Wi-Fi, API keys, fallback AP passwords).
> - In [`firmware/ibc-b.yaml`](firmware/ibc-b.yaml) set your own static IP under `manual_ip` (IP, gateway, subnet, DNS) or remove the `manual_ip` block to use DHCP.
> - In [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml) adjust the entity IDs to your installation (pump plug, power sensor, ESPHome entities) and replace `notify.mobile_app_dein_handy` ("your phone") with your own notify service.
>   The file is the original package draft. The running version differs from it (UI automations, two additional helpers), see section 8.
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

## 2. Status (as of 13.10.2026)

| Area | Status | Date / note |
|---|---|---|
| Ultrasonic sensor A02YYUW | ✅ delivered, bench-tested (room ceiling 1.37–1.47 m, hand detected immediately) | 06.10. |
| Node A flashed, in the Builder and in HA | ✅ done | 06.10. ~20:15 |
| Combined enclosure A (sensor + D1 mini) | ✅ printed (2nd revision, see section 5) | 07.10. |
| M12 cable glands | ✅ glued in with hot glue | by 11.10. |
| Mounting A on the IBC | ✅ mounted | 10.10. |
| Calibration A (empty value still estimated) | ⬜ open | by 22.10. |
| Remove float input from firmware A | ✅ removed and flashed via OTA | 10.10. |
| Restart diagnosis A (`debug`: reset reason, free memory) | ✅ flashed; until then A restarted ~1×/h, cause open | 11.10. |
| Restarts of A evaluated | ✅ 14 real restarts in ~20 h (11.10. 16:57 – 12.10. 13:15), all "Hardware Watchdog"; the Wi-Fi signal does not explain the clustering | 12.10. |
| Power-supply counter-test A | 🔄 power supply swapped 13.10. 17:47, A back online from 17:48:20 (reason "External System" = power-on); **result pending**, evaluation 14.10. 18:00 | 13.10. |
| Pump plug (Nous Zigbee) | ✅ in HA, power-outage memory = off; plugged in and reachable (13.10.), the pump has never run through it yet | 07.10. / 13.10. |
| Node B flashed (static IP), in the Builder and in HA | ✅ done, "keep awake"/deep sleep tested | 07.10. ~21:30–21:45 |
| Node B internal wiring (D0–RST, A0 divider, float) | ✅ done, bench test of float passed | 08.10. 17:32 |
| Float holder B | ✅ printed | 08.10. |
| Enclosure B | ✅ printed, node B installed | 10.10. |
| Node B on site | ✅ installed, reports every ~15 min; with static IP no more dropouts (with DHCP ~10 %) | 11.10. |
| Dropouts B with static IP | ✅ 0 of ~121 wake-ups lost (11.10. 13:12 – 12.10. 18:06, interval 14.3 min) | 12.10. |
| Float test B on site | ✅ passed: two cycles, "target container full" went on and off again immediately each time, no bouncing | 12.10. 18:21–18:23 |
| Lid gasket B (TPU) | ✅ designed, collision-checked; ⬜ not printed | 09.10. |
| Lid screws B 3 × 12 | ⬜ missing, to buy | — |
| Battery B | ✅ e-cigarette battery, self-discharge test passed (4.12 V in operation); replaced by an EVE 18650-33V on 21.10. | 11.10. / 21.10. |
| Solar panel, Zener diode, EVE battery | ✅ delivered (reichelt, 20.10.), panel + Zener diode soldered, EVE cell installed; B back on site | 21.10. |
| Charging via the panel | ⬜ **not proven yet**: cell almost full (4.18 V), voltage flat during the day, ~4 mV/h drop at night. Proof via the charge LED or a current measurement | 22.10. |
| Solar panel holder (wedge, frame with slide-in groove, latch) | ✅ designed and printed (reprint 21.10., first print on 20.10. failed); ⬜ fit test and mounting open | 21.10. |
| Pump logic in HA | ✅ **active** since 12.10. ~18:45 as UI helpers + 10 UI automations (section 8); ⬜ **not yet tested** in a real pump run | 12.10. |
| Normal pump power, dry-run threshold | ✅ test run 14.10.: **175 W** normal → threshold **105 W** (helper). Power during a real dry run not measured | — |

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
| Battery (variant 2) | 1 | EVE 18650-33V, flat top | reichelt, €6.82 | **installed 21.10.** (replaces variant 1) |
| Solar panel | 1 | Seeed DEBO SOLAR 1.0W, 5.5 V / ~170 mA, **open-circuit up to 8.2 V**, 100 × 80 × 2.33 mm (measured) | reichelt, €6.20 | delivered 20.10., connected 21.10. |
| Zener diode | 2 (1 + spare) | BZX 85C6V2, 6.2 V / 1.3 W | reichelt, €0.06/pc | installed 21.10. |
| Panel cable | ~3 m | H05RN-F 2 × 0.75 mm² (outdoor) | not available at reichelt (only a 50 m reel of H05RR-F) | source not documented |
| Solar panel holder | 1 + 1 + 1 | `solar_keil.stl` + `solar_rahmen.stl` + `solar_riegel.stl` (section 5) | own print, PETG/ASA | printed 21.10. |
| Holder screws | 4 + 4 + 2 | wood screw 4 × 30 countersunk (wedge → wall), 3 × 12 (frame → wedge, latch → frame) | — | — |
| Resistors | 2 | 100 kΩ + 22 kΩ in series (measured together 121.5 kΩ) | assortment | installed 08.10. |
| Wire jumper | 1 | D0 (GPIO16) → RST, for deep sleep | — | installed 08.10. |
| Float switch | 1 | side-mount float switch with hinged float (reed, 2 wires, ~3 mm cable), thread Ø 19 mm × 19.5 mm, sealing ring + nut; arrow on the body = mounting orientation | stock | available |
| Float holder | 1 | `ibc_schwimmer_halter.stl` | self-printed, PETG | printed 08.10. |
| Enclosure + lid | 1 + 1 | `ibc_b_gehaeuse.stl` + `ibc_b_deckel.stl` (outside 130 × 74 × 32 mm + tabs) | self-printed, PETG | printed, node B installed (10.10.) |
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
| Zigbee plug | 1 | Nous smart plug with power metering (Zigbee2MQTT). **Indoor device** → under the roof or in a protective box | stock | available, plugged in (13.10.) |
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
| ~~Float~~ | ~~2 wires~~ | ~~D5 + G~~ | ~~GPIO14~~ | **dropped**, the float now sits at node B. Removed from the firmware (10.10.) |

The wire colours come from the workshop notes and are not separately documented against the delivered sensor. Please check before soldering.

### Node B (`ibc-b`) – schematic: [`plaene/ibc-b-schaltplan.pdf`](plaene/ibc-b-schaltplan.pdf)

| From | To | Note |
|---|---|---|
| Solar panel + | left end of the **SS14** diode (anode, U1 side) | soldered like this on 21.10. The position was read from a photo of the board and checked with diode test and continuity before soldering |
| Solar panel − | round hole of the upper 5V/GND pair (back side, top right next to the 3R3 inductor) | |
| Zener diode | ring (cathode) to the SS14 anode, other end to ground (U1 shield pad or GND hole) | **in parallel** with the input, not in series. Clamps the panel's open-circuit voltage (up to 8.2 V) to ~6.2 V. With a full battery and bright sun the 1.3 W diode runs at its limit (calculated ~1.2–1.3 W) → check for heat before summer, use a 5 W type if needed |
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
| `ibc_b_gehaeuse.stl` | **B:** shield + D1 mini | printed (10.10.) | outside 130 × 74 × 32 + tabs, wall 3 mm, 2× M12 in the **lower** end wall, drain Ø 2.5, rails for shield (99.28 × 29.46, USB 6.74, height 25 – measured) and D1, terminal strip for the resistors |
| `ibc_b_deckel.stl` | lid for B | printed | lip, 4× self-tapping screw 3 × 12. Print: lid plate down |
| `ibc_b_dichtung.stl` | lid gasket for B (TPU) | designed 09.10., not printed | frame 1.6 mm on the 3 mm wall top, bead 0.8 × 0.6 on the wall centre, 4 corner ears Ø 7.4 with Ø 3.4 hole over the bosses. Print: TPU 95A, flat (bead up), 100 % infill, ~20 mm/s |
| `ibc_sensor_halter.stl`, `ibc_sensor_abdeckung.stl` | separate holder for the sensor (flange 104 × 60) | **replaced** by the combined enclosure | do not print any more |
| `vorschau_ibc.png` | preview image | **outdated** | still shows the round flange and the old D1 box |
| `solar_keil.stl` | **Panel B:** wall wedge, tilts the panel 30° away from the vertical wall (60° to horizontal) | printed 21.10. | 60.8 × 142.4 × 85.4 mm, 4× wood screw 4 × 30 countersunk. Print: **on its side**, profile on the bed |
| `solar_rahmen.stl` | **Panel B:** frame, the panel slides in from the top | printed 21.10. | 85.4 × 113.6 × 18.2 mm; slot 2.85 mm for the 2.33 mm panel; 11 mm chamber for solder joint/Wago; **slide-in groove** 20 × 9.5 mm in the head block for the terminals on the back of the panel; cable Ø 7.5 and drain holes at the bottom. Fixed to the wedge with 4× 3 × 12 from inside. Print: back wall down |
| `solar_riegel.stl` | **Panel B:** top cover, keeps the panel in the slot | printed 21.10. | tongue into the slot, 2× 3 × 12. Print: plate down |
| `vorschau_solarhalter.png` | preview of the mounted holder | current | |

The SCAD also contains `d1_box`/`d1_deckel` (separate D1 box). They have been replaced by the combined enclosure.

**Solar panel holder:** source [`gehaeuse/solarpanel-halter.scad`](gehaeuse/solarpanel-halter.scad), `TEIL = "keil" | "rahmen" | "riegel"`.
Collisions checked by intersection (`pruef_rahmen_keil`, `pruef_riegel_rahmen` empty or 0 mm³; `pruef_einschub`: a bump of
14 × 40 × 5 mm on the back of the panel slides through the groove over the whole way, without the groove it hits).
Mounting: wedge to the wall → frame onto the wedge from inside → cable from below through the chamber to the top, connect →
slide the panel in, pull the cable back down → latch on. Silicone (neutral-cure) at the cable entry.
The panel has an epoxy front but **no IP rating**; the back and the solder joints must stay dry in the chamber.
The SCAD also contains a variant B (panel from the front: `kasten`/`blende`); it is not needed.

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

The files in `firmware/` are the state from the **ESPHome Builder**, and the Builder is the authoritative source (compared 13.10.2026).
`abstand_voll_mm` has been `50` in the Builder since 09.10.; with the OTA updates of 10 and 11.10. the value is also on the device.

### Important substitutions

**A (`ibc-wasser`)**

| Name | Value | Meaning |
|---|---|---|
| `abstand_leer_mm` | `1050` (placeholder) | distance sensor → bottom = 0 %. **Calibrate** |
| `abstand_voll_mm` | `50` | distance sensor → highest level = 100 %. 100 % = 50 mm below the IBC top surface, because A has no overflow |
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

### Entities in Home Assistant (checked 13.10.2026)

| Node | Entity | Meaning |
|---|---|---|
| A | `sensor.ibc_wasser_abstand_wasser` | raw distance in mm (diagnostics) |
| A | `sensor.ibc_wasser_fullstand` | fill level % |
| A | `sensor.ibc_wasser_inhalt` | content in L |
| A | `sensor.ibc_wasser_wlan_signal`, `sensor.ibc_wasser_laufzeit` | diagnostics (Wi-Fi signal, uptime) |
| A | `sensor.garten_ibc_wasser_neustart_grund`, `sensor.garten_ibc_wasser_freier_speicher` | diagnostics (`debug`): reason of the last restart, free heap. Prefix `garten_` ("garden") because the entities were only created on 11.10. |
| B | `binary_sensor.ibc_b_zielcontainer_voll` | on = float open = B full or cable detached |
| B | `sensor.ibc_b_akku` | battery voltage V, `force_update` = sign of life (`last_reported`) |
| B | `sensor.ibc_b_akku_ladung` | roughly linear 3.3 V = 0 % … 4.15 V = 100 % (battery charge) |
| B | `sensor.ibc_b_wlan_signal`, `sensor.ibc_b_wach_seit` | diagnostics (Wi-Fi signal, awake since) |
| HA | `input_boolean.ibc_b_wach_halten` | UI helper (created 07.10.), since 12.10. also set by the pump automation |
| HA | `input_boolean.ibc_pumpe_gesperrt`, `input_datetime.ibc_pumpe_startzeit`, `input_number.ibc_a_stand_bei_pumpenstart`, `input_number.ibc_pumpe_trockenlauf_schwelle` | helpers of the pump logic (12.10.), see section 8 |
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
| [`docs/verlauf.en.md`](docs/verlauf.en.md) | project history 04.–13.10.2026 and decisions |

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

**Active since 12.10.2026 ~18:45.** The logic runs as **UI helpers and 10 UI automations** (IDs `ibc_*`), because this HA installation does not use
`packages:`. [`ha/ibc-pumpe.yaml`](ha/ibc-pumpe.yaml) is the original package draft and now serves only as a **reference**; its header lists the
differences of the live version. Push notifications go only to Jens' phone (`notify.mobile_app_dein_handy`).
**Test run 14.10. passed** (switched manually, ~66 s): 175–176 W steady, water moving A → B, A 46.3 → 45.4 %, "remember pump run" stored start time and level. The automatic start at A ≥ 90 % has not yet been triggered by a real run.

**Helpers**

| Helper | Purpose |
|---|---|
| `input_boolean.ibc_pumpe_gesperrt` | lock after dry run, 35 min run time or "A does not drop". Release only manually |
| `input_boolean.ibc_b_wach_halten` | keeps node B awake (exists since 07.10.); now also set by the pump automation |
| `input_datetime.ibc_pumpe_startzeit` | start time of the current pump run (new compared to the draft) |
| `input_number.ibc_a_stand_bei_pumpenstart` | level of A at pump start (`ibc_a_startstand` in the draft) |
| `input_number.ibc_pumpe_trockenlauf_schwelle` | power threshold for dry run, **105 W** = 60 % of 175 W (test run 14.10.; new compared to the draft) |

**Automations (live, read 13.10.2026)**

| Automation (ID) | Trigger | Effect |
|---|---|---|
| `ibc_pumpe_ein` | A > 90 %, B reports (`sensor.ibc_b_wach_seit` changes), lock → off, target full → off | If A > 90 %, target not full, no lock, pump off: first switch on `IBC B wach halten` (keep B awake); pump on only with a fresh B report (`sensor.ibc_b_akku` < 120 s old), otherwise at the next report |
| `ibc_pumpe_lauf` | pump off → on / on → off (also manual) | on: remember start time and level of A. off: `IBC B wach halten` off, B may sleep |
| `ibc_pumpe_aus_normal` | A < 70 % | pump off |
| `ibc_pumpe_aus_ziel_voll` | target full → on | if the pump was running: off + push. Always: `IBC B wach halten` off |
| `ibc_pumpe_sicherung` | every minute while the pump runs; power below the threshold helper for 20 s | run time ≥ 35 min, dropped less than 2 % after 10 min, or power too low → off + **lock** + push with reason. Run time from `input_datetime`, not via `for:` |
| `ibc_sensor_ausfall` | fill level A `unavailable` for 15 min | pump off + push. Short watchdog restarts of A (seconds) do not trigger this |
| `ibc_pumpe_aus_b_stumm` | pump on and B > 180 s without a report, or float `unavailable`/`unknown` | pump off + push |
| `ibc_b_lebenszeichen` | B silent > 40 min | push (pump will not start in the meantime) |
| `ibc_b_akku_schwach` | battery B < 3.4 V | push |
| `ibc_a_uebervoll` | A > 97 % for 2 min | push (A has no overflow) |

**Why it differs from the draft:** node B decides only ~1 s after reporting whether it goes back to sleep. The draft would have started the pump
on the report but already let B fall asleep again. Therefore the ON automation first sets "keep awake", and the pump starts at the next fresh
report. The run time comes from an `input_datetime` so that an HA restart or a radio dropout does not reset the 35 min limit
*(reasoning from planning, not yet observed in operation)*.

**Still to do:**
1. ~~Test run~~ done 14.10.: 175 W, threshold 105 W
   (see `docs/einmessen.en.md`). Check whether "remember pump run" sets start time and level of A, and whether A visibly drops.
2. Power-outage memory of the plug must stay `off` (checked 13.10.).

**Way back:** disable the `ibc_*` automations in HA; the plug then stays as it is (off after a power failure).

---

## 9. Open items, next steps, dates

| When | What | Who |
|---|---|---|
| ~~Fri 09.10. 14:30~~ | ~~E-cig battery self-discharge test~~ → done: the battery is in B and reports 4.11–4.15 V in operation (11/12.10.) | Jens |
| open | Calibrate A0 of B against the multimeter (`adc_faktor`) – not done yet | Jens |
| ~~—~~ | ~~Wi-Fi test at location B~~ → done by operation: −60…−73 dBm, no dropouts with static IP. External antenna not needed for now | — |
| ~~Wed 14.10. 17:30~~ | ✅ **Pump test run done:** 175 W, threshold 105 W, water moving A → B, start time/level A stored | — |
| **Wed 14.10. 18:00** | **Evaluate power-supply counter-test A:** restarts (`sensor.garten_ibc_wasser_neustart_grund`, uptime) since 13.10. 17:48:20 versus 14 watchdog restarts in ~20 h with the old power supply. 0–1 restarts → the power supply was the cause | — |
| Sat 18.10. 12:00 | Battery trend B after one week (daily means 11.–18.10., mV/day) → does the battery last through the absence until the panel arrives? | — |
| by 22.10. | Calibrate A (the empty value is still estimated) | Jens |
| **23.10.–01.11.** | **Jens away from home.** No deliveries, no manual work. The pump logic has been active since 12.10.; it should only keep running if the test run succeeds beforehand. Otherwise disable the `ibc_*` automations | — |
| ~~Mon 02.11. 18:00~~ | ~~Order from reichelt~~ → brought forward, delivered 20.10. | — |
| ~~after delivery~~ | ~~Solder panel + Zener diode~~ → done 21.10. | — |
| open | **Prove charging:** look at the charge LED in the sun or measure the panel current (not provable from the voltage alone while the cell is full) | Jens |
| open | **Fit test of the holder** (do the terminals slide through the groove, does the panel rattle?), then mount it on the wall; note the wall's orientation | Jens |
| Sun 15.11. | Battery trend B after 5 weeks (night mean 03–05 h) | — |
| before summer | Check the Zener diode for heat (5 W type if needed) | — |
| later | Assess sleep current via the battery voltage curve in HA (no µA measurement planned) | — |
| ~~open~~ | ~~Length of the float cable~~ → done: float installed and tested on site (12.10.) | — |
| open | Length and cross-section of the USB cable of A (for the restart question, in case it was not the power supply) | Jens |
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
│   ├── solarpanel-halter.scad    solar panel holder B (wedge, frame, latch)
│   ├── ibc_kombi_gehaeuse.stl    A – enclosure          (printed)
│   ├── ibc_kombi_deckel.stl      A – lid                (printed)
│   ├── ibc_schwimmer_halter.stl  B – float holder       (printed)
│   ├── ibc_b_gehaeuse.stl        B – enclosure          (printed)
│   ├── ibc_b_deckel.stl          B – lid                (printed)
│   ├── ibc_b_dichtung.stl        B – lid gasket TPU     (designed)
│   ├── solar_keil.stl            panel B – wall wedge   (printed)
│   ├── solar_rahmen.stl          panel B – frame        (printed)
│   ├── solar_riegel.stl          panel B – latch        (printed)
│   ├── vorschau_solarhalter.png  preview of the mounted holder
│   ├── ibc_sensor_halter.stl     replaced, do not print
│   ├── ibc_sensor_abdeckung.stl  replaced, do not print
│   └── vorschau_ibc.png          outdated preview
├── ha/
│   └── ibc-pumpe.yaml            pump logic as HA package (reference, live as UI automations)
├── plaene/
│   ├── ibc-b-schaltplan.pdf      schematic node B
│   ├── ibc_b_plan.py             source of the schematic
│   ├── ibc-messblatt.pdf/.html   measurement sheet 06.10. (partly outdated)
└── fotos/
    ├── ibc-sensorposition.jpg    proposed sensor location on A (~35 cm from the pump)
    ├── shield-vorderseite-kontakte.jpg
    └── shield-rueckseite-spule.jpg   polarity test (+ beeps at coil 3R3)
```
