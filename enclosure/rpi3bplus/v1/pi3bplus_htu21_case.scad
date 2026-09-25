/*
 Raspberry Pi 3 B+ / GY-21 enclosure, millimetres.
 Revised from the supplied design, preserved in archive/.
 Source of truth: this file. No external libraries.
 STL selections are already oriented on Z=0 for printing.
 part: base | lid | sensor | test | assembly | exploded | interface
 Diagnostic selections: check_case_arm | check_base_lid | check_pcb
*/
part = "assembly";
$fn = 48;
eps = 0.02;

// Case and original Pi mounting geometry.
wall = 2;
floor_t = 2;
corner_r = 3;
pi_x = 85;
pi_y = 56;
pcb_t = 1.6;
board_clear = 0.65;
inner_x = pi_x + 2*board_clear;
inner_y = pi_y + 2*board_clear;
outer_x = inner_x + 2*wall;
outer_y = inner_y + 2*wall;
base_h = 26; // raised from original 22; clear connector tops and lid
hole_dx = 58;
hole_dy = 49;
hole_x0 = 3.5;
hole_y0 = 3.5;
standoff_h = 3;
standoff_od = 6;
standoff_bore = 2.3; // PROVISIONAL M2.5 thread-forming pilot, not clearance
standoff_engagement = 3;

// Generous grouped connector openings; change for unusually bulky plugs.
io_x = 7;
io_width = outer_x-14;
io_sill_z = 4.4;
end_y = 4;
end_width = outer_y-8;
end_sill_z = 4.4;
sd_y = 16;
sd_width = 28;
sd_z = 2;
sd_height = 7;
sd_roof_bridge = 12; // 45 degree roof shoulders reduce the original 28 mm bridge
gpio_x = 6.5;
gpio_y = outer_y-16;
gpio_width = 58;
gpio_depth = 12;

// Lid locating skirt and four separately slotted spring tabs.
lid_top_t = 2;
lid_skirt_h = 8;
lid_skirt_t = 1.2;
lid_clear = 0.30; // radial clearance per side
lid_tab_w = 6;
lid_tab_gap = 1;
lid_snap_engagement = 0.25;
lid_snap_z = -6.5;
lid_snap_h = 1.0;
lid_snap_clear = 0.25;
lid_gpio_tabs = [17,73]; // centre X
lid_sd_tabs = [10,50]; // centre Y

// Low-profile, top-entry female dovetail on +Y wall.
// Its sloping underside grows out of the wall at <=45 degrees.
dock_x = 32;
dock_projection = 3.6;
dock_half_w = 12;
dock_seat_z = 4;
dock_h = 16.5;
dock_fit = 0.25; // NORMAL clearance on every dovetail profile face
dock_back_y = 0.35;
dock_back_half_w = 8;
dock_neck_y = 2.85;
dock_neck_half_w = 5.5;
dock_root_y = dock_projection+0.5;

// Independent vertical cantilever; dovetail carries the arm's load.
// Pull its exposed tip OUTWARD, then lift the arm clear of the rail.
latch_w = 4;
latch_side_gap = 0.65;
latch_y = 0.65;
latch_t = 1.0;
latch_h = 19.5;
latch_tooth_z = 13.0;
latch_tooth_h = 1.1;
latch_engagement = 0.35;
latch_pocket_clear = 0.25;
latch_pocket_depth = 1.1;
latch_release_travel = latch_y+latch_engagement+0.1; // outward at tooth, for path check

// Sensor: supplied PCB size; all unsupplied hole/keep-out data PROVISIONAL.
sens_x = 13.0;
sens_y = 10.8;
sens_t = 1.6;
sens_hole_d = 2.50; // PROVISIONAL: MEASURE before final printing
sens_hole_x = sens_x-2.2; // PROVISIONAL, from PCB left edge
sens_hole_y = sens_y-2.2; // PROVISIONAL, from solder/wire edge
sens_edge_fit = 0.35;
sens_support_inset = 0.60; // PROVISIONAL component-free edge land width
sens_support_h = 3.0; // air space below PCB; check underside components
sens_hole_land_d = 4.4; // PROVISIONAL component-free land around hole
sens_wire_keepout = 3.5; // PROVISIONAL strip from wire edge, no crossbar
sens_wire_drop_clear = 6; // open fork begins this far before PCB edge
sens_gap = 38; // main case +Y wall to NEAREST PCB edge (mm)

