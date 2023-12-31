// Resolution for milling:
$fa            = 1;    // Minimum angle
$fs            = 0.1;  // Minimum size
delta          = 0.001;

blechdicke     =   3.0;
breite_innen   = 110.0;
hoehe_innen    =  26.0;

tiefe_aussen   =  83.0;
tiefe_innen    =  tiefe_aussen - blechdicke;

fuss_hoehe     =   3.0;

loch_x1        =  36.0;
loch_x2        =  47.0;
loch_z1        =   7.0;
loch_z2        =  20.0;
loch_rahmen    =   2.7;

alu_dicke      =   1.0;
seite_unten_d  =   5.0;
seite_unten_h  =   6.0;
seite_unten_t  =  75.0;
seite_oben_h   =  hoehe_innen - seite_unten_h;
seite_oben_t   =  seite_unten_t;
stub_tiefe     =  75.0;
stub_hoehe     =  seite_unten_h - 2.0;

phasen_ende    =   1.2;

l1_x           =   3.0;
l1_y           =   3.7;

l2_x           = 107.8;
l2_y           =   3.7;

l3_x           =   2.2;
l3_y           =  68.8;

l4_x           = 107.8;
l4_y           =  67.8;

loch_d         =   4.0;
schrauben_d    =   7.0;

pcb_dicke      =   1.6;
pcb_rand       =   0.5;

module lattenarray(breite, tiefe, hoehe, n_latten) {
    dx = breite / (2 * n_latten - 1);
    for(n = [0 : n_latten-1]) {
        x = dx * n * 2;
        translate([x, 0, 0])
            cube([dx, tiefe, hoehe]);
    }
}

module phasenstange_x(l) {
    size = blechdicke / sqrt(2);
    versatz = size / 2 * sqrt(2);
    translate([0, versatz, -versatz])
        rotate([45, 0, 0])
            cube([l, size, size]);
}

module phasenstange_y(l) {
    size = blechdicke / sqrt(2);
    versatz = size / 2 * sqrt(2);
    translate([versatz, 0, -versatz])
        rotate([45, 0, 90])
            cube([l, size, size]);
}

module phasenstange_z_links(l) {
    size = blechdicke / sqrt(2);
    versatz = size / 2 * sqrt(2);
    rotate([0, 0, 45])
        cube([size, size, l]);
}

module phasenstange_z_rechts(l) {
    size = blechdicke / sqrt(2);
    versatz = size / 2 * sqrt(2);
    rotate([0, 0, 45])
        cube([size, size, l]);
}

module rueckwand_ohne_loch() {
    lattenarray(breite_innen, 
                blechdicke, 
                hoehe_innen, 
                25);
    translate([0, 0, hoehe_innen])
        rotate([0, 90, 0])
            lattenarray(hoehe_innen,
                        blechdicke,
                        breite_innen,
                        8);
    translate([0, 0, -fuss_hoehe])
        cube([breite_innen,
              blechdicke,
              fuss_hoehe + delta]);
    translate([loch_x1 - loch_rahmen,
               0,
               loch_z1 - loch_rahmen])
        cube([loch_x2 - loch_x1 + 2 * loch_rahmen,
              blechdicke,
              loch_z2 - loch_z1 + 2 * loch_rahmen]);
}

module rueckwand() {
    difference() {
        {
            rueckwand_ohne_loch();
        }
        ;
        {
            translate([loch_x1, -delta, loch_z1])
                cube([loch_x2 - loch_x1,
                      blechdicke + 2*delta,
                      loch_z2 - loch_z1]);
            translate([-delta, 0, hoehe_innen])
                phasenstange_x(breite_innen + 2*delta);
            translate([0, 0, seite_unten_h])
                phasenstange_z_links(
                    hoehe_innen - alu_dicke);
            translate([breite_innen, 0, seite_unten_h])
                phasenstange_z_rechts(
                    hoehe_innen - alu_dicke);
        }
    }
}

module seitenwand_unten_links() {
    translate([0, blechdicke - delta, alu_dicke])
        cube([seite_unten_d, stub_tiefe, stub_hoehe]);
    difference() {
        translate([-blechdicke, 0, -fuss_hoehe])
            cube([blechdicke + delta,
                  tiefe_aussen,
                  seite_unten_h + fuss_hoehe + 
                  alu_dicke]);
        ;
        translate([-blechdicke, phasen_ende,
                   seite_unten_h])
            phasenstange_y(tiefe_aussen - 
                           2 * phasen_ende);
    }
}

