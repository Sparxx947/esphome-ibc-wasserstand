// IBC-Wasserstand: Halter fuer Ultraschallsensor + Schwimmerschalter, Box fuer den D1 mini
// Stand 04.10.2026 — Notiz project_ibc_wasserstand.  Ueberdacht draussen → PETG reicht.
//
// TEIL = "kombi_gehaeuse" | "kombi_deckel" | "sensor_halter" | "sensor_abdeckung" | "d1_box" | "d1_deckel" | "schwimmer_halter" | "alle"
//
// ALLES MIT ★ VOR DEM DRUCK MESSEN (Masse sind noch nicht bekannt):
//   Sensor: Masse gemessen 07.10.; ★ s_koerper_h (Deutung 12,64) + Flanschgroesse gegen Deckelflaeche pruefen
//   Deckel A: IBC-Oberseite neben der Oeffnung: Ausschnitt 70 x 35 (Flanschfenster unten als Schablone anzeichnen)
//   ★ gewinde_d  Gewindedurchmesser des Schwimmerschalters, ★ haenge_tiefe Schalthoehe unter dem Deckelrand
//   ★ rand_t     Wandstaerke am Einfuellstutzen des Zielcontainers (dort haengt der Schwimmer-Halter ein)

TEIL = "alle";
$fn = 64;

// ---------- Ultraschall-Halter (Deckel von Container A) ----------
// A02YYUW = RECHTECKGEHAEUSE mit zwei Wandlern + zwei Laschen (nicht rund!).
// Gemessen 07.10.2026 (Jens, Messschieber), Datenblatt DFRobot SEN0311: 84,6 x 29,6 x 18,5
s_l      = 63.30;  // Koerper ohne Laschen
s_b      = 29.46;
s_ges_l  = 84.14;  // mit Laschen
s_ges_h  = 18.17;  // Gesamthoehe inkl. Wandler
s_koerper_h = 12.64; // Koerper OHNE Wandler (Jens bestaetigt 07.10.) → Wandler stehen ~5,5 vor
lasche_b = 12;     // ★ aus Foto geschaetzt (~10)
kabel_b  = 11;     // Kabeltuelle mittig an der Laengsseite
spiel    = 0.4;
// Fenster unter dem Koerper: beide Wandler (Ring ~19,5, Abstand ~37 — aus Foto geschaetzt) schauen hindurch,
// der Koerper liegt auf dem umlaufenden Rand. Ein Fenster statt zwei Loechern → Wandlerabstand egal.
fenster_l = 60; fenster_b = 25;
flansch_l = 104; flansch_b = 60; flansch_t = 4;   // Stelle neben der Oeffnung ist eben (Jens 07.10.)
wand = 2.2;
rahmen_h = s_koerper_h - 0.6;  // Abdeckung klemmt den Sensor leicht auf den Rand
ri_l = s_l + 2*spiel; ri_b = s_b + 2*spiel;
ra_l = ri_l + 2*wand; ra_b = ri_b + 2*wand;
dom_d = 8;  dom_pos = [[ra_l/2+1, ra_b/2+1],[-ra_l/2-1, ra_b/2+1],[ra_l/2+1,-ra_b/2-1],[-ra_l/2-1,-ra_b/2-1]];

module rrect(l, b, h, r=3) {
    hull() for (x=[-l/2+r, l/2-r], y=[-b/2+r, b/2-r]) translate([x,y,0]) cylinder(r=r, h=h);
}

module sensor_halter() {
    difference() {
        union() {
            rrect(flansch_l, flansch_b, flansch_t, 5);
            translate([0,0,flansch_t]) rrect(ra_l, ra_b, rahmen_h, 2);
            for (p=dom_pos) translate([p[0],p[1],0]) cylinder(d=dom_d, h=flansch_t + rahmen_h);
        }
        // Sensortasche
        translate([0,0,flansch_t]) rrect(ri_l, ri_b, rahmen_h + 1, 1);
        // Fenster fuer die Wandler, nach unten 45° aufgeweitet (keine Randechos)
        hull() {
            translate([0,0,flansch_t - 0.01]) rrect(fenster_l, fenster_b, 0.02, 2);
            translate([0,0,-0.01]) rrect(fenster_l + 2*flansch_t, fenster_b + 2*flansch_t, 0.02, 2);
        }
        // Aussparungen fuer die Laschen an den Stirnseiten (volle Hoehe, Laschenebene unbekannt)
        for (sx=[-1,1]) translate([sx*(ra_l/2), 0, flansch_t + rahmen_h/2 + 0.01]) cube([wand*3, lasche_b, rahmen_h], center=true);
        // Kabeltuelle (mittig an einer Laengsseite)
        translate([0, ra_b/2, flansch_t + rahmen_h/2 + 0.01]) cube([kabel_b, wand*3, rahmen_h], center=true);
        // Schraubdome: 2,5 mm Vorbohrung fuer Blechschrauben 3 x 16 (Abdeckung)
        for (p=dom_pos) translate([p[0],p[1],flansch_t]) cylinder(d=2.5, h=rahmen_h + 1);
        // 4 Befestigungsloecher M4 in den Deckel (zusaetzlich Silikon/Sikaflex zwischen Flansch und Deckel)
        for (x=[-flansch_l/2+7, flansch_l/2-7], y=[-flansch_b/2+7, flansch_b/2-7]) translate([x,y,-1]) cylinder(d=4.4, h=flansch_t + 2);
    }
}

