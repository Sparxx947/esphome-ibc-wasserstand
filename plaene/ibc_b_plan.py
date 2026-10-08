import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Circle, Polygon
import sys
fig = plt.figure(figsize=(8.27, 11.69)); ax = fig.add_axes((0.0,0.0,1.0,1.0)); ax.set_xlim(0,210); ax.set_ylim(0,297); ax.axis("off")
L=dict(color="black", lw=1.4)
def line(*p, **k): ax.plot([a[0] for a in p],[a[1] for a in p], **{**L, **k})
def dot(x,y,c="black"): ax.add_patch(Circle((x,y),0.9,color=c))
T=lambda x,y,s,**k: ax.text(x,y,s,**{"fontsize":9,**k})
def box(x,y,w,h,titel):
    ax.add_patch(Rectangle((x,y),w,h,fill=False,lw=1.5)); T(x+w/2,y+h+2,titel,ha="center",fontsize=9.5,fontweight="bold")
def widerstand(x,y1,y2,name):   # senkrecht
    m=(y1+y2)/2; line((x,y1),(x,m+5)); line((x,m-5),(x,y2)); ax.add_patch(Rectangle((x-1.8,m-5),3.6,10,fill=False,lw=1.3)); T(x+3,m-1,name,fontsize=8,fontweight="bold")

T(15,282,"IBC Container B – Solar-Knoten – Schaltplan",fontsize=18,fontweight="bold")
T(15,274,"Wemos D1 mini (ESP8266) · 18650 Battery Shield V3 (rechtes, ohne USB-Buchse) · Schwimmer „Ziel voll“ · Stand 07.10.2026",fontsize=8.5)

# Panel
px,py=8,215
box(px,py,30,24,"Solarpanel 1 W")
T(px+2,py+15,"Seeed 5,5 V / 170 mA",fontsize=7.5); T(px+2,py+9,"Leerlauf bis 8,2 V!",fontsize=7.5,color="firebrick")
T(px+2,py+3,"außen am Schuppen",fontsize=7.5,color="dimgray")
T(px+31,py+19,"+",fontsize=11,fontweight="bold"); T(px+31,py+3,"−",fontsize=11,fontweight="bold")
line((px+30,py+18),(70,py+18),color="firebrick",lw=1.8); line((px+30,py+5),(70,py+5),lw=1.8)
T(40,py+21,"2–3 m Kabel, M12-Verschr.",fontsize=7,color="dimgray")
# Z-Diode
zx=62
dot(zx,py+18,"firebrick"); dot(zx,py+5)
line((zx,py+18),(zx,py+14)); line((zx,py+9),(zx,py+5))
ax.add_patch(Polygon([(zx-3,py+9),(zx+3,py+9),(zx,py+13.5)],closed=True,fill=False,lw=1.3))
line((zx-3,py+13.6),(zx+3,py+13.6)); line((zx-3,py+13.6),(zx-4,py+12.4)); line((zx+3,py+13.6),(zx+4,py+14.8))
T(zx-22,py-7,"Z-Diode BZX85C6V2",fontsize=7.5,fontweight="bold"); T(zx-22,py-11,"parallel, Ring (Kathode) → +",fontsize=7)

# Shield
sx,sy,sw,sh=70,170,55,70
box(sx,sy,sw,sh,"18650 Battery Shield V3")
T(sx+2,py+18,"Input +",fontsize=8.5,fontweight="bold"); T(sx+2,py+5,"Input −",fontsize=8.5,fontweight="bold")
T(sx+2,py+11.5,"(Pads der fehlenden\nUSB-Buchse U1)",fontsize=6.5,color="dimgray")
ax.add_patch(Rectangle((sx+8,sy+16),38,12,fill=False,lw=1.2,ls="--")); T(sx+12,sy+21,"Akku EVE 18650-33V",fontsize=7.5)
T(sx+12,sy+30,"+ (Halterkontakt)",fontsize=7.5,fontweight="bold",color="firebrick")
T(sx+3,sy+5,"Lader TC4056 · Schutz DW01+8205\nBoost 5 V (läuft immer)",fontsize=6.8,color="dimgray")
for n,y in (("5V",232),("GND",222)): T(sx+sw-2,y,n,ha="right",fontsize=9,fontweight="bold")

# D1 mini
dx,dy,dw,dh=150,140,40,100
box(dx,dy,dw,dh,"Wemos D1 mini")
pins={"5V":232,"G":222,"A0":205,"D0":190,"RST":180,"D5":160}
for n,y in pins.items(): T(dx+2,y,n,fontsize=9,fontweight="bold")
T(dx+2,dy+4,"Antennenende nach oben\n(weg von Akku/Käfig)",fontsize=6.8,color="dimgray")

