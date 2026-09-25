/*
 Raspberry Pi 3 Model B+ + GY-21/HTU21 case
 Units: mm

 User-measured sensor PCB: 13.0 x 10.8 x 1.6 mm
 Pi geometry based on Raspberry Pi 3 Model B+ physical specification.

 Export with:
   openscad -D 'part="base"' -o pi3bplus_base.stl pi3bplus_htu21_case.scad
   openscad -D 'part="lid"' -o pi3bplus_lid.stl pi3bplus_htu21_case.scad
   openscad -D 'part="sensor"' -o htu21_sensor_arm.stl pi3bplus_htu21_case.scad
*/

part = "base"; // base | lid | sensor
$fn = 48;

// ---- Printer clearances ----
fit = 0.30;
wall = 2.0;
floor_t = 2.0;
corner_r = 3.0;

// ---- Raspberry Pi 3 B+ ----
pi_x = 85.0;
pi_y = 56.0;
pcb_t = 1.6;
board_clear = 0.65;
inner_x = pi_x + 2*board_clear;
inner_y = pi_y + 2*board_clear;
outer_x = inner_x + 2*wall;
outer_y = inner_y + 2*wall;
base_h = 22.0;

// official mounting pattern: 58 x 49, hole Ø2.75; centres referenced from board lower-left
hole_dx = 58.0;
hole_dy = 49.0;
hole_x0 = 3.5;
hole_y0 = 3.5;

standoff_h = 3.0;
standoff_od = 6.0;
standoff_bore = 2.3; // pilot bore for M2.5 self-tapping/screw clearance depending printer

// ---- Lid ----
lid_top_t = 2.0;
lid_skirt_h = 5.0;
lid_clear = 0.28;

// ---- Sensor board ----
sens_x = 13.0;
sens_y = 10.8;
sens_t = 1.6;
sens_fit = 0.30;
// Hole diameter was not measured. 2.5 mm is a conservative prototype default.
// Change this single value if the snap is too tight/loose.
sens_hole_d = 2.50;
lug_stem_d = sens_hole_d - 0.18;
lug_head_d = sens_hole_d + 0.28;
lug_h = 2.5;
lug_head_h = 0.45;

arm_len = 35.0;
arm_w = 8.0;
arm_t = 2.4;

// ---- helpers ----
module rounded_rect_prism(x,y,z,r) {
    linear_extrude(height=z)
        offset(r=r)
            offset(delta=-r)
                square([x,y], center=false);
}

module shell_box(x,y,z,w,r) {
    difference() {
        rounded_rect_prism(x,y,z,r);
        translate([w,w,w])
            rounded_rect_prism(x-2*w,y-2*w,z+0.1,r>w ? r-w : 0.2);
    }
}

module base() {
    difference() {
        union() {
            // floor
            rounded_rect_prism(outer_x, outer_y, floor_t, corner_r);

            // walls as shell above floor
            translate([0,0,floor_t])
                difference() {
                    rounded_rect_prism(outer_x, outer_y, base_h-floor_t, corner_r);
                    translate([wall,wall,0])
                        rounded_rect_prism(inner_x, inner_y, base_h, max(0.8,corner_r-wall));
                }

            // four PCB standoffs
            for (xx=[hole_x0, hole_x0+hole_dx])
                for (yy=[hole_y0, hole_y0+hole_dy])
                    translate([wall+board_clear+xx, wall+board_clear+yy, floor_t])
                        cylinder(h=standoff_h, d=standoff_od);

            // two sockets for the removable sensor arm on GPIO side (outer +Y wall)
            for (xx=[22, 34])
                translate([xx, outer_y-0.2, 7.0])
                    cube([7.0, 4.2, 7.0], center=false);
        }

        // standoff bores
        for (xx=[hole_x0, hole_x0+hole_dx])
            for (yy=[hole_y0, hole_y0+hole_dy])
                translate([wall+board_clear+xx, wall+board_clear+yy, floor_t-0.1])
                    cylinder(h=standoff_h+0.3, d=standoff_bore);

        // long-side I/O opening: power / HDMI / audio side. Deliberately generous.
        translate([7.0,-0.1,5.0]) cube([outer_x-14.0, wall+0.4, 14.0]);

        // USB/Ethernet end opening. Deliberately generous.
        translate([outer_x-wall-0.2,6.0,4.5]) cube([wall+0.4, outer_y-12.0, 16.0]);

        // microSD access at opposite end, low in the wall
        translate([-0.1,16.0,2.0]) cube([wall+0.4, 28.0, 7.0]);

        // ventilation slots in floor, kept clear of standoff zones
        for (xx=[18:8:66])
            translate([xx,18,-0.1]) cube([3.2,20,floor_t+0.2]);

        // sensor arm socket voids: friction/snap rectangular interface
        for (xx=[22,34])
            translate([xx+0.75, outer_y-0.3, 8.0])
                cube([5.5, 4.5, 5.0], center=false);
    }
}

