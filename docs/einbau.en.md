🇩🇪 [Deutsche Version](einbau.md)

# Assembly, commissioning, installation and test

Back to the [README](../README.en.md). As of 08.10.2026. For calibration see [einmessen.en.md](einmessen.en.md).

---

## Part A: Node `ibc-wasser` (container A)

### A1. Bench assembly

1. Prepare the enclosure: glue in the M12 glands (see README section 5, Assembly A).
2. Connect the sensor: red → 3V3, black → G, white → D7, **yellow unconnected**.
   For testing, jumper wires go into the JST-PH connector (2 mm pitch); outdoors, soldering is better.
   The sensor cable is only ~32 cm long, which is why the D1 mini sits right next to it in the combined enclosure. Do **not** extend the cable. At UART 9600 it would work over several metres, but it is unnecessary.
3. Power cable: long USB cable through one gland, solder the wires to **5V** and **G**.
4. Bench function test: power on, watch `IBC Wasser Abstand Wasser` (water distance) in HA, hold the sensor up towards the room ceiling.
   In the test on 06.10. this gave 1.37–1.47 m, and a hand underneath was detected immediately.
5. Set the sensor into the window with a bead of silicone, seal the cable slot of the partition wall, fix the D1 mini.
   Only put the lid on after curing (4 × 3 × 16).

### A2. Location on the IBC

Photo with marking: [`fotos/ibc-sensorposition.jpg`](../fotos/ibc-sensorposition.jpg)

- on the IBC **top surface next to** the filler opening, **not** in the screw cap. That is where the HT pipe DN50 and the pump riser pipe sit
- front field between the two longitudinal struts of the steel cage, left of the vertical trough ("avoid the channel"), in front of the moulded lettering
- distance **≥ 30 cm from the pump** (estimated ~35 cm from the photo) and **≥ 20 cm from the side wall**, because of the 60° sound cone
- the spot is flat (Jens, 07.10.). Space required on the IBC ~111 × 99 mm. Jens measured whether that fits between the struts; a result is **not noted**

### A3. Mounting

1. Using the enclosure as a template, mark the **window at the bottom (68 × 33)** and cut an opening of **70 × 35 mm** into the IBC top surface.
   Fish the chips out of the container.
2. Mark the 4 flange holes, **pre-drill 3.2 mm** in the IBC.
3. **Sealing tape** under the flange. When brim-full, water reaches the flange, and PE is hard to glue.
4. Fasten with **4 stainless-steel self-tapping screws 4.2 × 16**. Nuts would not be reachable from the inside.
5. Optionally secure the cables with cable ties to the cage strut. USB power adapter into a socket under the roof.
6. Calibration → [einmessen.en.md](einmessen.en.md), section 1. At the same time remove the float block from firmware A.

---

## Part B: Node `ibc-b` (container B)

### B1. State of the internal wiring (08.10.)

Done and tested: D0–RST jumper, A0 divider (100 k + 22 k = 121.5 kΩ measured), float at D5/G. Schematic: [`plaene/ibc-b-schaltplan.pdf`](../plaene/ibc-b-schaltplan.pdf).

### B2. Battery and shield

1. Only insert the battery if it has passed the self-discharge test ([einmessen.en.md](einmessen.en.md), section 4).
2. Polarity: the marking on the holder is correct on **both** shields. Checked on 07.10.: "+" beeps against coil 3R3, "−" does not.
   A layout error with reversed holder polarity is known for this board series, so measure again with any other shield.
3. Insert the battery, then measure and note **5V/GND** and **3V/GND** on the shield.
4. Shield **5V → D1 5V**, **GND → G**. **No USB on the D1 mini at the same time.**
5. ADC calibration → [einmessen.en.md](einmessen.en.md), section 2.

### B3. Solar panel (after delivery from 02.11.)

1. Before soldering, take a **photo of the pads of the missing USB jack U1** and determine which pad is VBUS.
2. **Zener diode BZX 85C6V2 in parallel** with the input, **ring (cathode) to +**.
   Reason: the panel delivers up to 8.2 V open-circuit, and according to the vendor the shield input only tolerates 6.5 V. The panel is current-limited; the Zener diode only gets warm with a full battery and sunshine.
3. Panel cable H05RN-F 2 × 0.75 (~2–3 m) through the second M12 gland. The panel hangs **on the outside of the shed**.

### B4. Enclosure and mounting

1. Print enclosure B (`ibc_b_gehaeuse.stl` + `ibc_b_deckel.stl`).
2. Insert shield and D1 (antenna end facing up), resistors into the terminal strip.
3. Float and panel cables through the M12 at the bottom. If a cable is too short, extend it **inside** at a terminal, not outside.
4. Hang the enclosure **vertically** on the cage of B, glands **facing down**, lid facing forward. Fasten with cable ties through the tab slots or a 4 mm screw.

### B5. Installing the float

1. Float into the holder: thread through the 19.5 mm hole (plate 6 mm), sealing ring, nut. The thread is 19.5 mm long, leaving ~11 mm.
   **Mind the arrow** → switching direction "opens with water" ([einmessen.en.md](einmessen.en.md), section 3).
2. Cable with cable ties through the slots on the web.
3. Hang the holder with its hook over the rim of B's filler neck (neck wall 11.1 mm, inside 220.3 mm). The float points horizontally into the interior.
   **B stays without a cap**, because the outer leg of the hook sits over the thread.

### B6. Wi-Fi at the location

An outdoor AP is ~10 m away in line of sight. If problems are expected, test beforehand: D1 on a power bank at B, watch `IBC B WLAN-Signal` (Wi-Fi signal). On the PC it was −57 dBm, in HA most recently −55 to −63.
An external antenna (or a D1 mini Pro) is only bought if the result is poor.

---

## Part C: Pump and Home Assistant

1. Nous Zigbee plug under the roof or in a protective box, because it is an indoor device. Power-outage memory must stay **off**.
2. Plug in the pump, measure the normal power ([einmessen.en.md](einmessen.en.md), section 5).
3. Adapt `ha/ibc-pumpe.yaml` (power threshold) and deploy it (README section 8).

---

## Part D: Acceptance test

| # | Test | Expected result |
|---|---|---|
| 1 | Fill level A plausible (cross-check with folding rule) | deviation ≤ ~1 % |
| 2 | Node B reports regularly | `sensor.ibc_b_akku` new every ~15 min (`last_reported`) |
| 3 | Flip float B up (by hand) | "Zielcontainer voll" (target container full) on → with the pump running, immediately off + push. B is awake at this point because the pump is running. If B is asleep, this is only detected at the next wake-up |
| 4 | Disconnect the float cable | "voll" (full) = on, pump locked |
| 5 | Start the pump manually, power down node B | after > 180 s without a report: pump off + push |
| 6 | Run-time limit (shorten `for` in HA for testing) | after expiry off + lock + push; lock only released manually |
| 7 | Node A without power | after 15 min: pump off + push |
| 8 | Regular run A ≥ 90 % → ≤ 70 % | start at the next B wake-up, stop at 70 %, B sleeps again afterwards |
| 9 | Battery curve B over a few days | no steady decline in sunshine. Otherwise the quiescent current is too high, e.g. due to a bad shield batch |

Carry out tests 3–7 **before** the absence from 23.10., or leave the plug unplugged until November.