module seitenwand_unten_rechts() {
    translate([breite_innen - seite_unten_d, 
               blechdicke - delta, alu_dicke])
        cube([seite_unten_d, stub_tiefe, stub_hoehe]);
    difference() {
        translate([breite_innen, 0, -fuss_hoehe])
            cube([blechdicke + delta,
                  tiefe_aussen,
                  seite_unten_h + fuss_hoehe + 
                  alu_dicke]);
        ;
        translate([breite_innen, phasen_ende,
                   seite_unten_h])
            phasenstange_y(tiefe_aussen - 
                           2 * phasen_ende);
    }
}


module loch(x, y) {
    translate([x, y + blechdicke, 
               - fuss_hoehe - blechdicke - delta]) 
        cylinder(h = hoehe_innen + alu_dicke +
                     stub_hoehe +
                     2 * blechdicke + 2*delta,
                 d = schrauben_d);
}

module schraubenhalterung() {
    cube([schrauben_d + blechdicke/2,
          schrauben_d + blechdicke/2,
          blechdicke + delta]);
}

module schraubenhalterungen() {
    translate([-delta, blechdicke,
               hoehe_innen - blechdicke])
        schraubenhalterung();
    translate([breite_innen -
               schrauben_d - blechdicke/2 - delta, 
               blechdicke * 1.15,
               hoehe_innen - blechdicke])
        schraubenhalterung();
}

module loecher() {
    loch(l1_x, l1_y);
    loch(l2_x, l2_y);
}

module schraubenloch(x, y) {
    translate([x, y + blechdicke, 
               - fuss_hoehe - blechdicke - delta]) 
        cylinder(h = hoehe_innen + alu_dicke +
                     stub_hoehe +
                     2 * blechdicke + 2*delta,
                 d = loch_d);
}

module schraubenloecher() {
    schraubenloch(l1_x, l1_y);
    schraubenloch(l2_x, l2_y);
}

module boden() {
    translate([-blechdicke - delta, 
               0, 
               -fuss_hoehe - blechdicke])
        cube([breite_innen + 2 * blechdicke,
              tiefe_aussen, blechdicke + delta]);
}

module deckel() {
    translate([-blechdicke - delta, 0, hoehe_innen])
        cube([breite_innen + 2 * blechdicke,
              tiefe_aussen, blechdicke + delta]);
    translate([-delta, 0, hoehe_innen + 0.25])
        phasenstange_x(breite_innen + 2*delta);
}

module seitenwand_oben_links() {
    union() {
        translate([-blechdicke, 0, seite_unten_h])
            cube([blechdicke + delta,
                  tiefe_aussen,
                  seite_oben_h + delta]);
        translate([-blechdicke, phasen_ende,
              seite_unten_h])
            phasenstange_y(tiefe_aussen - 
                  2 * phasen_ende);
    }
}

module seitenwand_oben_rechts() {
    union() {
        translate([breite_innen, 0, seite_unten_h])
            cube([blechdicke + delta,
                  tiefe_aussen,
                  seite_oben_h + delta]);
        translate([breite_innen, phasen_ende,
              seite_unten_h])
            phasenstange_y(tiefe_aussen - 
                  2 * phasen_ende);
    }
}

module front() {
    breite_rechts = 60.0;
    breite_links  = 10.0;
    raste_laenge  =  5.0;
    
    // Linker Teil:
    translate([-delta, 
               tiefe_innen + blechdicke/2,
               hoehe_innen - seite_oben_h + delta])
        cube([breite_links + delta,
              blechdicke/2, seite_oben_h + delta]);
    translate([0.2, 
               tiefe_innen + blechdicke/2,
               -blechdicke + delta])
        cube([breite_links - 0.2,
              blechdicke/2,
              hoehe_innen + blechdicke - 
                  seite_oben_h + delta]);
    translate([0.2,
               tiefe_innen - 
               raste_laenge + 
               blechdicke - delta, -fuss_hoehe])
        cube([breite_links - 0.2,
              raste_laenge, 2.0]); 
    
    // Rechter Teil:
    translate([breite_innen - breite_rechts + delta, 
               tiefe_innen + blechdicke * 0.25,
               hoehe_innen - seite_oben_h + delta])
        cube([breite_rechts + delta,
              blechdicke * 0.75, seite_oben_h + delta]);
    translate([breite_innen - breite_rechts, 
               tiefe_innen + blechdicke * 0.25,
               -blechdicke + delta])
        cube([breite_rechts - 0.2,
              blechdicke * 0.75,
              hoehe_innen + blechdicke - 
                  seite_oben_h + delta]);
    translate([breite_innen - breite_rechts,
               tiefe_innen - 
               raste_laenge + 
               blechdicke - delta, -fuss_hoehe])
        cube([breite_rechts - 0.2,
              raste_laenge, 2.0]); 
}