module lid() {
    difference() {
        union() {
            // top cap
            rounded_rect_prism(outer_x, outer_y, lid_top_t, corner_r);

            // inner skirt that locates inside base
            translate([wall+lid_clear, wall+lid_clear, -lid_skirt_h])
                difference() {
                    rounded_rect_prism(inner_x-2*lid_clear, inner_y-2*lid_clear, lid_skirt_h, 1.2);
                    translate([1.5,1.5,-0.1])
                        rounded_rect_prism(inner_x-2*lid_clear-3.0, inner_y-2*lid_clear-3.0, lid_skirt_h+0.2, 0.8);
                }

            // small retention bumps on inside skirt; flex of skirt gives snap
            for (xx=[18, outer_x-20]) {
                translate([xx, wall+lid_clear-0.45, -3.2]) sphere(d=1.1);
                translate([xx, outer_y-wall-lid_clear-0.65, -3.2]) sphere(d=1.1);
            }
        }

        // GPIO access: large rectangular window over 40-pin header region
        // leaves enough room for individual Dupont leads or a ribbon cable.
        translate([6.5, outer_y-16.0, -0.1]) cube([58.0, 12.0, lid_top_t+0.2]);

        // CPU / board ventilation slots
        for (yy=[17:6:41])
            translate([28.0,yy,-0.1]) cube([30.0,2.6,lid_top_t+0.2]);

        // extra vents near power-management / network area
        for (yy=[13:6:37])
            translate([67.0,yy,-0.1]) cube([12.0,2.6,lid_top_t+0.2]);
    }
}

module snap_peg(x=0,y=0,z=0) {
    translate([x,y,z])
        union() {
            cylinder(h=lug_h, d=lug_stem_d);
            translate([0,0,lug_h-lug_head_h])
                cylinder(h=lug_head_h, d1=lug_head_d, d2=lug_stem_d);
        }
}

module sensor_arm() {
    // Designed to print flat with the arm and cradle on the build plate.
    // Two compliant tongues insert into the sockets on the case's GPIO side.
    union() {
        // twin plug tongues
        for (xx=[0,12]) {
            translate([xx,0,0]) cube([5.2,5.5,4.7]);
            // small retention bump at plug tip
            translate([xx+2.6,4.9,2.35]) sphere(d=1.0);
        }

        // bridge from plugs to arm
        translate([-1.5,5.0,0]) cube([19.2,5.0,arm_t]);

        // arm: moves sensor away from warm Pi case
        translate([5.5,9.5,0]) cube([arm_w,arm_len+1.0,arm_t]);

        // open cradle platform at arm end
        translate([2.0,10.0+arm_len,0])
            difference() {
                cube([sens_x+4.0, sens_y+4.0, arm_t]);
                // large open window below sensor to maximise ambient airflow
                translate([3.0,2.4,-0.1]) cube([sens_x-2.0, sens_y-0.8, arm_t+0.2]);
            }

        // two low corner stops on the wire-free edge
        translate([2.0,10.0+arm_len+sens_y+2.0,arm_t]) cube([2.0,2.0,1.5]);
        translate([2.0+sens_x+2.0,10.0+arm_len+sens_y+2.0,arm_t]) cube([2.0,2.0,1.5]);

        // snap lug located near one corner of PCB. Position intentionally adjustable.
        // Current default places it 2.2 mm from two board edges.
        translate([2.0+2.2,10.0+arm_len+2.0+2.2,arm_t])
            snap_peg();

        // two tiny edge supports; top remains completely open to ambient air
        translate([2.0,10.0+arm_len+3.6,arm_t]) cube([1.2, sens_y-3.2, 1.0]);
        translate([2.0+sens_x+2.8,10.0+arm_len+3.6,arm_t]) cube([1.2, sens_y-3.2, 1.0]);

        // wire strain-relief arch behind the PCB pad edge; 4 wires pass underneath
        translate([6.5,10.0+arm_len-3.0,arm_t-0.3])
            difference() {
                cube([8.0,3.0,4.3]);
                translate([1.0,-0.1,1.2]) cube([6.0,3.2,2.6]);
            }
    }
}

if (part == "base") base();
if (part == "lid") lid();
if (part == "sensor") sensor_arm();
