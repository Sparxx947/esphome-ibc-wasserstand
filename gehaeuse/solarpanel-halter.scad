// Halter fuer das Solarpanel des IBC-Knotens B: Seeed „DEBO SOLAR 1.0W“ (reichelt, Seeed 313070005)
// Stand 21.10.2026.  PETG/ASA, haengt aussen am Holz des Schuppens.
//
// Aufbau (drei Teile):
//   keil    Wandkeil — wird mit 4 Holzschrauben 4 x 30 aufs Holz geschraubt, neigt das Panel um `neigung` von der Wand weg
//   rahmen  Panel-Rahmen — Panel wird von OBEN eingeschoben, liegt vorn hinter Seitenlippen; dahinter eine geschlossene
//           Kammer (Loetstelle/Wago Panel-Litze ↔ Aussenkabel), Kabel unten raus, Ablaufloecher unten.
//           Einschub-Nut im Kopfblock (nut_b x nut_t): die Anschluesse auf der Panel-Rueckseite gleiten beim Einschieben hindurch
//   riegel  Deckel oben — haelt das Panel im Schlitz und deckt den Schlitz gegen Regen ab (2 Schrauben 3 x 12)
//
// Montage: Keil an die Wand → Rahmen mit 4 Schrauben 3 x 12 von innen (aus der Kammer) auf den Keil →
//          Kabel von unten durch die Kammer nach oben, anschliessen → Panel einschieben, Kabel unten nachziehen → Riegel drauf.
//
// TEIL = "keil" | "rahmen" | "riegel" | "alle" (Druckplatte) | "zusammen" (Ansicht eingebaut)
//        | "pruef_rahmen_keil" | "pruef_riegel_rahmen" | "pruef_einschub" (Kollisionspruefung: Schnittmenge muss LEER sein)
//
// Panelmasse: 100 x 80 mm (Datenblatt, nachgemessen), Dicke 2,33 mm gemessen → pt = 2.35.
// Die Kammer hat 11 mm Tiefe (Wago 221-412 liegend 8,2 mm oder Loetstelle + Schrumpfschlauch).
// Weiter unten steht eine Variante B (Panel von vorn, kasten/blende). Sie wird NICHT gebraucht, bleibt als Alternative.

TEIL = "alle";
$fn = 64;

// ---------- Panel ----------
pl = 100;     // ★ Laenge (laengs der Neigung, Kabel-Seite unten)
pb = 80;      // ★ Breite
pt = 2.35;    // Dicke: gemessen 2,33 mm (Jens, 20.10.2026)
spiel = 0.6;  // Spiel in Laenge/Breite
spiel_t = 0.5;// Spiel in der Dicke

// ---------- Neigung ----------
neigung = 30; // Grad von der (senkrechten) Wand weg → Panel 60° zur Waagerechten (Winter-Optimum in Mitteleuropa)

// ---------- Rahmen ----------
w      = 2.4;   // Seitenwand
rb     = 2.4;   // Rueckwand
kt     = 11;    // Kammertiefe hinter dem Panel
steg   = 3;     // Auflage des Panels auf der Kammerwand (links/rechts/unten)
lippe  = 2.5;   // Lippe vorn ueber dem Panelrand (links/rechts)
lippe_t= 2;     // Dicke der Lippe
ub     = 3;     // Bodenwand unten
ob     = 10;    // Kopfblock oben (hier greifen die Riegelschrauben)
kabel_d= 7.5;   // Kabeldurchfuehrung unten (H05RN-F 2 x 0,75: Ø 6–7,4) — mit Silikon abdichten
ablauf_d = 3.5; // Ablaufloecher unten in der Kammer
nut_b  = 20;    // Einschub-Nut Breite (Loetpunkte + Litze + Kleber mittig, Breite ungemessen)
nut_t  = 9.5;   // Einschub-Nut Tiefe hinter dem Schlitz (Wago 221-412 liegend 8,2 mm)
nase   = 8;     // Breite der drei Nasen vorn unten (dazwischen laeuft das Regenwasser ab)

