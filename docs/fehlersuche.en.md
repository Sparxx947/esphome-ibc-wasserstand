🇩🇪 [Deutsche Version](fehlersuche.md)

# Troubleshooting

Back to the [README](../README.en.md). Known failure patterns from the project history (04.–08.10.2026). Items that are only described as a precaution are marked *(precautionary)*.

## Node A (`ibc-wasser`)

| Symptom | Cause | Solution |
|---|---|---|
| `Zielcontainer voll` (target container full) on A is permanently **on** | The float input GPIO14 is open (internal pull-up). The float has been at node B since 07.10. | Delete the `binary_sensor` block from the Builder YAML A and remove the orphaned entity in HA |
| Fill level jumps or shows nonsense when the container is almost empty *(precautionary)* | 60° sound cone: echoes from the wall, the pump riser pipe or the corrugated hose | Location ≥ 30 cm from the pump and ≥ 20 cm from the wall; the median filter (15) catches isolated echoes |
| No value / `nan` with a very full container | The sensor is blind below ~30 mm | That is why 100 % is at 50 mm. From 97 % a push is sent |
| Sensor delivers different data / values only on request | The yellow wire (RX/mode) is connected to ground | leave yellow unconnected |
| Fill level does not match the folding rule | Empty value wrong, bottom uneven *(unverified)*, folding rule at an angle | recalibrate, see [einmessen.en.md](einmessen.en.md) |
| Moisture in the D1 chamber *(precautionary)* | Tank air through the cable slot of the partition wall or past the sensor | Silicone bead under the sensor and in the slot; keep the 2 mm condensation hole clear |
| Water at the sensor flange | A is brim-full because there is no overflow | Sealing tape under the flange; HA reports from 97 % |
| Gland does not grip | The printed wall at the M12 is 6.4 mm thick (2nd revision) | Thread the nut on the inside as far as possible, secure with hot glue; or counterbore Ø 22–25 on the inside; or reprint the current STL (3 mm remaining wall) |

## Node B (`ibc-b`)

| Symptom | Cause | Solution |
|---|---|---|
| Node **never** wakes up after deep sleep | D0–RST jumper missing or without contact | Check the jumper; until then only the reset button helps |
| Flashing via USB fails | The D0–RST jumper interferes with auto-reset | Briefly remove the jumper |
| Node only reports every 2 h | Battery < 3.3 V, or A0 unconnected (07.10.: 0.01 V) or without battery (08.10.: 0.41 V) | Check battery/divider; after a reset it is awake for 10 min |
| OTA update does not arrive | The node is asleep | Switch on `IBC B wach halten` (keep awake) in HA, wait up to 15 min (or 2 h), flash, then switch **off** again |
| Battery drains quickly | "Keep awake" forgotten; shield quiescent current too high (bad batch with SW6115/IP3005A: ~100 mA instead of ~0.3 mA); panel shaded | Helper off; look at the battery curve in HA; replace the shield; clean and align the panel |
| D1 mini starts unreliably *(precautionary)* | powered from the shield's 3V output (XC6206 without capacitor) | always shield **5V** → D1 **5V** |
| Shield input destroyed *(precautionary)* | Panel open-circuit voltage up to 8.2 V > 6.5 V input limit | Zener diode 6.2 V in parallel, ring to + |
| Smoke/heat when inserting the battery *(precautionary)* | Holder polarity reversed (known layout error of this shield series) | measure first: + beeps at coil 3R3. Checked on both existing shields ✔ |
| Strange behaviour during testing | D1 USB and shield connected at the same time | **never** both at the same time |
| `Zielcontainer voll` = on although B is empty | Float cable detached/open or float mounted the wrong way round | Check the cable; arrow on the float, rotate by 180° (do **not** invert the firmware) |
| Hotspot password or API key wrong after flashing | A test build with dummy secrets was flashed (`esphome upload` does not recompile) | always `esphome run` with real secrets; then verify via the API |
| Battery does not charge in winter *(precautionary)* | Li-ion must not be charged below 0 °C | open. According to the notes the charger has no temperature monitoring *(not confirmed)* |

## Pump / Home Assistant

| Symptom | Cause | Solution |
|---|---|---|
| A > 90 %, but the pump does not start immediately | **Intentional:** start only when B has reported freshly (< 120 s), i.e. at the next wake-up (≤ 15 min) | wait; otherwise check lock, "target full" and B's sign of life |
| Pump does not start at all any more | `IBC-Pumpe gesperrt` (IBC pump locked) is on (after dry run or 30 min) | Inspect the cause on site, then switch off the lock **manually** |
| Push "Pumpe gesperrt – Leistung zu niedrig" (pump locked – power too low), although everything was pumped | The threshold `below: 20` is still a placeholder | set it to ~60 % of the normal power |
| Push "A sinkt nicht" (A is not dropping) | Line blocked, pump drawing air, ball valve closed; or the pump delivers less than ~2 l/min | Check line and valve; adjust the rule if necessary |
| Push "Knoten B meldet sich nicht" (node B is not reporting) | Battery empty, Wi-Fi, node stuck in deep sleep without D0–RST | Battery/panel, Wi-Fi signal, reset |
| Pump starts after a power failure *(precautionary)* | Power-outage memory of the plug not `off` | set to `off` (configured this way since 07.10.) |
| Plug `unavailable` | It is unplugged (since 07.10. 18:33), or there is no Zigbee reception | plug it in; check reception at the location |

## Ordering / parts

| Problem | Note |
|---|---|
| Seki M12 has the wrong colour | The listings are mixed up: B083V943WD is **grey** despite "black" in the title; B083V8V9TR was chosen. Its description also says "grau (RAL7035)" (grey), so please check the delivery |
| Lapp SKINTOP ST-M M12 does not seal the float cable | Clamping range starts at 3.5 mm, the float cable is ~3 mm. Hence types with 3–6.5 mm |
| Panel with 6 V nominal voltage | unsuitable (open-circuit ~7.7 V). Only 5 V / 5.5 V panels with Zener diode |