// Small split snap lug. Head overlap is intentionally small for PLA/PETG.
lug_diametral_clear = 0.20;
lug_head_overlap = 0.12; // radial beyond nominal hole
lug_slot = 0.65;
lug_root_h = 0.4;
lug_axial_clear = 0.20;
lug_head_ramp_h = 0.30;
lug_tip_h = 0.65;
lug_stem_d = sens_hole_d-lug_diametral_clear;
lug_head_d = sens_hole_d+2*lug_head_overlap;
lug_shoulder_z = sens_support_h+sens_t+lug_axial_clear;

arm_w = 7;
arm_t = 2.4;
carrier_rail_w = 1.8;
carrier_outer_half = sens_x/2+sens_edge_fit+carrier_rail_w;
test_gap = 12; // shortened arm ONLY on test coupon

assert(dock_fit > 0 && dock_fit < 0.6);
assert(dock_seat_z >= dock_projection, "Dock underside must be support-free");
assert(sens_gap >= 30 && sens_gap <= 40, "PCB edge spacing must be 30-40 mm");
assert(lug_stem_d > lug_slot+1.4, "Split lug fingers too thin for a 0.4 mm nozzle");
assert(sens_hole_x > sens_hole_land_d/2 && sens_hole_x <= sens_x-sens_hole_land_d/2);
assert(sens_hole_y >= sens_wire_keepout+sens_hole_land_d/2);
assert(sens_hole_y <= sens_y-sens_hole_land_d/2);
assert(latch_pocket_depth < wall, "Latch pocket must not break into Pi cavity");
assert(latch_y+latch_t < dock_neck_y);

module rounded_rect_prism(x,y,z,r) {
    linear_extrude(height=z)
        offset(r=r) offset(delta=-r) square([x,y]);
}

module board_holes(h,d,z=0) {
    for (xx=[hole_x0,hole_x0+hole_dx], yy=[hole_y0,hole_y0+hole_dy])
        translate([wall+board_clear+xx,wall+board_clear+yy,z]) cylinder(h=h,d=d);
}

// Local dock coordinates: X centred, Y outward from case, Z up.
module dock_profile() {
    polygon([[-dock_back_half_w,dock_back_y],
             [dock_back_half_w,dock_back_y],
             [dock_neck_half_w,dock_neck_y],
             [dock_neck_half_w,dock_projection+2],
             [-dock_neck_half_w,dock_projection+2],
             [-dock_neck_half_w,dock_neck_y]]);
}

module dock_outline() {
    polygon([[-dock_half_w,-eps],[dock_half_w,-eps],
             [dock_half_w-2,dock_projection],[-dock_half_w+2,dock_projection]]);
}

module dock_blank() {
    union() {
        // Continuous tapered gusset, not hanging rectangular blocks.
        hull() {
            translate([-dock_half_w,-eps,0]) cube([2*dock_half_w,2*eps,eps]);
            translate([0,0,dock_seat_z-eps]) linear_extrude(eps) dock_outline();
        }
        translate([0,0,dock_seat_z-eps]) linear_extrude(dock_h+eps) dock_outline();
    }
}

module dock_cuts() {
    translate([0,0,dock_seat_z]) linear_extrude(dock_h+eps) dock_profile();
    // Blind catch in wall; upper lip stops extraction until tab is pulled.
    translate([-latch_w/2-latch_pocket_clear,-latch_pocket_depth,
               dock_seat_z+latch_tooth_z-latch_pocket_clear])
        cube([latch_w+2*latch_pocket_clear,latch_pocket_depth+dock_back_y+eps,
              latch_tooth_h+2*latch_pocket_clear]);
}

// Generic wedge extruded along X, specified in the Y/Z plane.
module x_prism(width, points) {
    rotate([90,0,90]) linear_extrude(height=width,center=true) polygon(points);
}

module latch_shape() {
    translate([-latch_w/2,latch_y,0]) cube([latch_w,latch_t,latch_h]);
    // 45 degree insertion lead-in; flat shoulder for positive retention.
    x_prism(latch_w,[[latch_y,latch_tooth_z],
                    [-latch_engagement,latch_tooth_z+latch_tooth_h],
                    [latch_y+eps,latch_tooth_z+latch_tooth_h]]);
}

