// IBC Container B: Solar-Knoten — Gehaeuse fuer 18650 Battery Shield V3 (rechtes, ohne USB-Buchse) + Wemos D1 mini
// Stand 07.10.2026 — Notiz project_ibc_wasserstand.  PETG, ueberdacht/aussen am Kaefig von B.
//
// Lage beim Einbau: Gehaeuse HAENGT senkrecht am Kaefig, die Stirnwand mit den Verschraubungen zeigt NACH UNTEN
// (Tropfwasser laeuft ab), Deckel zeigt nach vorn.  Gedruckt wird liegend (Boden auf dem Bett).
//
// TEIL = "gehaeuse" | "deckel" | "alle"
//
// Shield-Masse gemessen 07.10.2026 (vorher geschaetzt):
//   ★ sh_l, sh_b  Shield-Platine (ohne USB-A-Buchse), ★ sh_usb Ueberstand der USB-A-Buchse
//   ★ sh_h        Hoehe Shield + eingelegter Akku (Unterseite Bauteile bis Oberkante Akku)

TEIL = "alle";
$fn = 64;

// ---------- Inhalt ----------
sh_l = 99.28; sh_b = 29.46; sh_usb = 6.74; sh_h = 25;   // gemessen 07.10. (Jens)
d1_l = 34.2; d1_b = 25.6;                             // Wemos D1 mini (bekannt)
spiel = 0.6;

// ---------- Gehaeuse ----------
w      = 3;      // Wand = 3 mm → Standard-M12-Verschraubung (Gewinde ~8 mm) samt Mutter fasst
boden  = 2.4;
il = 124;        // innen Laenge: Mutterzone 12 + Shield 98 + USB 6 + Eckdome
ib = 68;         // innen Breite: Shield 30 | Luft | D1 mini 26,6
ih = 30;         // innen Hoehe (★ sh_h + Leisten 3 + Luft)
al = il + 2*w; ab = ib + 2*w; ah = boden + ih;
dom_d = 7;  dom_loch = 2.5;   // Blechschraube 3 x 12 fuer den Deckel
m12 = 12.3;  m12_z = boden + 13;  m12_y = 15;   // zwei Verschraubungen: Schwimmer | Panel
lasche_l = 14;

function dome() = [for (sx=[-1,1], sy=[-1,1]) [sx*(il/2 - dom_d/2), sy*(ib/2 - dom_d/2)]];

module rbox(l, b, h, r=3) { hull() for (x=[-l/2+r, l/2-r], y=[-b/2+r, b/2-r]) translate([x,y,0]) cylinder(r=r, h=h); }

module gehaeuse() {
    difference() {
        union() {
            rbox(al, ab, ah, 3);
            // Befestigungslaschen oben und unten (Kabelbinder um die Kaefigstrebe oder Schraube 4 mm)
            for (sx=[-1,1]) translate([sx*(al/2 + lasche_l/2 - 2), 0, 0]) rbox(lasche_l + 4, 34, 4, 3);
        }
        translate([-il/2, -ib/2, boden]) cube([il, ib, ih + 1]);
        // M12 in der unteren Stirnwand (x = -), Wand 3 mm
        for (y=[-m12_y, m12_y]) translate([-al/2 - 1, y, m12_z]) rotate([0,90,0]) cylinder(d=m12, h=w + 2);
        // Kondenswasser-Ablauf ganz unten in der Stirnwand
        translate([-al/2 - 1, 0, boden + 1.2]) rotate([0,90,0]) cylinder(d=2.5, h=w + 2);
        // Laschen: Loch 4,5 + Schlitz fuer Kabelbinder (bis 5 mm breit)
        for (sx=[-1,1]) {
            translate([sx*(al/2 + lasche_l/2), 0, -1]) cylinder(d=4.5, h=6);
            for (y=[-11, 11]) translate([sx*(al/2 + lasche_l/2) - 1.5, y - 3, -1]) cube([3, 6, 6]);
        }
    }
    // Eckdome fuer die Deckelschrauben
    for (p=dome()) translate([p[0], p[1], boden]) difference() {
        cylinder(d=dom_d, h=ih);
        translate([0,0,ih - 12]) cylinder(d=dom_loch, h=13);
    }
    // Shield: zwei Laengsleisten (Bauteile auf der Unterseite bleiben frei); Fixierung mit Klebepad/Heisskleber
    sh_x0 = -il/2 + 14;                       // 14 mm Mutterzone vor den Verschraubungen frei
    sh_y0 = -ib/2 + 2;
    for (y=[sh_y0, sh_y0 + sh_b + 2*spiel - 2]) translate([sh_x0, y, boden]) cube([sh_l + 2*spiel, 2, 3]);
    // Anschlag am oberen Ende (USB-A-Seite)
    translate([sh_x0 + sh_l + sh_usb + 2*spiel, sh_y0, boden]) cube([2, sh_b, 6]);
    // D1 mini: Auflageleisten, Antenne (Ende ohne USB) zeigt nach OBEN, weg vom Akku und vom Kaefig
    d1_x0 = -il/2 + 30;  d1_y0 = ib/2 - 4 - d1_b - 2*spiel;
    for (y=[d1_y0, d1_y0 + d1_b + 2*spiel - 2]) translate([d1_x0, y, boden]) cube([d1_l + 2*spiel, 2, 3]);
    // Haltepunkt fuer 2 Widerstaende (Akku-Messung) als kleine Klemmleiste
    translate([d1_x0 + d1_l + 8, d1_y0 + 4, boden]) difference() { cube([12, 18, 5]); for (y=[4, 14]) translate([-1, y - 0.6, 2.5]) cube([14, 1.2, 3]); }
}

module deckel() {
    t = 2.4; lip_h = 3; lip_w = 1.4; sp = 0.35;
    difference() {
        rbox(al, ab, t, 3);
        for (p=dome()) translate([p[0], p[1], -1]) cylinder(d=3.4, h=t + 2);
    }
    // umlaufende Lippe nach innen, an den Eckdomen ausgespart
    translate([0,0,-lip_h]) difference() {
        rbox(il - 2*sp, ib - 2*sp, lip_h, 1);
        rbox(il - 2*sp - 2*lip_w, ib - 2*sp - 2*lip_w, lip_h + 1, 0.5);
        for (p=dome()) translate([p[0], p[1], -1]) cylinder(d=dom_d + 1, h=lip_h + 2);
    }
}

if (TEIL=="gehaeuse") gehaeuse();
if (TEIL=="deckel") rotate([180,0,0]) deckel();     // Druck: Deckelplatte unten
if (TEIL=="alle") { gehaeuse(); translate([0, ab + 30, 0]) rotate([180,0,0]) deckel(); }
if (TEIL=="zusammen") { gehaeuse(); %translate([0,0,boden + ih]) deckel(); }
