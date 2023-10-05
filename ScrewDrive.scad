/* [Screw Drive] */

screw_length = 50;
screw_center_radius = 2;

blade_length = 6;
blade_angle = 60;

motor_adapter_radius = 5 / 2;
motor_adapter_length = 6;
motor_adapter_skinny_size = 3;

/* [Housing] */

housing_wall_thickness = 2;

ramp_slope = 45;

/* [Motor Mount] */
mount_height = 32;
mount_screw_radius = 4.5 / 2;
mount_screw_separation = 34.5;

/* [Render] */

quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]
filament_gap = .2;
cross_section = false;
include_screw_drive = true;
include_housing = true;

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

total_screw_length = screw_length + motor_adapter_length;
blade_radius = blade_length + screw_center_radius;
motor_adapter_housing_radius = motor_adapter_radius + 1.5;
blade_container_radius = (blade_radius + housing_wall_thickness + filament_gap * 2);

ramp_length = total_screw_length - housing_wall_thickness;
ramp_height = tan(ramp_slope) * ramp_length;
housing_width = max(2 * blade_container_radius - housing_wall_thickness, mount_screw_separation - 2 * mount_screw_radius - 2 * housing_wall_thickness);
housing_height = ramp_height + 2 * blade_container_radius - housing_wall_thickness;

mount_width = mount_screw_separation + 2 * mount_screw_radius + 2 * housing_wall_thickness;

EQUILATERAL_TO_RIGHT_TRIANGLE = tan(45) / tan(60);

module motor_drive_adapter() {
    difference() {
        hull() {
            cylinder(h = motor_adapter_length, r = motor_adapter_housing_radius);

            translate([0, 0, -(motor_adapter_housing_radius - screw_center_radius)]) {
                cylinder(h = 1, r = screw_center_radius);
            }
        }

        intersection() {
            cylinder(h = motor_adapter_length, r = motor_adapter_radius + filament_gap);
            
            translate([0, 0, motor_adapter_length / 2]) {
                cube([motor_adapter_radius * 2, motor_adapter_skinny_size + filament_gap, motor_adapter_length], center = true);
            }
        }
    }
}

module screw_drive() {
    intersection() {
        rotations = screw_length / (PI * blade_radius * 2) * tan(blade_angle);

        union() {
            linear_extrude(height = screw_length, twist = 360 * rotations) {
                square([screw_center_radius, blade_radius]);
            }

            translate([0, 0, screw_length]) {
                motor_drive_adapter();
            }

            cylinder(h = screw_length, r = screw_center_radius);
        }

        cylinder(h = screw_length * 5, r = blade_radius, center = true);
    }
}

module ramp() {
    translate([blade_radius + 2 * filament_gap, 0, housing_wall_thickness]) {
        rotate([90, 0, 0]) {
            linear_extrude(housing_width, center = true) {
                polygon(points = [[0, 0], [0, ramp_length], [ramp_height, 0]]);
            }
        }
    }
}


module housing() {
    housing_container_width = housing_width - 2 * housing_wall_thickness;
    height_of_cutout = tan(60) * housing_width / 2;
    cutout_radius = (housing_container_width) * sqrt(3) / 3;

    difference() {
        union() {
            difference() {
                translate([-blade_container_radius, -housing_width / 2, 0]) {
                    cube([housing_height, housing_width, total_screw_length]);
                }

                union() {
                    cylinder(h = screw_length + filament_gap, r = blade_radius + filament_gap * 2);
                    cylinder(h = total_screw_length, r = motor_adapter_housing_radius + filament_gap * 2);
                }

                translate([blade_container_radius - housing_wall_thickness, -housing_container_width / 2, housing_wall_thickness]) {
                    cube([housing_height - blade_container_radius * 2 + housing_wall_thickness, housing_container_width, screw_length - housing_wall_thickness + filament_gap]);
                }
            }

            ramp();
            motor_mount();
        }

        translate([0, 0, screw_length + filament_gap])
            scale([1, 1, EQUILATERAL_TO_RIGHT_TRIANGLE])
                translate([0, 0, -cutout_radius / 2])
                    rotate([0, 90, 0])
                            cylinder(r = cutout_radius, h = housing_height, $fn = 3);
    }
}

module screw_slot(radius, length, height, center = false) {
    hull() {
        translate([length / 2 - radius, 0, 0])
            cylinder(h = height, r = radius, center = center);

        translate([-length / 2 + radius, 0, 0])
            cylinder(h = height, r = radius, center = center);
    }
}

module motor_mount() {
    translate([-blade_container_radius + mount_height / 2, 0, total_screw_length - housing_wall_thickness / 2]) {
        difference() {
            cube([mount_height, mount_width, housing_wall_thickness], center = true);

            cube([mount_height, housing_width, housing_wall_thickness], center = true);

            translate([0, mount_screw_separation / 2, 0])
                screw_slot(mount_screw_radius, mount_height / 4 * 3, housing_wall_thickness, center = true);

            translate([0, -mount_screw_separation / 2, 0])
                screw_slot(mount_screw_radius, mount_height / 4 * 3, housing_wall_thickness, center = true);
        }
    }
}

module feeder() {
    if (include_housing)
        color("blue")
            housing();    

    if (include_screw_drive)
        color("green")
            screw_drive();
}

difference() {
    feeder();

    if (cross_section)
        translate([0, 500, 0]) {
            cube([1000, 1000, 1000], center = true);
        }
}