module latch(released=false) {
    // Shear is only a swept-clearance proxy, NOT a spring/strain simulation.
    multmatrix([[1,0,0,0],[0,1,released ? latch_release_travel/(latch_tooth_z+latch_tooth_h) : 0,0],
                [0,0,1,0],[0,0,0,1]]) latch_shape();
}

module male_dock(released=false) {
    difference() {
        linear_extrude(dock_h) offset(delta=-dock_fit) dock_profile();
        // Open centre separates the spring from load-bearing dovetail flanks.
        translate([-latch_w/2-latch_side_gap,-1,arm_t])
            cube([latch_w+2*latch_side_gap,dock_projection+4,dock_h]);
        // Profile is clipped at the external arm root.
        translate([-20,dock_root_y,-eps]) cube([40,10,dock_h+2*eps]);
    }
    latch(released);
    // Root overlaps both keys and latch, but leaves spring free above arm_t.
    translate([-dock_neck_half_w+dock_fit,latch_y,0])
        cube([2*(dock_neck_half_w-dock_fit),dock_root_y+2-latch_y,arm_t]);
}

module lid_catch_cuts() {
    for (x=lid_gpio_tabs)
        translate([x-lid_tab_w/2-lid_snap_clear,outer_y-wall-eps,
                   base_h+lid_snap_z-lid_snap_clear])
            cube([lid_tab_w+2*lid_snap_clear,wall+2*eps,lid_snap_h+2*lid_snap_clear]);
    for (y=lid_sd_tabs)
        translate([-eps,y-lid_tab_w/2-lid_snap_clear,
                   base_h+lid_snap_z-lid_snap_clear])
            cube([wall+2*eps,lid_tab_w+2*lid_snap_clear,lid_snap_h+2*lid_snap_clear]);
}

module base() {
    difference() {
        union() {
            difference() {
                rounded_rect_prism(outer_x,outer_y,base_h,corner_r);
                translate([wall,wall,floor_t])
                    rounded_rect_prism(inner_x,inner_y,base_h,max(0.8,corner_r-wall));
            }
            board_holes(standoff_h,standoff_od,floor_t);
            translate([dock_x,outer_y,0]) dock_blank();
        }
        board_holes(standoff_engagement+eps,standoff_bore,
                    floor_t+standoff_h-standoff_engagement);
        // Open to rim: no long unsupported lintels or connector-top collision.
        translate([io_x,-eps,io_sill_z]) cube([io_width,wall+2*eps,base_h]);
        translate([outer_x-wall-eps,end_y,end_sill_z]) cube([wall+2*eps,end_width,base_h]);
        translate([wall/2,0,0]) x_prism(wall+2*eps,
            [[sd_y,sd_z],[sd_y+sd_width,sd_z],
             [sd_y+sd_width,sd_z+sd_height],
             [sd_y+(sd_width+sd_roof_bridge)/2,sd_z+sd_height+(sd_width-sd_roof_bridge)/2],
             [sd_y+(sd_width-sd_roof_bridge)/2,sd_z+sd_height+(sd_width-sd_roof_bridge)/2],
             [sd_y,sd_z+sd_height]]);
        for (xx=[18:8:66]) translate([xx,18,-eps]) cube([3.2,20,floor_t+2*eps]);
        translate([dock_x,outer_y,0]) dock_cuts();
        lid_catch_cuts();
    }
}

module skirt() {
    translate([wall+lid_clear,wall+lid_clear,-lid_skirt_h])
        difference() {
            rounded_rect_prism(inner_x-2*lid_clear,inner_y-2*lid_clear,lid_skirt_h,1.2);
            translate([lid_skirt_t,lid_skirt_t,-eps])
                rounded_rect_prism(inner_x-2*(lid_clear+lid_skirt_t),
                    inner_y-2*(lid_clear+lid_skirt_t),lid_skirt_h+2*eps,0.4);
        }
}

module lid_tab_rib() {
    x_prism(lid_tab_w,[[-eps,lid_snap_z],
            [lid_clear+lid_snap_engagement,lid_snap_z+lid_snap_h/2],
            [-eps,lid_snap_z+lid_snap_h]]);
}