sb = pb + spiel;              // Schlitz-Breite
sl = pl + spiel;              // Schlitz-Laenge
st = pt + spiel_t;            // Schlitz-Dicke
ra = sb + 2*w;                // Rahmen aussen Breite
rl = ub + sl + ob;            // Rahmen aussen Laenge (ohne Riegel)
z_schlitz = rb + kt;          // Schlitz beginnt hier (Panel-Rueckseite)
rt = z_schlitz + st + lippe_t;// Rahmen aussen Tiefe

kam_b = sb - 2*steg;          // Kammer innen Breite
kam_y0 = ub + steg;           // Kammer unten
kam_y1 = ub + sl;             // Kammer oben (= Kopfblock)

befest = [for (x=[-20,20], y=[rl*0.28, rl*0.72]) [x,y]];   // Rahmen ↔ Keil, Schraube 3 x 12 von innen
riegel_x = [-28, 28];

// ---------- Riegel ----------
rg_t = 3;           // Plattendicke
zunge_l = 7;        // Zunge ragt so weit in den Schlitz (haelt das Panel unten)
zunge_b = 50;

// ---------- Keil ----------
kw = 4;             // Wand-/Montageplatte/Wangen
lasche = 22;        // Laschen oben/unten fuer die Holzschrauben
holz_d = 4.5; holz_senk = 9;   // Holzschraube 4 x 30 Senkkopf
kh = rl * cos(neigung);         // Keilhoehe an der Wand
kz = rl * sin(neigung);         // Keiltiefe unten

module rahmen() {
    difference() {
        translate([-ra/2, 0, 0]) cube([ra, rl, rt]);
        // Schlitz fuer das Panel (oben offen)
        translate([-sb/2, ub, z_schlitz]) cube([sb, rl, st]);
        // Fenster vorn (Lippen links/rechts, unten nur drei Nasen → Wasser laeuft ab)
        translate([-(sb/2 - lippe), ub + 5, z_schlitz]) cube([sb - 2*lippe, rl, rt]);
        // Ablauf-Luecken zwischen den drei Nasen unten: gehen bis durch die Bodenwand, Sohle 1 mm ueber der
        // Panel-Rueckseite → Regen vom Panel laeuft unten frei ab, das Panel steht trotzdem auf der Bodenwand
        for (x0=[-(sb/2 - lippe) + nase, nase/2]) translate([x0, -0.01, z_schlitz + 1])
            cube([(sb - 2*lippe)/2 - 1.5*nase, ub + 5.02, rt]);
        // Kammer hinter dem Panel
        translate([-kam_b/2, kam_y0, rb]) cube([kam_b, kam_y1 - kam_y0, kt + 0.01]);
        // Einschub-Nut (21.10.): die Loetpunkte/Litze sitzen MITTIG hinten am Panel → beim Einschieben von oben
        // laufen sie hier durch den Kopfblock; gross genug fuer Wago 221-412 / Loetstelle, damit das Kabel
        // VON UNTEN durch die Kammer nach oben gefuehrt, angeschlossen und beim Einschieben nachgezogen werden kann
        translate([-nut_b/2, kam_y1 - 0.01, z_schlitz - nut_t]) cube([nut_b, ob + 0.02, nut_t + 0.01]);
        // Freistich im unteren Auflagerand fuer die flachen Anschlussbaender
        translate([-nut_b/2, ub - 0.01, rb]) cube([nut_b, steg + 0.02, kt + 0.01]);
        // Kabel unten raus (mittig) + zwei Ablaufloecher
        translate([0, -0.01, rb + kt/2]) rotate([-90,0,0]) cylinder(d=kabel_d, h=ub + steg + 0.02);
        for (x=[-kam_b/2 + 4, kam_b/2 - 4])
            translate([x, -0.01, rb + ablauf_d/2 + 0.6]) rotate([-90,0,0]) cylinder(d=ablauf_d, h=ub + steg + 0.02);
        // Befestigung am Keil: Durchgang 3,4 + Kopfsenkung von innen
        for (p=befest) translate([p[0], p[1], -0.01]) {
            cylinder(d=3.4, h=rb + 0.02);
            translate([0,0,rb - 1.2]) cylinder(d1=3.4, d2=6.2, h=1.21);
        }
        // Riegelschrauben: Vorbohrung 2,5 von oben in den Kopfblock
        for (x=riegel_x) translate([x, rl - ob + 0.5, z_schlitz/2]) rotate([-90,0,0]) cylinder(d=2.5, h=ob);
    }
}

