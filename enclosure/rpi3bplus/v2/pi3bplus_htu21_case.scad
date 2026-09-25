/*
 V2: Raspberry Pi 3 B+ case with a SIMPLE removable upright sensor post.
 Derived from v1: same Pi mounting holes, case, port openings and snap lid.
 Units mm. Self-contained editable source; no library/version dependencies.
 part = base | lid | sensor | test | assembly | exploded
 Print selections are already on Z=0. Sensor post prints flat, then stands up.
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

// Simple rectangular push-fit post socket, beside the lid vents and GPIO.
post_x = 18;
post_y = 34;
post_w = 6;
post_t = 3;
post_shoulder_w = 10;
post_shoulder_h = 2;
socket_depth = 4; // inside lid; cap + socket give 6 mm engagement
socket_wall = 2;
socket_clear = 0.20; // TOTAL width/thickness allowance, 0.10 mm per face
peg_len = socket_depth+lid_top_t;
peg_lead_h = 1;
peg_lead_w = 0.8; // total width reduction at insertion tip
peg_lead_t = 0.4;
sensor_elevation = 35; // lid TOP to LOWEST edge of upright PCB

// Supplied board dimensions; unmeasured hole and contact lands are provisional.
sens_x = 13.0;
sens_y = 10.8;
sens_t = 1.6;
sens_hole_d = 2.50; // PROVISIONAL: measure mounting hole before final printing
sens_hole_x = sens_x-2.2; // PROVISIONAL: hole centre from left PCB edge
sens_hole_y = sens_y-2.2; // PROVISIONAL: hole centre from lower four-wire edge
sens_hole_land_d = 4.4; // PROVISIONAL bare underside land around hole
sens_support_h = 2.5; // air space from post to back of PCB
sens_support_inset = 0.6; // PROVISIONAL bare PCB edge land
sens_wire_keepout = 3.5; // PROVISIONAL lower solder strip depth
sens_edge_fit = 0.30;
edge_stop_t = 1.2;
edge_support_len = 2;

// Small split PCB lug, retained from v1. No case-side snap mechanism.
lug_diametral_clear = 0.20;
lug_head_overlap = 0.12; // radial, relative to nominal mounting hole
lug_slot = 0.65;
lug_root_h = 0.4;
lug_axial_clear = 0.20;
lug_head_ramp_h = 0.30;
lug_tip_h = 0.65;
lug_stem_d = sens_hole_d-lug_diametral_clear;
lug_head_d = sens_hole_d+2*lug_head_overlap;
lug_shoulder_z = sens_support_h+sens_t+lug_axial_clear;
test_elevation = 8; // shortened post only in fit coupon

assert(sensor_elevation >= 30 && sensor_elevation <= 40);
assert(socket_clear >= 0 && socket_clear <= 0.6);
assert(peg_len > peg_lead_h);
assert(post_w/2 >= sens_x-sens_hole_x-sens_support_inset,
       "Edge support must remain attached to post; increase post_w if hole moves");
assert(lug_stem_d > lug_slot+1.4, "Lug fingers too thin for 0.4 mm nozzle");
assert(sens_hole_x >= sens_hole_land_d/2 && sens_hole_x <= sens_x-sens_hole_land_d/2);
assert(sens_hole_y >= sens_wire_keepout+sens_hole_land_d/2);
assert(sens_hole_y <= sens_y-sens_hole_land_d/2);
assert(post_x-(post_w+socket_clear)/2-socket_wall > wall+lid_clear+lid_skirt_t);
assert(post_x+(post_w+socket_clear)/2+socket_wall < 28,
       "Socket must stay left of main lid vents");
assert(post_y+(post_t+socket_clear)/2+socket_wall < gpio_y,
       "Socket must clear GPIO window");

module rounded_rect_prism(x,y,z,r) {
    linear_extrude(height=z)
        offset(r=r) offset(delta=-r) square([x,y]);
}

module board_holes(h,d,z=0) {
    for (xx=[hole_x0,hole_x0+hole_dx], yy=[hole_y0,hole_y0+hole_dy])
        translate([wall+board_clear+xx,wall+board_clear+yy,z]) cylinder(h=h,d=d);
}

module x_prism(width, points) {
    rotate([90,0,90]) linear_extrude(height=width,center=true) polygon(points);
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
        lid_catch_cuts();
    }
}

module socket_body(x=post_x,y=post_y) {
    translate([x-(post_w+socket_clear)/2-socket_wall,
               y-(post_t+socket_clear)/2-socket_wall,-socket_depth])
        cube([post_w+socket_clear+2*socket_wall,
              post_t+socket_clear+2*socket_wall,socket_depth+eps]);
}

module socket_cut(x=post_x,y=post_y) {
    translate([x-(post_w+socket_clear)/2,y-(post_t+socket_clear)/2,-socket_depth-eps])
        cube([post_w+socket_clear,post_t+socket_clear,socket_depth+lid_top_t+2*eps]);
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

module lid() {
    difference() {
        union() {
            rounded_rect_prism(outer_x,outer_y,lid_top_t,corner_r);
            skirt();
            socket_body();
            for (x=lid_gpio_tabs)
                translate([x,outer_y-wall-lid_clear,0]) lid_tab_rib();
            for (y=lid_sd_tabs)
                translate([wall+lid_clear,y,0]) rotate([0,0,90]) lid_tab_rib();
        }
        socket_cut();
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

module pi_pcb(inset=0) {
    difference() {
        translate([wall+board_clear,wall+board_clear,floor_t+standoff_h+inset])
            rounded_rect_prism(pi_x,pi_y,pcb_t-2*inset,3);
        board_holes(pcb_t+2*eps,2.75,floor_t+standoff_h-eps);
    }
}

// Native post coordinates: X across mast, Y height above lid, Z facing out.
// Prints with rear face Z=0. Rotate +90 about X for upright installation.
module post_peg() {
    translate([-post_w/2,-peg_len+peg_lead_h,0])
        cube([post_w,peg_len-peg_lead_h+eps,post_t]);
    hull() {
        translate([-(post_w-peg_lead_w)/2,-peg_len,0])
            cube([post_w-peg_lead_w,eps,post_t-peg_lead_t]);
        translate([-post_w/2,-peg_len+peg_lead_h,0]) cube([post_w,eps,post_t]);
    }
}

module sensor_post(elevation=sensor_elevation) {
    hole_height = elevation+sens_hole_y;
    right_edge = sens_x-sens_hole_x;
    support_y = elevation+sens_wire_keepout+1;
    post_peg();
    translate([-post_shoulder_w/2,0,0]) cube([post_shoulder_w,post_shoulder_h,post_t]);
    translate([-post_w/2,0,0]) cube([post_w,hole_height,post_t]);
    translate([0,hole_height,0]) cylinder(h=post_t,d=post_w);
    // Mounting-hole support ring; hollow centre leaves the split lug free to flex.
    translate([0,hole_height,post_t]) {
        difference() {
            cylinder(h=sens_support_h,d=sens_hole_land_d);
            translate([0,0,lug_root_h]) cylinder(h=sens_support_h+eps,d=lug_head_d+0.4);
        }
        split_lug();
    }
    // One bare-edge resting pad and outside fence; no frame around the sensor.
    translate([right_edge-sens_support_inset,support_y,0])
        cube([sens_support_inset+sens_edge_fit,edge_support_len,post_t+sens_support_h]);
    translate([right_edge+sens_edge_fit,support_y,0])
        cube([edge_stop_t,edge_support_len,post_t+sens_support_h+sens_t/2]);
}

module sensor_pcb(elevation=sensor_elevation,inset=0) {
    difference() {
        translate([-sens_hole_x,elevation,post_t+sens_support_h+inset])
            cube([sens_x,sens_y,sens_t-2*inset]);
        translate([0,elevation+sens_hole_y,post_t+sens_support_h-eps])
            cylinder(h=sens_t+2*eps,d=sens_hole_d);
    }
}

module upright(lift=0) {
    translate([post_x,post_y+post_t/2,base_h+lid_top_t+lift]) rotate([90,0,0]) children();
}

module lid_print() {
    translate([0,outer_y,lid_top_t]) rotate([180,0,0]) lid();
}

module socket_coupon() {
    // Lid patch in installed coordinates, then cap-down onto print bed.
    translate([0,0,lid_top_t]) rotate([180,0,0]) difference() {
        union() {
            translate([-9,-7,0]) cube([18,14,lid_top_t]);
            socket_body(0,0);
        }
        socket_cut(0,0);
    }
}

module sensor_mount_test() {
    translate([9,7,0]) socket_coupon();
    translate([29,peg_len,0]) sensor_post(test_elevation);
}

module assembly(explode=0) {
    // Render each solid separately to keep colours without coplanar preview artefacts.
    color("SlateGray") render() base();
    color("LightSteelBlue") translate([0,0,base_h+explode]) render() lid();
    color("SeaGreen") render() pi_pcb();
    color("Orange") upright(explode*1.6) render() sensor_post();
    color("RoyalBlue") upright(explode*1.6) render() sensor_pcb();
}

if (part=="base") base();
else if (part=="lid") lid_print();
else if (part=="sensor") sensor_post();
else if (part=="test") sensor_mount_test();
else if (part=="assembly") assembly();
else if (part=="exploded") assembly(14);
else if (part=="check_base_lid") intersection() {
    base(); translate([0,0,base_h]) lid();
    translate([-100,-100,-eps]) cube([300,300,base_h]);
}
else if (part=="check_post_case") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    // Lift epsilon to exclude intended shoulder/lid contact.
    upright(eps) sensor_post();
}
else if (part=="check_pcb") intersection() { sensor_post(); sensor_pcb(inset=eps); }
else if (part=="check_pi_pcb") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); upright() sensor_post(); }
    pi_pcb(inset=eps);
}
else if (part=="check_withdrawal") intersection() {
    union() { base(); translate([0,0,base_h]) lid(); }
    // Discrete samples plus straight, constant-section socket: no undercuts.
    for (lift=[eps,1,3,peg_len+eps]) upright(lift) sensor_post();
}
else assert(false,str("Unknown part: ",part));
