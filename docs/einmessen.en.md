🇩🇪 [Deutsche Version](einmessen.md)

# Calibration

Back to the [README](../README.en.md). As of 08.10.2026.

Four things are calibrated:

1. Node A: empty and full distance of the ultrasonic sensor, i.e. 0 % and 100 %
2. Node B: ADC factor of the battery voltage
3. Node B: switching direction of the float
4. Pump: normal power and, derived from it, the dry-run threshold in HA

In addition there is the self-discharge test of the battery before installation.

---

## 1. Node A: calibrating the fill level

**When:** only **after mounting** the combined enclosure on the IBC, because the measurement starts at the actual transducer surface.

### Basics

- The sensor measures the distance **transducer surface → water surface** in mm (`sensor.ibc_wasser_abstand_wasser`).
- The transducer surface lies ~1.5 mm **below** the IBC top surface. This is negligible for the calculation.
- The sensor is blind below ~30 mm (A02YYUW: minimum distance 3 cm). That is why "full" is not brim-full.
- Container A has **no overflow**. 100 % is therefore defined as **50 mm below the top surface**: decision of 07.10., set as an assumption, not derived from an overflow dimension.

### Formulas (as they are in the firmware)

```
Füllstand_% = (abstand_leer_mm − Abstand) / (abstand_leer_mm − abstand_voll_mm) × 100      → auf 0…100 begrenzt
Inhalt_L    = Füllstand_% / 100 × volumen_l                                                (volumen_l = 1000)
Liter pro cm = volumen_l / ((abstand_leer_mm − abstand_voll_mm) / 10)                       (≈ 10 l/cm)
```

(`Füllstand_%` = fill level %, `Abstand` = measured distance, `Inhalt_L` = content in litres, `Liter pro cm` = litres per cm; "auf 0…100 begrenzt" = clamped to 0…100.)

### Step by step

1. **Calm water:** pump off, no rain inflow. Wait about one minute, because the median filter needs 10 new values and values are sent at most every 30 s.
2. **Read the sensor value:** `IBC Wasser Abstand Wasser` (water distance) in HA, e.g. `d = 612 mm`. Wait for two or three values; they should differ by a few mm at most.
3. **Measure the water depth:** folding rule vertically through the filler opening down to the bottom, read the water line, e.g. `h = 395 mm`.
   - The pump stands in the middle of the bottom. Place the folding rule next to it, not on the pump.
4. **Calculate the empty value:**
   ```
   abstand_leer_mm = d + h          Beispiel: 612 + 395 = 1007
   ```
   (Beispiel = example)
5. **Set the full value:** `abstand_voll_mm = 50`.
6. **In the ESPHome Builder** open the YAML of `ibc-wasser` (the Builder is authoritative) and there:
   - enter `abstand_leer_mm` and `abstand_voll_mm`,
   - **delete the whole `binary_sensor` block "Zielcontainer voll" (target container full, GPIO14)**, because the float sits at node B. Otherwise A permanently reports "target full",
   - update the header comment ("mittig im Deckel" / centred in the cap, "Schwimmer … D5" / float … D5),
   - *Install → Wirelessly*.
7. **Check:** the fill level should now correspond to `h / (leer − 50) × 100` (leer = empty). In the example: 395 / 957 × 100 ≈ 41 %, i.e. ≈ 413 L.
8. In HA remove the orphaned entity `binary_sensor.ibc_wasser_zielcontainer_voll`.
9. Copy the new Builder YAML into the repo (`firmware/ibc-wasser.yaml`).

### Cross-check (recommended)

At a different water level, e.g. after the next rain or a pump run, repeat steps 2–3 and compute `d + h` again.
If it deviates by more than ~10 mm from the entered empty value, there are several possible causes. **None of them has been verified:**
- The IBC bottom is not flat. Many IBCs slope towards the outlet; then `h` depends on where you measure.
- Echoes from the riser pipe, corrugated hose or wall, because the sound cone is 60° wide.
- The folding rule was held at an angle.

### Notes

- The real volume of a "1000 l" IBC was **not** measured. If the litre value is wrong, adjust `volumen_l`. The % value is not affected.
- With an almost empty container, **wall echoes** are possible because of the 60° cone. Treat values below ~10 % with caution.
- The pump logic only uses % (thresholds 70/90/97 %). An error in the empty value shifts these thresholds.

---

## 2. Node B: calibrating the battery voltage (ADC factor)

**Background:** The D1 mini has an internal 220 kΩ / 100 kΩ divider on A0; the ADC full-scale value is 1.0 V. In front of it are 100 kΩ + 22 kΩ in series, measured together **121.5 kΩ**.