module riegel() {   // Lage wie eingebaut: liegt auf der Oberkante des Rahmens
    difference() {
        union() {
            translate([-ra/2, rl, 0]) cube([ra, rg_t, rt]);
            // Zunge in den Schlitz
            translate([-zunge_b/2, rl - zunge_l, z_schlitz + 0.25]) cube([zunge_b, zunge_l + 0.01, st - 0.5]);
        }
        for (x=riegel_x) translate([x, rl - 0.01, z_schlitz/2]) rotate([-90,0,0]) {
            cylinder(d=3.4, h=rg_t + 0.02);
            translate([0,0,rg_t - 1.6]) cylinder(d1=3.4, d2=6.4, h=1.61);
        }
    }
}

// Lage des Rahmens auf dem Keil (Wand = Ebene z=0, y nach oben)
module auf_keil() { translate([0, 0, kw + kz]) rotate([-neigung, 0, 0]) children(); }

// Keil = ein durchgehendes Profil (Wandplatte + Montageplatte + 2 Querstege), Profil in der y/z-Ebene,
// in x ueber die Rahmenbreite gezogen → gedruckt AUF DER SEITE (Profil auf dem Bett), keine Ueberhaenge.
// Eingebaut liegen die Querstege waagerecht unter dem Rahmen (Regen erreicht sie nicht, Keil unten offen).
steg_k = 3;
module keil_profil() {   // 2D: [y (hoch), z (von der Wand weg)]
    aussen = function(y) kw + (kh - y) * tan(neigung);       // Aussenflaeche Montageplatte
    innen  = function(y) aussen(y) - kw / cos(neigung);
    union() {
        translate([-lasche, 0]) square([kh + 2*lasche, kw]);                       // Wandplatte + Laschen
        polygon([[0, innen(0)], [0, aussen(0)], [kh, aussen(kh)], [kh, kw - 1], [kh - (kw/cos(neigung) - 1)/tan(neigung), kw - 1]]);     // Montageplatte
        for (y=[kh*0.12, kh*0.55]) translate([y, 0]) square([steg_k, aussen(y + steg_k) - 1]);  // Querstege
    }
}

module keil() {
    difference() {
        translate([-ra/2, 0, 0]) rotate([90,0,90]) linear_extrude(ra) keil_profil();
        // Holzschrauben (Senkkopf vorn)
        for (x=[-ra/2 + 12, ra/2 - 12], y=[-lasche/2, kh + lasche/2 + 2]) translate([x, y, -0.01]) {
            cylinder(d=holz_d, h=kw + 0.02);
            translate([0,0,kw - (holz_senk - holz_d)/2]) cylinder(d1=holz_d, d2=holz_senk, h=(holz_senk - holz_d)/2 + 0.02);
        }
        // Vorbohrungen fuer die Rahmenschrauben 3 x 12
        auf_keil() for (p=befest) translate([p[0], p[1], -kw - 6]) cylinder(d=2.5, h=kw + 6.01);
        // Mittelrippe bei den Vorbohrungen freistellen ist nicht noetig (x = ±20)
    }
}

module eingebaut() {
    color("sienna") keil();
    auf_keil() { color("lightgray") rahmen(); color("gray") riegel();
                 %translate([-pb/2, ub + spiel/2, z_schlitz + spiel_t/2]) cube([pb, pl, pt]); }
}

if (TEIL=="keil")   translate([0,0,ra/2]) rotate([0,-90,0]) keil();                       // Druck: AUF DER SEITE, Profil auf dem Bett
if (TEIL=="rahmen") rahmen();                                       // Druck: Rueckwand unten (wie modelliert)
if (TEIL=="riegel") translate([0, 0, rl + rg_t]) rotate([-90,0,0]) riegel();  // Druck: Platte unten, Zunge oben
if (TEIL=="alle") {
    translate([-ra/2 - 20, 0, ra/2]) rotate([0,-90,0]) keil();
    translate([ra + 15, 0, 0]) rahmen();
    translate([2*(ra + 15), 0, rl + rg_t]) rotate([-90,0,0]) riegel();
}
if (TEIL=="zusammen") eingebaut();
if (TEIL=="pruef_rahmen_keil")   intersection() { keil(); auf_keil() rahmen(); }
if (TEIL=="pruef_riegel_rahmen") intersection() { riegel(); rahmen(); }

