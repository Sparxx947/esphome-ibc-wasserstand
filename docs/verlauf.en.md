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
| 10.10. | A mounted, float input removed from firmware A (OTA). Wi-Fi at the container only −79…−81 dBm (indoors −60). Node B in its enclosure: a direct D0–RST bridge blocked USB flashing → now 470 Ω (deep-sleep wake-up works, USB flashing only without the bridge, otherwise OTA) |
| 11.10. | B installed on site, reports every ~15 min. DHCP test reverted, static IP again: no more dropouts since (before ~10 %). A restarted ~1×/h → `debug` with reset reason flashed; first finding "Hardware Watchdog" with weak Wi-Fi (−83 dBm), cause still open |
| 12.10. | **A:** evaluation since the diagnostics flash: 14 real restarts in ~20 h, all "Hardware Watchdog", clustered in the evening (21:09–22:37), stable for 7 h 44 min at night, every 20–80 min during the day. Wi-Fi was even better in the morning (−81…−76 dBm) → **the signal does not explain the clustering**. Next step: power supply as a counter-test (only one change at a time). **B:** static IP confirmed (0 of ~121 wake-ups lost in ~29 h). Evaluation pitfall: HA does not store identical consecutive values, so always evaluate `wach_seit` and `akku` together. **Float test on site passed** (two cycles, no bouncing). **Pump logic activated ~18:45**, as UI helpers + 10 UI automations instead of a package; key change: ON first sets "keep awake", because B decides about sleeping only ~1 s after reporting; run time from `input_datetime` instead of `for:`. Dry-run threshold provisionally 20 W, the pump has never run through the plug yet |
| 13.10. | **A:** power supply swapped (17:47), A back online at 17:48:20, reset reason "External System" (= power-on), fill level 45.4 %, Wi-Fi −76 dBm. From now on only restarts after 17:48:20 count; baseline 14 watchdog restarts in ~20 h with the old power supply. Evaluation 14.10. 18:00, **result pending**. Repo brought up to the state of 13.10. |
| 14.10. | **Pump:** manual test run, ~66 s: **175–176 W** steady, water moving A → B, A 46.3 → 45.4 % (roughly ~8 l/min, sensor noise possible), float B stayed off; "remember pump run" and "keep awake off" worked. Dry-run threshold **20 → 105 W** (60 %). Open: power during a real dry run; is the flow enough for A to get from 90 to 70 % within 30 min (~200 l ≈ 6.7 l/min needed)? **Run-time limit raised 30 → 35 min as a precaution.** **A:** evaluation since the PSU swap (13.10. 17:48 → 14.10. 17:06, ~23.3 h): **17 real reboots** (uptime reset, all "Hardware Watchdog"), clustered 01:06–01:38 (7 in 32 min); before 14 in ~20 h → **the PSU was not the cause**. The dropout on 13.10. 18:55 was on the HA side (uptime kept counting). **A 17:21 OTA:** likely cause found — the logger occupied UART0, so the sensor on GPIO13 ran on **SoftwareSerial** (per ESPHome 2026.9.1 source). Logger moved to UART1 → sensor on hardware UART0 (swapped). Added diagnostics: loop time (19 ms after boot), largest free block, heap fragmentation. Sensor keeps delivering fresh values every ~30 s. **Effect pending**, evaluation 15.10. |
| 15.10. | **A: cause confirmed.** Since the hardware-UART flash (14.10. 17:21) **0 reboots in 21.3 h** (uptime counted through without reset; before ~0.7/h, so ~15 expected). Reset reason still "Software/System restart" (= the OTA), loop time steadily 18–23 ms (up to 3.7 s at boot before), largest free block 41 KB, fragmentation 4–5 %, distance 594–601 mm without dropouts, Wi-Fi −81…−76 dBm as before. **SoftwareSerial caused the watchdog reboots** — neither Wi-Fi nor the power supply did |

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