// Assembled lid origin is its underside. Export flips it cap-down onto bed.
module lid() {
    difference() {
        union() {
            rounded_rect_prism(outer_x,outer_y,lid_top_t,corner_r);
            skirt();
            for (x=lid_gpio_tabs)
                translate([x,outer_y-wall-lid_clear,0]) lid_tab_rib();
            for (y=lid_sd_tabs)
                translate([wall+lid_clear,y,0]) rotate([0,0,90]) lid_tab_rib();
        }
        // Remove skirt over the two grouped connector bays.
        translate([io_x,-eps,-lid_skirt_h-eps])
            cube([io_width,wall+lid_clear+lid_skirt_t+eps,lid_skirt_h+eps]);
        translate([outer_x-wall-lid_clear-lid_skirt_t-eps,end_y,-lid_skirt_h-eps])
            cube([wall+lid_clear+lid_skirt_t+2*eps,end_width,lid_skirt_h+eps]);
        // Isolate four compliant tabs; slots end at solid cap.
        for (x=lid_gpio_tabs, s=[-1,1])
            translate([x+s*(lid_tab_w/2+lid_tab_gap/2)-lid_tab_gap/2,
                       outer_y-wall-lid_clear-lid_skirt_t-eps,-lid_skirt_h-eps])
                cube([lid_tab_gap,lid_skirt_t+2*eps,lid_skirt_h+eps]);
        for (y=lid_sd_tabs, s=[-1,1])
            translate([wall+lid_clear-eps,y+s*(lid_tab_w/2+lid_tab_gap/2)-lid_tab_gap/2,
                       -lid_skirt_h-eps])
                cube([lid_skirt_t+2*eps,lid_tab_gap,lid_skirt_h+eps]);
        translate([gpio_x,gpio_y,-eps]) cube([gpio_width,gpio_depth,lid_top_t+2*eps]);
        for (yy=[17:6:41]) translate([28,yy,-eps]) cube([30,2.6,lid_top_t+2*eps]);
        for (yy=[13:6:37]) translate([67,yy,-eps]) cube([12,2.6,lid_top_t+2*eps]);
    }
}

module split_lug() {
    difference() {
        union() {
            cylinder(h=lug_shoulder_z,d=lug_stem_d);
            translate([0,0,lug_shoulder_z-lug_head_ramp_h])
                cylinder(h=lug_head_ramp_h,d1=lug_stem_d,d2=lug_head_d);
            translate([0,0,lug_shoulder_z])
                cylinder(h=lug_tip_h,d1=lug_head_d,d2=lug_stem_d-0.25);
        }
        // Split through support boss too, leaving a tough continuous root.
        translate([-lug_slot/2,-sens_hole_land_d,lug_root_h])
            cube([lug_slot,2*sens_hole_land_d,lug_shoulder_z+lug_tip_h]);
    }
}

module carrier(gap=sens_gap) {
    bx = -sens_x/2;
    by = gap;
    rail_inner = sens_x/2+sens_edge_fit;
    // U-frame outside PCB; solder edge is completely open between fork rails.
    for (s=[-1,1]) {
        x = s<0 ? -carrier_outer_half : rail_inner;
        translate([x,by-sens_wire_drop_clear,0])
            cube([carrier_rail_w,sens_y+sens_wire_drop_clear+carrier_rail_w,arm_t]);
        // Two small bare-edge ledges. No component clamping.
        px = s<0 ? bx-sens_edge_fit : sens_x/2-sens_support_inset;
        hull() {
            translate([x,by+sens_wire_keepout+1,arm_t-eps])
                cube([carrier_rail_w,2,eps]);
            translate([px,by+sens_wire_keepout+1,arm_t+sens_support_h-eps])
                cube([sens_edge_fit+sens_support_inset,2,eps]);
        }
        // Side fences outside the PCB, stopping short of sensing face.
        translate([x,by+sens_wire_keepout+1,arm_t])
            cube([carrier_rail_w,2,sens_support_h+sens_t/2]);
    }
    translate([-carrier_outer_half,by+sens_y,0])
        cube([2*carrier_outer_half,carrier_rail_w,arm_t]);
    hull() {
        translate([-sens_x/2-0.2,by+sens_y,arm_t-eps])
            cube([sens_x+0.4,carrier_rail_w,eps]);
        translate([-sens_x/2-0.2,by+sens_y-sens_support_inset,arm_t+sens_support_h-eps])
            cube([sens_x+0.4,sens_support_inset+carrier_rail_w,eps]);
    }
    translate([-carrier_outer_half,by+sens_y+sens_edge_fit,arm_t])
        cube([2*carrier_outer_half,carrier_rail_w-sens_edge_fit,sens_support_h+sens_t/2]);
    // Hole boss joined to rear/side frame by a low web, well below PCB.
    translate([bx+sens_hole_x,by+sens_hole_y,0]) {
        hull() {
            cylinder(h=arm_t,d=sens_hole_land_d);
            translate([0,sens_y-sens_hole_y,0]) cylinder(h=arm_t,d=sens_hole_land_d);
        }
        difference() {
            cylinder(h=arm_t+sens_support_h,d=sens_hole_land_d);
            // Clear boss centre so the lug fingers flex over their full length.
            translate([0,0,arm_t+lug_root_h])
                cylinder(h=sens_support_h+eps,d=lug_head_d+0.4);
        }
        translate([0,0,arm_t]) split_lug();
    }
}