// =====================================================================================================
// VARIANTE B (21.10.2026): Panel wird VON VORNE eingelegt, Blende darueber geschraubt.
// Grund: Das Seeed-Panel hat seine Loetpunkte (+/−) mit Litze und Klebe-Raupe MITTIG auf der Rueckseite
// (2–4 mm hoch, Tinytronics-Foto + Jens) — beim Einschieben von oben wuerden sie am Kopfblock abgeschert.
// Teile: kasten (ersetzt rahmen) + blende (ersetzt riegel). Der KEIL BLEIBT UNVERAENDERT: Kasten-Laenge = rl,
// Befestigungsloecher = befest (gleiche Lage) → bereits gedruckter Keil passt.
// Montage: Keil an die Wand → Kasten mit 4× 3×12 von innen auf den Keil → Kabel durch die Verschraubung unten,
//          in der Kammer anschliessen (Wago/Loetstelle) → duenne Silikonraupe auf den Auflagerand → Panel einlegen
//          → Blende mit 6× 3×12 (Blech-/Kunststoffschraube) drauf.
// TEIL = "kasten" | "blende" | "alle_b" | "zusammen_b" | "pruef_kasten_keil" | "pruef_blende_kasten" | "pruef_panel_kasten"
wb      = 6;                    // Seitenwand Kasten (traegt die Blendenschrauben)
wl      = (rl - sl) / 2;        // Stirnwand oben/unten → Kastenlaenge = rl (Keil passt)
tasche  = pt + 0.2;             // Panel-Tasche: Panel liegt auf dem Rand, Blende drueckt es leicht an
bl_t    = 2.5;                  // Blendendicke
bl_lip  = 2.5;                  // Blende ueberdeckt den Panelrand (links/rechts/oben)
kb_a    = sb + 2*wb;            // Kasten aussen Breite
kb_t    = rb + kt + tasche;     // Kasten aussen Tiefe (ohne Blende)
bl_schr = [for (x=[-1,1], y=[rl*0.15, rl*0.5, rl*0.85]) [x*(sb/2 + wb/2), y]];
// Rueckseiten-Buckel des Panels fuer die Kollisionspruefung (Loetpunkte + Litze + Kleber, grosszuegig)
buckel  = [40, 30, 5];          // L x B x H, mittig
band_b  = 16;                   // Breite Freistich fuer die flachen Anschlussbaender (Breite ungemessen, grosszuegig)

module kasten() {
    difference() {
        translate([-kb_a/2, 0, 0]) cube([kb_a, rl, kb_t]);
        // Panel-Tasche (vorne offen)
        translate([-sb/2, wl, rb + kt]) cube([sb, sl, tasche + 0.01]);
        // Kammer hinter dem Panel (Rand `steg` ringsum als Auflage)
        translate([-kam_b/2, wl + steg, rb]) cube([kam_b, sl - 2*steg, kt + 0.01]);
        // Freistich im Auflagerand oben + unten mittig: dort laufen die flachen Anschlussbaender des Panels
        // von den kurzen Seiten zu den Loetpunkten (Jens 21.10.) — Panel liegt nicht auf ihnen auf
        for (y0=[wl - 0.01, wl + sl - steg]) translate([-band_b/2, y0, rb]) cube([band_b, steg + 0.02, kt + 0.01]);
        // Ablauf der Tasche: zwei Schlitze durch die untere Stirnwand, Sohle = Panel-Auflage
        for (x0=[-(sb/2 - bl_lip) + nase, nase/2]) translate([x0, -0.01, rb + kt])
            cube([(sb - 2*bl_lip)/2 - 1.5*nase, wl + 0.02, tasche + 0.01]);
        // Kabel unten raus (mittig, M12-taugliche Bohrung wie bisher) + zwei Ablaufloecher der Kammer
        translate([0, -0.01, rb + kt/2]) rotate([-90,0,0]) cylinder(d=kabel_d, h=wl + steg + 0.02);
        for (x=[-kam_b/2 + 4, kam_b/2 - 4])
            translate([x, -0.01, rb + ablauf_d/2 + 0.6]) rotate([-90,0,0]) cylinder(d=ablauf_d, h=wl + steg + 0.02);
        // Befestigung am Keil (identisch zu rahmen())
        for (p=befest) translate([p[0], p[1], -0.01]) {
            cylinder(d=3.4, h=rb + 0.02);
            translate([0,0,rb - 1.2]) cylinder(d1=3.4, d2=6.2, h=1.21);
        }
        // Vorbohrungen fuer die Blendenschrauben
        for (p=bl_schr) translate([p[0], p[1], kb_t - 11]) cylinder(d=2.5, h=11.01);
    }
}