# 5V / GND
line((sx+sw,232),(dx,232),color="darkorange",lw=1.8); T(sx+sw+3,234,"5 V",color="darkorange",fontsize=8,fontweight="bold")
line((sx+sw,222),(dx,222),lw=1.8); T(sx+sw+3,224,"GND",fontsize=8,fontweight="bold")
# Akku-Messung
ax_=sx+30
line((ax_,sy+29),(ax_,sy-8),(138,sy-8),(138,205-12))
widerstand(138,205-12,205,"")
T(113,196,"100 k + 22 kΩ",fontsize=8,fontweight="bold")
line((138,205),(dx,205),color="purple",lw=1.5); dot(ax_,sy+29,"firebrick")
T(72,150,"Akku + direkt vom Halterkontakt\n(Draht anlöten) → 100 kΩ + 22 kΩ in Reihe → A0",fontsize=7,color="purple")
# D0-RST
line((dx-6,190),(dx,190)); line((dx-6,180),(dx,180)); line((dx-6,190),(dx-6,180),color="teal",lw=1.8)
T(dx-30,184,"Draht D0–RST\n(Tiefschlaf)",fontsize=7,color="teal",fontweight="bold")
# Schwimmer
fx,fy=105,128
line((dx,160),(fx+30,160),(fx+30,fy+6)); line((fx+30,fy-6),(fx+30,fy-14),(dx+20,fy-14),(dx+20,dy)); dot(dx+20,dy)
T(dx+22,dy-6,"G",fontsize=8,fontweight="bold")
line((fx+30,fy+6),(fx+26,fy-3)); dot(fx+30,fy+6); dot(fx+30,fy-6)
T(fx-38,fy+3,"Schwimmerschalter in B",fontsize=8.5,fontweight="bold"); T(fx-38,fy-3,"Einbau: öffnet bei Wasser",fontsize=7.5)
T(fx-38,fy-8,"(Kabelbruch = „voll“ = Pumpe gesperrt)",fontsize=7,color="dimgray")
T(fx-38,fy-13,"M12-Verschraubung",fontsize=7.5,color="dimgray")

T(15,100,"Hinweise",fontsize=11,fontweight="bold")
H=[
"• Z-Diode PARALLEL an den Eingang, Ring (Kathode) an +. Ohne sie liegt bei vollem Akku die Leerlaufspannung des Panels",
"   (bis 8,2 V) am Eingang – das Shield verträgt laut Händler nur 6,5 V.",
"• Panel an die Pads der fehlenden USB-Buchse U1 (VBUS = +, GND = −). Vor dem Löten Foto der Pads an Claude: welches Pad ist VBUS.",
"• Akku erst einlegen, wenn alles verdrahtet ist; Polung am Halter ist geprüft (Aufdruck stimmt, 07.10.).",
"• D1 mini über den 5-V-Pin versorgen (Boost des Shields). Der 3-V-Ausgang des Shields ist ohne Kondensator instabil – NICHT nehmen.",
"• A0: Der D1 mini hat intern 220 kΩ/100 kΩ (3,2 V Endwert); mit 100 kΩ + 22 kΩ in Reihe davor (= 122 kΩ) misst er bis ~4,4 V. Dauerstrom ~10 µA.",
"• D0–RST-Draht ist für den Tiefschlaf nötig. Klappt das Flashen per USB nicht, den Draht kurz abziehen.",
"• Schwimmer an D5 (GPIO14) und G, interner Pull-up. Geschlossen = Wasser unten, offen = B voll ODER Kabel ab → Pumpe gesperrt.",
"• Verbrauch (geschätzt): Shield ~0,3 mA + D1 im Schlaf ~0,2 mA + 96× Aufwachen ≈ 25 mAh/Tag → EVE 3200 mAh ≈ 4 Monate ohne Sonne.",
"• Zum Aktualisieren (OTA) in HA „IBC B wach halten“ einschalten und auf das nächste Aufwachen warten (max. 15 min).",
]
for i,s in enumerate(H): T(15,92-i*6.3,s,fontsize=7.6)

out = sys.argv[1] if len(sys.argv)>1 else "ibc-b-schaltplan.pdf"
fig.savefig(out)
if len(sys.argv)>2: fig.savefig(sys.argv[2],dpi=80)