```
adc_faktor (theoretisch) = (R_vor + 220k + 100k) / 100k
                         = (122 + 220 + 100) / 100 = 4,42          (in der Firmware)
                         = (121,5 + 220 + 100) / 100 = 4,415       (mit gemessenem R_vor)
Messbereich ≈ 4,42 V
```

(theoretisch = theoretical, `R_vor` = series resistor, "in der Firmware" = as in the firmware, "mit gemessenem R_vor" = with the measured series resistor, Messbereich = measuring range.)

The internal resistors of the D1 mini have tolerances. That is why the value is calibrated against a multimeter.

### Step by step

1. Prerequisites: the battery has passed the self-discharge test (section 4), shield 5V/GND is connected to the D1 mini, **no USB on the D1 mini**.
2. In HA switch **on** `IBC B wach halten` (keep awake) and wait for the next wake-up. After plugging in or a reset it is awake for 10 min anyway.
3. Use the multimeter to measure the voltage **at the holder contact battery+ against GND**: `U_mm`.
4. At the same time read `sensor.ibc_b_akku` in HA: `U_ha`. While awake it is updated every 60 s.
5. New factor:
   ```
   adc_faktor_neu = adc_faktor_alt × U_mm / U_ha
   Beispiel: 4,42 × 3,95 / 4,01 = 4,354
   ```
   (neu = new, alt = old, Beispiel = example)
6. In the Builder change `adc_faktor` in `ibc-b` → OTA (while "keep awake" is on).
7. Check after the restart, then switch "keep awake" **off**.

### Battery charge (%)

The firmware calculates roughly linearly: `% = (U − 3,3) / (4,15 − 3,3) × 100`, clamped to 0…100. This is only a rough guide, because the Li-ion discharge curve is not linear.

### Thresholds

| Voltage | Effect |
|---|---|
| < 3.4 V | push "Akku schwach" (battery low) (HA) |
| < 3.3 V | node sleeps 2 h instead of 15 min (firmware) |
| 2.4 V | over-discharge protection of the shield (DW01, according to research) |
| 4.20 V | end-of-charge voltage TC4056 |

---

## 3. Node B: float switching direction

Goal: **"opens with water"**. An open contact then means full **or** cable break, and both lock the pump.

1. There is an arrow on the float body; it indicates the mounting orientation. Rotated by 180°, the switching direction is reversed.
2. Check on the bench before installation: keep node B awake, connect the float.
   - Hinged float **hanging down** (no water) → contact must be **closed** → `IBC B Zielcontainer voll` (target container full) = **off**.
   - Hinged float **flipped up** (water) → contact **open** → **on** after 2 s.
3. If it is wrong, rotate the float in the holder by 180°. Do **not** invert the firmware, because then a cable break would be read as "empty".

Bench test of 08.10. (wire jumper instead of float): short circuit → off (17:32:35), open → on (17:32:40). Passed.

**Switching point:** the holder places the threaded hole 120 mm below the rim of the neck. The float switches at roughly the height of the hole *(approximate, not measured)*.

---

## 4. Battery self-discharge test (before installation)

Applies to the e-cigarette battery. It was deeply discharged (2.78 V), was charged under supervision in the left-hand shield via micro-USB and has been resting outside the shield since then.

| Point in time | Voltage |
|---|---|
| 07.10. ~21:05 (start of charging) | 2.78 V |
| 08.10. 14:25 (reference value, loose outside the shield) | **4.137 V** |
| 09.10. ~14:30 (evaluation) | ≥ 4.09 V good · 4.04–4.09 V borderline · < 4.04 V discard |

Check beforehand: wrap undamaged, note marking/type. **Do not charge Li-ion below 0 °C.** For winter operation outdoors this has not been solved yet *(open)*.

If the battery fails, the EVE 18650-33V from the reichelt order on 02.11. will be used.

---

## 5. Pump: normal power and dry-run threshold

1. Plug in the plug. During the **first real run** (A well filled, hose to B open) read the power `sensor.steckdose_ibc_wassercontainer_pumpe_power` after ~1 min: `P_normal`.
2. Calculate the threshold: `P_schwelle ≈ 0,6 × P_normal` (Schwelle = threshold), e.g. 350 W → 210 W.
3. In `ha/ibc-pumpe.yaml`, automation `ibc_pumpe_sicherung`, replace `below: 20` with `P_schwelle`.
4. **Check the flow rate:** the rule "dropped less than 2 % after 10 min → lock" requires at least ~2 l/min, because 2 % ≈ 20 l.
   Read the fill level of A after 10 min of run time. If the pump delivers close to this limit, adjust the threshold or the time.
5. Check whether A gets from 90 % to 70 % within 30 min (run-time limit), i.e. ~200 l. Otherwise the 30 min lock will trigger every time.