module sensor_arm(gap=sens_gap,released=false) {
    male_dock(released);
    translate([-arm_w/2,dock_root_y,0])
        cube([arm_w,gap-sens_wire_drop_clear-dock_root_y+carrier_rail_w,arm_t]);
    translate([-carrier_outer_half,gap-sens_wire_drop_clear,0])
        cube([2*carrier_outer_half,carrier_rail_w,arm_t]);
    carrier(gap);
}

module case_coupon() {
    difference() {
        union() {
            translate([-dock_half_w-2,-wall,0]) cube([2*dock_half_w+4,wall,base_h-3]);
            dock_blank();
        }
        dock_cuts();
    }
}

module sensor_mount_test() {
    // Two separate printable bodies. Same interface, lug and carrier as full part.
    translate([dock_half_w+2,wall,0]) case_coupon();
    translate([3*dock_half_w+10,2,0]) sensor_arm(test_gap);
}

module pi_pcb(inset=0) {
    difference() {
        translate([wall+board_clear,wall+board_clear,floor_t+standoff_h+inset])
            rounded_rect_prism(pi_x,pi_y,pcb_t-2*inset,3);
        board_holes(pcb_t+2*eps,2.75,floor_t+standoff_h-eps);
    }
}

module sensor_pcb(gap=sens_gap,inset=0) {
    difference() {
        translate([-sens_x/2,gap,arm_t+sens_support_h+inset]) cube([sens_x,sens_y,sens_t-2*inset]);
        translate([-sens_x/2+sens_hole_x,gap+sens_hole_y,arm_t+sens_support_h-eps])
            cylinder(h=sens_t+2*eps,d=sens_hole_d);
    }
}

module assembly(explode=0) {
    color("SlateGray") base();
    color("LightSteelBlue") translate([0,0,base_h+explode]) lid();
    color("Orange") translate([dock_x,outer_y,dock_seat_z]) sensor_arm();
    color("SeaGreen") pi_pcb();
    color("RoyalBlue") translate([dock_x,outer_y,dock_seat_z]) sensor_pcb();
}

if (part=="base") base();
else if (part=="lid") translate([0,outer_y,lid_top_t]) rotate([180,0,0]) lid();
else if (part=="sensor") sensor_arm();
else if (part=="test") sensor_mount_test();
else if (part=="assembly") assembly();
else if (part=="exploded") assembly(18);
else if (part=="interface") {
    color("SlateGray") case_coupon();
    color("Orange") translate([0,0,dock_seat_z]) sensor_arm(test_gap);
}
else if (part=="check_case_arm") intersection() {
    base(); translate([dock_x,outer_y,dock_seat_z]) sensor_arm();
}
else if (part=="check_base_lid") intersection() {
    base(); translate([0,0,base_h]) lid();
    // Exclude the intentional zero-thickness rim/cap contact plane.
    translate([-100,-100,-eps]) cube([300,300,base_h]);
}
else if (part=="check_pcb") intersection() { sensor_arm(); sensor_pcb(inset=eps); }
else if (part=="check_pi_pcb") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    pi_pcb(inset=eps);
}
else if (part=="check_withdrawal") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    // Conservative full-height extrusion of released arm's XY silhouette.
    // Encloses its entire upward withdrawal path while lid stays fitted.
    translate([dock_x,outer_y,dock_seat_z+eps])
        linear_extrude(latch_h+dock_h+1) projection(cut=false) sensor_arm(released=true);
}
else assert(false,str("Unknown part: ",part));
