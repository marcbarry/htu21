# V2: simple upright sensor post

**A straight post pushes into the lid and holds the sensor upright, with its
lowest PCB edge 35 mm above the lid.** No side arm, dovetail or release mechanism.
The post lifts straight out. The base and snap lid are derived from v1, retaining
the Pi mounts, connector openings, GPIO access and ventilation.

![Assembled v2](renders/assembly.png)

## Specification

| Item | V2 design |
| --- | --- |
| Pi | Raspberry Pi 3 Model B+ Rev 1.3; 85 × 56 mm PCB, 58 × 49 mm M2.5 mounting pattern |
| Main enclosure | Two pieces: base and snap lid; 90.3 × 61.3 × 28 mm assembled |
| Sensor mount | Separate 6 × 3 mm upright post; 6 mm insertion into lid socket |
| Attachment | Rectangular snug slip-fit, shoulder stop; pull straight up to remove |
| Elevation | 35 mm from lid top to sensor PCB's lowest edge; editable `sensor_elevation` |
| Sensor orientation | Vertical; four soldered wires at bottom, component/sensing face exposed |
| PCB support | Mounting-hole support ring and one small bare-edge pad/fence; no full cradle |
| PCB retention | Split printed snap lug through mounting hole, no screw |
| Wire route | Loose four-wire loop from GPIO window to the unobstructed lower solder edge |

This intentionally replaces v1's lateral separation with vertical elevation.
The post is a simple slip-fit, not a locking clip: lift the enclosure by the case,
not the sensor. No claim of calibrated thermal isolation is made.

## Files

- [Editable OpenSCAD](pi3bplus_htu21_case.scad) — self-contained source of truth.
- [Base STL](stl/pi3bplus_base.stl)
- [Lid STL](stl/pi3bplus_lid.stl)
- [Sensor post STL](stl/htu21_sensor_post.stl)
- [Fit test STL](stl/sensor_mount_test.stl) — small lid/socket patch plus a shortened
  post with the identical peg and PCB lug. Two separate bodies, no electronics.
- [Exploded rendering](renders/exploded.png) and [post detail](renders/sensor.png).

## Provisional dimensions — measure before the final print

The sensor PCB dimensions **13.0 × 10.8 × 1.6 mm** are supplied measurements.
The following defaults are prototype assumptions, clearly exposed in the SCAD:

| Parameter | Default | Measure/check |
| --- | --- | --- |
| `sens_hole_d` | **2.50 mm** | **Provisional mounting-hole diameter** |
| `sens_hole_x`, `sens_hole_y` | **10.8, 8.6 mm** | **Provisional hole centre**, measured from left PCB edge and lower wire edge, viewed from component side |
| `sens_hole_land_d` | 4.4 mm | Bare underside land around the hole |
| `sens_support_inset` | 0.6 mm | Bare PCB land along supported right edge |
| `sens_support_h` | 2.5 mm | Clearance between post and underside components |
| `sens_wire_keepout` | 3.5 mm | Unobstructed solder strip measured from lower edge |
| `standoff_bore` | 2.3 mm | Pi M2.5 screw pilot, not a clearance hole; tune for your screws/printer |

The hole centre determines the post's position relative to the PCB. If moving it,
check the edge pad and the assertion about `post_w`; the source warns if that pad
would become detached. Confirm both support lands are component-free.

## Print and assemble

All STLs are already oriented for printing:

1. **Base:** floor down. **Lid:** outside face down, skirt/socket up.
   **Post:** long flat rear face down, PCB lug up. The printed post is turned
   upright for assembly. The test parts are also oriented correctly.
2. Start with a **0.4 mm nozzle, 0.16–0.20 mm layers, 3–4 perimeters,
   4–5 top/bottom layers and 20–30% infill**. PLA or PETG; PETG is preferable
   for the small snap lug. Preserve the 0.65 mm slit with thin-wall/variable-width
   handling. Use good layer adhesion and remove strings from the lug and socket.
3. Supports are not intended in these orientations. The post lies flat so the
   peg, shoulder and edge pad start on the bed. The case retains a 12 mm microSD
   bridge and approximately 6.5 mm lid-catch bridges; check their slicer preview.
4. Print the fit test first. Try the rectangular peg in the lid patch. It should
   reach the shoulder with light hand pressure and pull out without bending the
   lid. `socket_clear=0.20` is the **total** width/thickness allowance (0.10 mm per
   face). Adjust by 0.05 mm if too tight or loose; use first-layer compensation
   rather than scaling an STL. The taper is only an insertion lead-in.
5. Check the PCB lug on the shortened test post. The stem is hole diameter minus
   `lug_diametral_clear=0.20`; head diameter is hole diameter plus
   `2*lug_head_overlap=0.24`. Tune those after measuring the hole. The lug is split
   by `lug_slot=0.65`; do not force it if the slit has fused or a component touches
   the support. To remove the PCB, gently squeeze the split head while supporting
   the board near the hole.
6. Mount the Pi on the four normal M2.5 points. M2.5 × 4 mm screws give about
   2.4 mm engagement through a 1.6 mm PCB; check the pilot fit and prepare/tap it
   for your screws as needed. The standoffs are 3 mm tall; don't drive through
   the floor. Snap the lid on evenly.
7. Fit the sensor to the post with its component side facing away from the post,
   wires downward. Push the post into the lid socket until its shoulder rests on
   top. It sits beside the vents and leaves the GPIO opening free.
8. Wire VCC to 3.3 V (pin 1), GND to pin 9, SDA to pin 3 and SCL to pin 5.
   I²C address remains **0x40**. Leave a loose loop through the GPIO opening so
   the post can lift at least 6 mm and the lid can be removed without pulling
   solder joints. Unplug the leads to detach the sensor completely.

Lid tolerances remain `lid_clear=0.30` per side and `lid_snap_engagement=0.25`.
Release its four tabs through the small case catch windows. The sensor fit test
does not test those lid clips.

## Rebuild and checks

Open the source in desktop OpenSCAD or a compatible online editor; no libraries
are needed. `part="assembly"` is the default. Other selections are `"exploded"`,
`"base"`, `"lid"`, `"sensor"` and `"test"`. PCB shapes in assembly views are
reference geometry and aren't included in the print files.

From the repository root, using Python 3 and OpenSCAD:

```powershell
python enclosure/rpi3bplus/v2/build.py --openscad .tools/openscad/openscad-2021.01/openscad.com --checks --renders
```

Omit `--openscad ...` if OpenSCAD is on PATH. `--parts sensor test` rebuilds only
those exports. The build validates closed meshes, winding, degenerate triangles,
body counts and bed placement. Five intersection checks cover the base/lid,
post/case, both PCBs and post removal. Seating contact planes are excluded by
0.02 mm. Removal is checked at several positions in a straight socket with no
undercuts. The result is generated as `renders/validation.json` (Git-ignored).

The three saved PNGs are colour previews; the STL exports and intersection checks
use OpenSCAD's solid renderer. Physical fit, lug durability, detailed Pi component
and cable-plug clearance still need a test print/trial assembly. No physical print
has been tested yet.

The preserved [v1](../v1/README.md) remains available for comparison. Its source
and STL geometry have not been modified by the v2 redesign.
