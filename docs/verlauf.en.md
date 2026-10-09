🇩🇪 [Deutsche Version](verlauf.md)

# Project history and decisions

Back to the [README](../README.en.md). Summarised from the project notes.

| Date | Event / decision |
|---|---|
| 04.10. | Idea: fill level A via ultrasound + existing float as "target full". Sensor A02YYUW ordered (JSN-SR04T rejected, blind ~20–25 cm at the top). Clarified: 3 containers at ground level, path to B/C 2–3 m high → existing pump. Pump via a free Zigbee plug with power metering. Firmware A and HA package designed and compiled (RAM 38.7 %, flash 40.5 %) |
| 06.10. | Sensor delivered. D1 mini flashed as `ibc-wasser` (.189, fixed assignment in the FRITZ!Box), in the Builder and in HA. Measurement sheet printed |
| 07.10. afternoon | Sensor measured: **rectangular housing**, not a round head → holder redesigned. Position in A clarified: pump centred in the neck, HT pipe in the neck → sensor **next to** the opening on the top surface. A has no overflow → 100 % = 50 mm below the top. Sensor cable only ~32 cm → **combined enclosure** sensor + D1 |
| 07.10. | Pump plug found (Nous, Z2M), power-outage memory → off. B and C are connected at the bottom → **one** float in B is enough. B is too far from A → **separate node**, preference for solar + battery |
| 07.10. | Expensive variant (FireBeetle 2 ESP32-C5 + panel + cells, ~€87) rejected ("must be possible cheaper"). **Budget variant:** existing D1 mini + existing 18650 Battery Shield V3 (right-hand one, without U1 jack) + 1 W panel + Zener diode. No wake-up by the float; instead HA only starts the pump on a fresh B report, and B stays awake as long as the pump is running |
| 07.10. | Float measured (thread 19, neck wall 11.1, switching height 120), B stays without a cap → float holder ready to print. Shield polarity checked on both shields. Combined enclosure A **printed** (2nd revision, wall at M12 6.4 mm) → hot glue instead of counterboring |
| 07.10. evening | Enclosure B, schematic B, firmware B finished. Node B **flashed** (.196 static), added to HA, helper `ibc_b_wach_halten` (keep awake) created, test keep awake / deep sleep ✔. The ESPHome Builder can be controlled via API. Amazon basket (multimeter UT139C, M12) ordered by Jens; remaining reichelt items postponed to **02.11.** (absence 23.10.–01.11.) |
| 08.10. | E-cig battery charged, reference value 4.137 V. 100 k + 22 k available. Float holder **printed**. Internal wiring B finished, bench test float ✔ (17:32) |
| 09.10. | **TPU lid gasket B** designed (`ibc_b_dichtung.stl`), collision checked by intersection, mesh cleaned. Lid screws 3 × 12 still missing |

## Rejected approaches

| Idea | Why not |
|---|---|
| Sensor in the screw cap of A | The HT pipe and the pump riser pipe sit in the neck, both within the sound cone |
| Stilling pipe DN110 with the sensor on top | not necessary, because the top surface next to the opening is flat and free |
| Drilling through the IBC wall (float) | hanging holder in the filler neck instead of drilling |
| Zigbee door contact as float node | Jens wanted a solar ESP with the later option of a fill level in B |
| FireBeetle 2 ESP32-C5/C6 | too expensive (total basket ~€87) |
| 6 V panel | open-circuit ~7.7 V > 6.5 V shield input |
| Shield 3V output for the D1 | XC6206 without output capacitor, unstable |
| µA measurement of the sleep current | replaced by observing the battery voltage curve in HA |
