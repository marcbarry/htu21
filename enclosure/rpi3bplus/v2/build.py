"""Rebuild OpenSCAD STL exports, previews and geometric checks (Python 3 stdlib).

python enclosure/rpi3bplus/v2/build.py --openscad PATH/TO/openscad.com
Use --parts base lid sensor test to select outputs, --renders for PNGs,
and --checks for expected-empty assembly intersections.
"""
import argparse
from collections import defaultdict, deque
import json
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "pi3bplus_htu21_case.scad"
PARTS = {"base": "pi3bplus_base", "lid": "pi3bplus_lid",
         "sensor": "htu21_sensor_post", "test": "sensor_mount_test"}


def mesh_report(path):
    data = path.read_bytes()
    triangles = []
    if len(data) >= 84 and 84 + 50 * struct.unpack_from("<I", data, 80)[0] == len(data):
        for offset in range(84, len(data), 50):
            v = struct.unpack_from("<12fH", data, offset)[3:12]
            triangles.append([v[0:3], v[3:6], v[6:9]])
    else:
        vertices = [tuple(map(float, line.split()[1:]))
                    for line in data.decode("ascii").splitlines()
                    if line.strip().startswith("vertex ")]
        triangles = [vertices[i:i+3] for i in range(0, len(vertices), 3)]
    assert triangles, f"Empty mesh: {path}"
    edges = defaultdict(list)
    neighbours = defaultdict(set)
    volume = 0
    degenerate = 0
    bounds = [[float("inf")]*3, [float("-inf")]*3]
    for i, triangle in enumerate(triangles):
        a, b, c = [tuple(round(t, 5) for t in v) for v in triangle]
        for v in [a, b, c]:
            for axis in range(3):
                bounds[0][axis] = min(bounds[0][axis], v[axis])
                bounds[1][axis] = max(bounds[1][axis], v[axis])
        ab = [b[j]-a[j] for j in range(3)]
        ac = [c[j]-a[j] for j in range(3)]
        cross = [ab[1]*ac[2]-ab[2]*ac[1], ab[2]*ac[0]-ab[0]*ac[2], ab[0]*ac[1]-ab[1]*ac[0]]
        if sum(t*t for t in cross) < 1e-16:
            degenerate += 1
        volume += (a[0]*(b[1]*c[2]-b[2]*c[1])
                   - a[1]*(b[0]*c[2]-b[2]*c[0])
                   + a[2]*(b[0]*c[1]-b[1]*c[0]))/6
        for v, w in [(a,b),(b,c),(c,a)]:
            edges[tuple(sorted([v,w]))].append((i, v < w))
    bad_edges = sum(len(faces) != 2 for faces in edges.values())
    winding_errors = sum(len(faces) == 2 and faces[0][1] == faces[1][1] for faces in edges.values())
    for faces in edges.values():
        for i, _ in faces:
            neighbours[i].update(j for j, _ in faces if i != j)
    unseen = set(range(len(triangles)))
    components = 0
    while unseen:
        components += 1
        queue = deque([unseen.pop()])
        while queue:
            for nxt in neighbours[queue.popleft()]:
                if nxt in unseen:
                    unseen.remove(nxt)
                    queue.append(nxt)
    report = {"triangles": len(triangles), "connected_shells": components,
              "boundary_or_nonmanifold_edges": bad_edges, "winding_errors": winding_errors,
              "degenerate_triangles": degenerate, "volume_mm3": round(volume, 2),
              "bounds_mm": bounds,
              "size_mm": [round(bounds[1][j]-bounds[0][j], 3) for j in range(3)]}
    assert not bad_edges and not winding_errors and not degenerate and volume > 0, report
    assert abs(bounds[0][2]) < 1e-5, "Print part does not sit on Z=0"
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--openscad", default="openscad")
    parser.add_argument("--parts", nargs="*", default=list(PARTS), choices=list(PARTS))
    parser.add_argument("--renders", action="store_true")
    parser.add_argument("--checks", action="store_true")
    args = parser.parse_args()
    report = {}
    for part in args.parts:
        output = ROOT / "stl" / (PARTS[part]+".stl")
        output.parent.mkdir(exist_ok=True)
        result = subprocess.run([args.openscad, "-D", f'part="{part}"', "-o", str(output), str(SOURCE)],
                                capture_output=True, text=True)
        log = result.stdout + result.stderr
        print(f"{part}:\n{log}", flush=True)
        if result.returncode or "WARNING:" in log or "ERROR:" in log:
            raise RuntimeError(f"OpenSCAD failed for {part}")
        report[part] = mesh_report(output)
        assert report[part]["connected_shells"] == (2 if part == "test" else 1), report[part]
        print(json.dumps(report[part]), flush=True)
    if args.checks:
        for part in ["check_post_case", "check_base_lid", "check_pcb", "check_pi_pcb", "check_withdrawal"]:
            output = ROOT / "renders" / (part+".stl")
            output.parent.mkdir(exist_ok=True)
            if output.exists():
                output.unlink()
            result = subprocess.run([args.openscad, "-D", f'part="{part}"', "-o", str(output), str(SOURCE)],
                                    capture_output=True, text=True)
            log = result.stdout + result.stderr
            print(f"{part}:\n{log}", flush=True)
            empty = "Current top level object is empty" in log
            assert empty and "ERROR:" not in log, f"Unexpected solid intersection: {part}"
            report[part] = "empty (pass)"
    if args.renders:
        for part in ["assembly", "exploded", "sensor"]:
            output = ROOT / "renders" / (part+".png")
            output.parent.mkdir(exist_ok=True)
            camera = ["--camera=0,0,0,65,0,25,200"] if part in ["assembly", "exploded"] else []
            result = subprocess.run([args.openscad, "-D", f'part="{part}"', "-o", str(output),
                                     "--imgsize=1400,1100", "--viewall", "--autocenter",
                                     "--projection=o", "--colorscheme=Tomorrow"] + camera + [str(SOURCE)],
                                    capture_output=True, text=True)
            print(f"render {part}: {result.stdout}{result.stderr}", flush=True)
            assert result.returncode == 0 and output.exists(), f"Render failed: {part}"
    if report:
        (ROOT / "renders").mkdir(exist_ok=True)
        (ROOT / "renders" / "validation.json").write_text(json.dumps(report, indent=2)+"\n")


if __name__ == "__main__":
    main()