// Abdeckung: klemmt den Sensor in die Tasche und schuetzt die Rueckseite vor Tropfwasser
module sensor_abdeckung() {
    t = 2.4;
    difference() {
        hull() for (p=dom_pos) translate([p[0],p[1],0]) cylinder(d=dom_d, h=t);
        for (p=dom_pos) translate([p[0],p[1],-1]) cylinder(d=3.4, h=t + 2);
        // Kabeltuelle nicht einklemmen
        translate([0, ra_b/2, 0]) cube([kabel_b, 6, 10], center=true);
    }
}

// ---------- KOMBI-GEHAEUSE: Sensor + D1 mini in einem (07.10.2026) ----------
// Sensorkammer (Fenster nach unten) und D1-Kammer nebeneinander, getrennt durch eine Wand mit Kabelschlitz.
// WICHTIG: Sensor mit einer Silikonraupe auf den Auflagerand setzen → feuchte Tankluft bleibt aus der D1-Kammer.
// Kabel (USB-Strom angeloetet an 5V/G, Schwimmer) durch 2 Verschraubungen M12x1,5 in der Aussenwand.
k_h    = 24;                    // Innenhoehe ueber dem Boden
k_w    = 2.4;                   // Wandstaerke
k_il   = s_ges_l + 2;           // innen Laenge: Sensor MIT Laschen
k_sy0  = -ri_b/2;               // Sensorkammer y-Bereich
k_sy1  =  ri_b/2;
k_ty   = 2.2;                   // Trennwand
k_dy1  = k_sy1 + k_ty + 42;     // D1-Kammer bis hier
k_rand = 10;                    // Flansch rundum (Schrauben in die IBC-Oberseite)
k_m12  = 12.3;
k_m12_wand = 3;   // Wandstaerke an den Verschraubungen
k_dom  = 8;
function k_dome() = [for (x=[-k_il/2-k_w, k_il/2+k_w], y=[k_sy0-k_w, k_dy1+k_w]) [x,y]];

module k_box_aussen(h) {
    hull() {
        translate([-k_il/2-k_w, k_sy0-k_w, 0]) cube([k_il+2*k_w, k_dy1-k_sy0+2*k_w, h]);
        for (p=k_dome()) translate([p[0],p[1],0]) cylinder(d=k_dom, h=h);
    }
}