module unterteil() {
    difference() {
        union() {
            rueckwand();
            seitenwand_unten_links();
            seitenwand_unten_rechts();
            boden();
        }
        ;
        loecher();
    }
}

module display() {
    cube([71.2 + 2 * pcb_rand, 
          24.0 + 2 * pcb_rand, 7.0]);
}

module schalter() {
    union() {
        cube([7.0, 13.3, 6.0]);
        translate([-4.0, 7.37, -9.0])
            cube([4.45, 3.74, 15.0]);
    }
}

module schlitten_ohne_ausschnitt() {
    // Innere Platte:
    translate([5.25, 13.0, + alu_dicke + 0.2])
        cube([1.6, 20.0, hoehe_innen - 5.2]);
    // Block:
    translate([0.5, 13.0, seite_unten_h - alu_dicke])
        cube([2 * blechdicke + delta,
              20.0, 17.0]);
    // Hebel:
    translate([-blechdicke - 5.4, 18.0, 6.5])
        union() {
            cube([blechdicke + 6.0, 10.0, 11.5]);
            translate([0.25, 0, 0.0])
                rotate([0, 0, 90])
                    lattenarray(10.0, 1.0, 11.5, 5.0);
        }
}

module schlitten() {
    difference() {
        schlitten_ohne_ausschnitt();
        pcb();
    };
}

module schlittenausschnitt() {
    translate([-blechdicke - 2.4, 
               14.0, seite_unten_h + alu_dicke - 4.0])
        cube([blechdicke + 4.0, 14.0, 15.2]);
}

module pcb() {
    translate([7.0, 1.5 + blechdicke, 6.8 + alu_dicke])
        union() {
            translate([12.2, 3.6, 11.8 + pcb_dicke])
                union() {
                    cube([80.0, 36.0, pcb_dicke]);
                    translate([4.7 - pcb_rand,
                               6.5 - pcb_rand, 
                               pcb_dicke])
                        display();
                }
            cube([95.0, 65.0, pcb_dicke]);
            // AMPL Regler:
            translate([14.3, 50.5, pcb_dicke])
                cylinder(h = 25.3, d = 7);
            // ADJ Regler:
            translate([60.3, 52.0, pcb_dicke])
                cylinder(h = 25.3, d = 12);
            // OFFS Regler:
            translate([3.3, 43.0, pcb_dicke])
                cylinder(h = 25.3, d = 3);
            // Schalter:
            translate([0, 10.0, pcb_dicke])
                schalter();
        }
}

module oberteil() {
    difference() {
        union() {
            difference() {
                union() {
                    deckel();
                    seitenwand_oben_links();
                    seitenwand_oben_rechts();
                    front();
                }
                loecher();
            }
            schraubenhalterungen();
        }
        ;
        {
            schraubenloecher();
            pcb();
            schlittenausschnitt();
        }
    }
    // Schiene fuer Schlitten
    translate([7.2, 8.0, hoehe_innen - 10.0 + delta])
        cube([6.0, 25.0, 10.0]);
}

module alu() {
    translate([0, blechdicke, 0])
        cube([breite_innen, 
              tiefe_innen - blechdicke / 2, 
              alu_dicke]);
    translate([0, tiefe_innen + blechdicke / 2, 0])
        cube([breite_innen, 
              alu_dicke, 
              24.0]);
    translate([20.0, tiefe_innen, 12.0])
        rotate([-90, 0, 0])
            cylinder(h = 15.0, d = 9.0);    
    translate([39.0, tiefe_innen, 12.0])
        rotate([-90, 0, 0])
            cylinder(h = 15.0, d = 9.0);    
}

module print_unten() {
    translate([blechdicke + breite_innen, 
               fuss_hoehe + blechdicke, 0])
        rotate([90, 0, 180])
            unterteil();
}

module print_schlitten() {
    translate([-1.2, -13.1, 7.0])
        rotate([0, 90, 0])
            schlitten();
}

module combined() {
    color("blue")   unterteil();
    color("red")    oberteil();
    color("silver") alu();
    color("green")  pcb();
    color("white")  schlitten();
}

//combined();

//print_unten();
print_schlitten();
