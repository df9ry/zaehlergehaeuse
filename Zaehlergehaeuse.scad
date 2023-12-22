// Resolution for milling:
$fa            = 1;    // Minimum angle
$fs            = 0.1;  // Minimum size
delta          = 0.001;

blechdicke     =   3.0;
breite_innen   = 110.0;
hoehe_innen    =  26.0;

tiefe_aussen   =  83.0;

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
stub_tiefe     =  70.0;
stub_hoehe     =  seite_unten_h - 2.0;

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
        translate([-blechdicke, -delta, seite_unten_h])
            phasenstange_y(tiefe_aussen + 2*delta);
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
        translate([breite_innen, -delta, seite_unten_h])
            phasenstange_y(tiefe_aussen + 2*delta);
    }
}

module unterteil() {
    rueckwand();
    seitenwand_unten_links();
    seitenwand_unten_rechts();
}

unterteil();