module kombi_gehaeuse() {
    fx0 = -k_il/2-k_w-k_rand; fx1 = -fx0;
    fy0 = k_sy0-k_w-k_rand;   fy1 = k_dy1+k_w+k_rand;
    difference() {
        union() {
            // Flansch = Boden
            translate([(fx0+fx1)/2, (fy0+fy1)/2, 0]) rrect(fx1-fx0, fy1-fy0, flansch_t, 5);
            translate([0,0,flansch_t]) k_box_aussen(k_h);
        }
        // Innenraum
        translate([-k_il/2, k_sy0, flansch_t]) cube([k_il, k_dy1-k_sy0, k_h+1]);
        // Fenster fuer die Wandler, nach unten 45° aufgeweitet
        hull() {
            translate([0,0,flansch_t - 0.01]) rrect(fenster_l, fenster_b, 0.02, 2);
            translate([0,0,-0.01]) rrect(fenster_l + 2*flansch_t, fenster_b + 2*flansch_t, 0.02, 2);
        }
        // Schraubloecher Deckel (Blechschraube 3 x 16)
        for (p=k_dome()) translate([p[0],p[1],flansch_t+k_h-14]) cylinder(d=2.5, h=15);
        // Befestigung auf dem IBC: 4 x Edelstahl-Blechschraube 4,2 (im IBC 3,2 vorbohren)
        for (x=[fx0+5.5, fx1-5.5], y=[fy0+5.5, fy1-5.5]) translate([x,y,-1]) cylinder(d=4.4, h=flansch_t+2);
        // 2 Kabelverschraubungen M12 in der Aussenwand der D1-Kammer
        for (x=[-22, 22]) translate([x, k_dy1-1, flansch_t+11]) rotate([-90,0,0]) cylinder(d=k_m12, h=k_w+8);   // Wand ist durch die Eckdome ~6,4 dick
        // Innen ausgespart auf k_m12_wand Reststaerke, damit Standard-Verschraubungen (Gewinde 8 mm) samt Mutter fassen
        for (x=[-22, 22]) translate([x, k_dy1-0.01, flansch_t+11]) rotate([-90,0,0]) cylinder(d=22, h=k_w + 4 - k_m12_wand);
        // Belueftung/Kondenswasser: 2-mm-Loch unten in der Stirnwand der D1-Kammer
        translate([k_il/2-1, k_dy1-6, flansch_t+1.2]) rotate([0,90,0]) cylinder(d=2, h=k_w+8);
    }
    // Trennwand mit Kabelschlitz (mittig, fuer die Kabeltuelle des Sensors)
    difference() {
        translate([-k_il/2, k_sy1, flansch_t]) cube([k_il, k_ty, k_h]);
        translate([-kabel_b/2, k_sy1-1, flansch_t+2]) cube([kabel_b, k_ty+2, k_h]);
        // Platz fuer die Deckellippe an beiden Enden
        for (sx=[-1,1]) translate([sx>0 ? k_il/2-2.2 : -k_il/2-0.01, k_sy1-1, flansch_t+k_h-3.6]) cube([2.21, k_ty+2, 4]);
    }
    // Anschlaege an den Sensor-Stirnseiten (Laschen bleiben frei)
    for (sx=[-1,1], sy=[-1,1]) {
        y0 = sy<0 ? k_sy0 : lasche_b/2;
        translate([sx>0 ? ri_l/2 : -ri_l/2-2, y0, flansch_t]) cube([2, ri_b/2 - lasche_b/2, 5]);
    }
    // Auflageleisten fuer den D1 mini (34,2 x 25,6), Platine mit Doppelklebeband/Heisskleber fixieren
    dy0 = k_sy1 + k_ty + 2;
    for (y=[dy0, dy0 + d1_b + 2*d1_spiel - 2]) translate([-(d1_l+2*d1_spiel)/2, y, flansch_t]) cube([d1_l+2*d1_spiel, 2, 3]);
}

module kombi_deckel() {
    t = 2.4; lip_h = 3; lip_w = 1.4; sp = 0.35;
    difference() {
        k_box_aussen(t);
        for (p=k_dome()) translate([p[0],p[1],-1]) cylinder(d=3.4, h=t+2);
    }
    // umlaufende Lippe nach unten (in den Innenraum) gegen Schlagregen — Trennwand bekommt Aussparung
    translate([0,0,-lip_h]) difference() {
        translate([-k_il/2+sp, k_sy0+sp, 0]) cube([k_il-2*sp, k_dy1-k_sy0-2*sp, lip_h]);
        translate([-k_il/2+sp+lip_w, k_sy0+sp+lip_w, -1]) cube([k_il-2*sp-2*lip_w, k_dy1-k_sy0-2*sp-2*lip_w, lip_h+2]);
    }
    // zwei Druckrippen auf den Sensorruecken (0,4 mm Vorspannung)
    rippe = k_h - s_koerper_h + 0.4;
    for (x=[-20, 20]) translate([x-1, -ri_b/2+3, -rippe]) cube([2, ri_b-6, rippe]);
}

// ---------- Box fuer Wemos D1 mini (34,2 x 25,6 mm) ----------
d1_l = 35.2; d1_b = 26.6; d1_spiel = 0.6;
bw = 1.8; bb = 1.8;
box_ih = 18;
il = d1_l + 2*d1_spiel + 14;   // + Platz fuer Klemmen/Kabel
ib = d1_b + 2*d1_spiel + 6;
al = il + 2*bw; ab = ib + 2*bw; ah = bb + box_ih;
kabel_d = 6;    // je ein Kabel: Sensor, Schwimmer, USB-Strom — alle UNTEN raus (Tropfwasser)

