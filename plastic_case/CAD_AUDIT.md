# CAD audit — 2026-10-26

Scope: post-merge review of `be006ab` and `c4e6dfe`, including the validators they used. Original FreeCAD documents, original STL exports and original renders are preserved.

## Corrected defects

| Defect | Evidence before correction | Correction |
|---|---|---|
| Retainers occupied their case bosses | Native CSG intersections: OLED 779.0809 mm³, encoder 259.8628 mm³ | Rear screw plates seat against the boss ends; separate lips reach forward to the PCB/body beside the bosses. The 18 mm boss depth clears the existing lid towers. |
| OLED retainer entered the floor | Installed lower corner at z≈0.622 mm, inside a 1.5 mm floor | Clip the retainer to the shell cavity with 0.35 mm clearance, including its rounded floor. The bottom is open; side/top lips retain the board. |
| Retainer header/terminal slots had a roof | Centered cutter removed only half of the 1.6 mm frame | Cut through the full plate/support height. A 3 mm rear brace keeps the open-bottom OLED retainer connected. |
| Carrier collided with controls and bosses | Earlier audit measured 94.42 mm³ encoder/carrier overlap; rear-plate changes also exposed OLED/boss intersections | Sweep both control, boss and configurable screw-head footprints to the panel-side edge with 0.35 mm relief. Open notches avoid detached plate islands. Move panel-side mounting bosses inward. |
| Carrier mount holes nearly broke out of its ends | Hole center only 2 mm from edge; Ø3.4 hole left 0.3 mm of material | Derive the plate length from the lid-tower envelope plus 0.5 mm gap; mounting holes have a 4 mm edge margin. Default plate is 54.62 × 122 × 2 mm. |
| Ø8 rework tower parameter had no effect | A second `m3_case_tower` definition replaced the intended reinforced module | Remove duplicate and add the configured reinforced cylinder to the source tower/web geometry in rework only. |
| Cable-clamp head recess was buried | Default Ø5.8 recess ended around z3 inside a 6 mm cap | Open counterbores from the exterior face. Regression checks head-entry corridors at cable Ø6/8/12. |
| Lid locating panel faced outward | Assembly put the raised panel above the cover and left 1.5 mm above tower tops | Install rework lid face-down. Its lip follows the sloped cavity with 0.25 mm normal clearance and seats on tower tops. |
| Profile arc angles remained fixed at 75° | Arc limits 195°/375° ignored the angle parameter | Derive all endpoints from the panel angle and include fractional endpoints exactly. |
| Small end-wall offsets biased source comparison | End skins translated inward by 0.02 mm | Restore source end planes. Reduce internal support overlap from 0.01 to 0.001 mm. |
| Clearance test could accept missing pieces | Any empty OpenSCAD result passed; warnings were ignored | Validate five positive solid controls, reject tool diagnostics, then measure every pair using mesh Booleans. Fault-injection tests verify failure on missing modules/includes and real collisions. |
| Baseline validation was not a failure gate | Exit status remained zero for failed comparisons, and invalid source recomputes were discarded from evidence | Fail for distance/topology/tool errors or invalid parameter variants; preserve source object/solver states and distinguish saved snapshot geometry. |
| Symmetric difference estimate concealed small errors | Independently voxelized 1 mm grids could report zero for different surfaces | Use finite-precision tessellated mesh Booleans; shared-world-lattice sampling is explicitly labeled as a fallback. |
| Reports and printable files could drift | Tracked rework JSON predated the carrier correction | Regenerate reports and all current STL/previews; add source/artifact SHA256 manifest and `build_print_set.py --verify`. |
| Main README still led to old files | `control_box.stl` described as the case without a revision distinction | Link the rework print set from the main README and label the preserved historical exports. |

## Source reference limitations

The saved default FreeCAD solid is valid, but its support sketches are not a valid recomputed parameter point. The report calls this `source_snapshot_only`; it must not be presented as parametric proof.

The longer/thicker source variant recomputes successfully. A further 78.5° variant revealed an unstable external reference: Sketch006 constraint 34 fixes geometry 5 point 1 to external geometry -3, `Pad002.Edge156`. At 75°, that edge is on the near-left tower at X=7.12701665379; at 78.5°, the same edge number refers to the far-right tower at X=56.26881262189947. Both variants have zero DoF, but the resulting support opening differs dramatically. The third baseline test deliberately transcribes the returned coordinate so it reproduces the source, including this behavior. It does not declare that geometry a useful enclosure configuration.

The inventory now records construction geometry, constraint point positions, external references, dependencies, states, source checksum and placements. Those fields distinguish the source's actual profile from reference lines and expose the unstable edge link independently.

## Evidence and reproduction

- `tests/geometry-validation.json`: default snapshot plus two valid source recomputes; six case/lid comparisons pass the sampled 0.05 mm check. The Boolean differences are nonzero and reported numerically; no geometric-identity claim is made.
- `tests/rework-validation.json`: eight printable configurations, each one positive watertight solid with consistent winding.
- `tests/assembly-clearance.json`: five installed printed parts and ten pairwise intersections for default and longer/thicker assemblies. Contact is accepted only below 0.0001 mm³ to account for finite-precision mesh arithmetic.
- `tests/test_assembly_clearance.py`: missing geometry, disconnected solids, injected collisions, volume-tolerance behavior, and configured retainer-head clearance.
- `tests/test_cable_clamp.py`: actual STL head-entry corridor checks.
- `tests/test_validation_tools.py`: invalid/stale source recompute and failed distance/topology gates.
- `print_candidate/manifest.json`: exact source and generated-artifact hashes.

Run the commands in `README_OpenSCAD.md` from the repository root. `python3 -m pytest -q plastic_case/tests` runs the regression suite. `python3 plastic_case/tools/build_print_set.py --verify` rejects a print set after either CAD source or any listed artifact changes.

## Assembly order and physical limits

Install the display and encoder and tighten their rear retainers before installing the removable carrier; the carrier can obstruct the screwdriver approach. Screw heads sit outside the thin rear plates rather than in blind recesses. The lid lip enters the opening and its four holes register with the towers.

These checks establish printed-solid geometry at the tested parameter points. They do not prove insertion paths, printer tolerances, insert installation strength or fit to unmeasured electronics. Exact board outlines, solder heights, Dupont housings/wire bends, USB overmold, button travel and cable boot still require the real components and fit coupons. Board-specific clips, a measured supply cradle and final cable-clamp placement remain pending that evidence. The model contains a generic removable grid carrier, not a validated layout of all three populated boards.