module blende() {   // Lage wie eingebaut: liegt vorn auf dem Kasten
    difference() {
        translate([-kb_a/2, 0, kb_t]) cube([kb_a, rl, bl_t]);
        // Fenster: links/rechts/oben Lippe, unten offen bis auf drei Nasen (Regen laeuft ab)
        translate([-(sb/2 - bl_lip), -0.01, kb_t - 0.01]) cube([sb - 2*bl_lip, wl + sl - bl_lip + 0.01, bl_t + 0.02]);
        for (p=bl_schr) translate([p[0], p[1], kb_t - 0.01]) {
            cylinder(d=3.4, h=bl_t + 0.02);
            translate([0,0,bl_t - 1.6]) cylinder(d1=3.4, d2=6.4, h=1.61);
        }
    }
    // drei Nasen unten halten die Panel-Unterkante
    for (x=[-(sb/2 - bl_lip), -nase/2, (sb/2 - bl_lip) - nase]) translate([x, 0, kb_t]) cube([nase, wl + bl_lip, bl_t]);
}

module panel_dummy() {
    translate([-pb/2, wl + spiel/2, rb + kt]) cube([pb, pl, pt]);
    translate([-buckel[1]/2, wl + spiel/2 + pl/2 - buckel[0]/2, rb + kt - buckel[2]]) cube([buckel[1], buckel[0], buckel[2] + 0.01]);
    translate([-4, wl + spiel/2, rb + kt - 1]) cube([8, pl, 1.01]);   // flache Baender kurze Seite ↔ Mitte (8 x 1 mm angenommen)
}

if (TEIL=="kasten") kasten();                                                    // Druck: Rueckwand unten
if (TEIL=="blende") translate([0, 0, kb_t + bl_t]) rotate([180,0,0]) blende();  // Druck: Sichtseite unten
if (TEIL=="alle_b") { kasten(); translate([kb_a + 10, rl, kb_t + bl_t]) rotate([180,0,0]) blende(); }
if (TEIL=="zusammen_b") { color("sienna") keil(); auf_keil() { color("lightgray") kasten(); color("gray") blende(); %panel_dummy(); } }
if (TEIL=="pruef_kasten_keil")   intersection() { keil(); auf_keil() kasten(); }
if (TEIL=="pruef_blende_kasten") intersection() { blende(); kasten(); }
if (TEIL=="pruef_panel_kasten")  intersection() { panel_dummy(); union() { kasten(); blende(); } }

// Einschub-Pruefung Variante A: Rueckseiten-Buckel (14 breit x 5 hoch, laengs 40) auf dem ganzen Weg von oben
// bis in die Endlage — Schnittmenge mit dem Rahmen muss LEER sein
ein_buckel = [14, 40, 5];
if (TEIL=="pruef_einschub") intersection() {
    rahmen();
    hull() for (dy=[0, rl]) translate([-ein_buckel[0]/2, ub + spiel/2 + pl/2 - ein_buckel[1]/2 + dy, z_schlitz + spiel_t/2 - ein_buckel[2]])
        cube([ein_buckel[0], ein_buckel[1], ein_buckel[2]]);
}