module d1_box() {
    difference() {
        hull() for (x=[2, al-2], y=[2, ab-2]) translate([x,y,0]) cylinder(r=2, h=ah);
        translate([bw, bw, bb]) cube([il, ib, box_ih + 1]);
        // drei Kabeldurchfuehrungen in der Unterseite (Boden), versetzt
        for (i=[0:2]) translate([bw + 10 + i*((il-20)/2), ab/2, -1]) cylinder(d=kabel_d, h=bb + 2);
        // Kondenswasser-Ablauf in der tiefsten Ecke
        translate([bw + 3, bw + 3, -1]) cylinder(d=2, h=bb + 2);
    }
    // D1-Auflageleisten (Platine liegt flach, Stiftleisten nach oben loeten)
    for (y=[bw, bw + ib - 2]) translate([bw + il - d1_l - 2*d1_spiel, y, bb]) cube([d1_l + 2*d1_spiel, 2, 3]);
    // Montagelaschen
    for (x=[-7, al]) translate([x, ab/2 - 6, 0]) difference() {
        cube([7, 12, 3]);
        translate([3.5, 6, -1]) cylinder(d=4.2, h=5);
    }
}

module d1_deckel() {
    difference() {
        union() {
            hull() for (x=[2, al-2], y=[2, ab-2]) translate([x,y,0]) cylinder(r=2, h=1.8);
            translate([bw+0.25, bw+0.25, 1.8]) difference() {
                cube([il-0.5, ib-0.5, 3]);
                translate([1.4,1.4,-1]) cube([il-0.5-2.8, ib-0.5-2.8, 5]);
            }
        }
    }
}

// ---------- Schwimmer-Halter (Zielcontainer, haengt im Einfuellstutzen) ----------
gewinde_d    = 19;    // gemessen 07.10. (Loch = gewinde_d + 0,5); Schwimmer steht 49,3 mm ab
haenge_tiefe = 120;   // Stutzenrand → Schaltpunkt (Jens 07.10.; Schwimmer schaltet etwa auf Lochhoehe)
rand_t       = 11.1;  // Wandstaerke Stutzen B (gemessen 07.10.; Stutzen innen 220,3)
steg_b = 32; steg_t = 5;   // 32 breit: Mutter des 19-mm-Gewindes braucht Auflage

module schwimmer_halter() {
    // flach liegend gedruckt: x = Laenge nach unten, y = Breite, z = Dicke
    difference() {
        union() {
            // senkrechter Steg
            cube([haenge_tiefe + 20, steg_b, steg_t]);
            // Haken oben: geht ueber den Stutzenrand nach aussen
            translate([-steg_t, 0, 0]) cube([steg_t, steg_b, steg_t + rand_t + 0.8 + steg_t]);   // 0,8 Luft am Rand
            translate([-steg_t, 0, steg_t + rand_t + 0.8]) cube([18, steg_b, steg_t]);
            // Platte unten fuer den Schwimmerschalter (verstaerkt)
            translate([haenge_tiefe - 20, 0, 0]) cube([40, steg_b, steg_t + 1]);   // 6 mm: Gewinde muss Platte + Dichtung + Mutter fassen
        }
        // Loch fuer das Schwimmer-Gewinde (quer durch Steg, Schwimmer zeigt waagrecht in den Behaelter)
        translate([haenge_tiefe, steg_b/2, -1]) cylinder(d=gewinde_d + 0.5, h=steg_t + 5);
        // Kabelklemmen-Schlitze entlang des Stegs
        for (x=[20:30:haenge_tiefe-30]) translate([x, 3, -1]) cube([3.5, 1.8, steg_t + 2]);
    }
}

if (TEIL=="sensor_halter") sensor_halter();
if (TEIL=="sensor_abdeckung") sensor_abdeckung();
if (TEIL=="kombi_gehaeuse") kombi_gehaeuse();
if (TEIL=="kombi_deckel") rotate([180,0,0]) kombi_deckel();   // Druck: Deckelplatte unten
if (TEIL=="kombi_zusammen") { kombi_gehaeuse(); %translate([0,0,flansch_t+k_h]) kombi_deckel(); }
if (TEIL=="d1_box") d1_box();
if (TEIL=="d1_deckel") d1_deckel();
if (TEIL=="schwimmer_halter") schwimmer_halter();
if (TEIL=="alle") {
    sensor_halter();
    translate([0, 60, 0]) sensor_abdeckung();
    translate([65, -25, 0]) d1_box();
    translate([65, 25, 0]) d1_deckel();
    translate([-30, -90, 0]) schwimmer_halter();
}
