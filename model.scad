include <BOSL2/std.scad>
include <BOSL2/transforms.scad>

/* [Container Size] */
card_x= 54; // [50:60]
card_y = 86; // [80:90]
card_z = 2;  // [1.1:0.1:2.0]

// Total thickness of the case
thickness = 5; // [4:10]

// How much space will be between the card and the case on each edge.
padding = 5; // [5:10]

// How much of the NFC card face will be covered from each edge.
overhang = 4; // [2:6]

/* [Tolerances] */
// Smoothness of curved surfaces in preview mode
preview_smoothness = 16; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

// The printer-specific slop value to make parts fit just right. Read more here: https://github.com/BelfrySCAD/BOSL2/wiki/constants.scad#constant-slop
$slop = 0.2;


/* [Experimental] */
wall_thickness = 2; // [1:3]
rounding= 1.5; // [0.1:1.5]
latch_size = 1; // [0.1:0.5]
plate_thickness = 1.0;  // [0.5:0.1:3.0]

/* [Hidden] */
$fn = $preview ? preview_smoothness : render_smoothness;
inner_wall_height = thickness - (plate_thickness * 2);

card_safe_zone_x = card_x + 1;
card_safe_zone_y = card_y + 1;




case_x = card_x + (padding * 2);
case_y = card_y + (padding * 2);
case_z = thickness;

case_x_window = card_x - (overhang * 2);
case_y_window = card_y - (overhang * 2);

echo (str(""));
echo (str("XXXXXXXXX INITIAL VARIABLES XXXXXXXXXXXXX"));
echo (str("Card Width: ", card_x));
echo (str("Card Height: ", card_y));
echo (str("Card Safe Zone Width: ", card_safe_zone_x));
echo (str("Card Safe Zone Height: ", card_safe_zone_y));
echo (str("Total Width: ", case_x));
echo (str("Total Height: ", case_y));
echo (str("Total Thickness: ", case_z));

echo (str("Window Opening Width: ", case_x_window));
echo (str("Window Opening Height: ", case_y_window));

module card() {
    color([0.5, 1, 0.5])
    cube([card_x ,card_y,card_z], anchor=BOTTOM);
}

module magnet() {
    color([0.8, 0.8, 0.8])
    cylinder(1.75, 3, 3);
}

module plate(is_open=true, face="front") {
  color([0.5, 0.5, 0.5])

  difference() {
    if (face == "front") {
      cuboid([case_x, case_y, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
    } else {
      cuboid([case_x - (wall_thickness * 2) - $slop, case_y - (wall_thickness * 2) - $slop, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
    }

    if (is_open) {
    echo (str("Back Opening X: ", card_x - (overhang * 2)));
    echo (str("Back Opening Y: ", card_y - (overhang * 2)));

    down(1)
      cuboid([card_x - (overhang * 2) , card_y - (overhang * 2), plate_thickness + 2], anchor=BOTTOM);
    }
  }
}

module front_plate() {
  color([1, 0.94, 0.84], 1)

  difference() {
  union() {
    up(thickness / 2)
    latches();
    rect_tube(size=[case_x, case_y], wall=wall_thickness, rounding=rounding, h=case_z, anchor=BOTTOM);
    rect_tube(size=[case_x_window + wall_thickness, case_y_window + wall_thickness], isize=[case_x_window, case_y_window],wall=wall_thickness, rounding=rounding, h=case_z - card_z, anchor=BOTTOM);
    plate();
    }

    // removal slot
    fwd((case_y / 2) - wall_thickness )
    up(thickness)
    cuboid([padding * 3, wall_thickness * 2, plate_thickness * 3], anchor=TOP);
  }
}

module back_plate(is_open=true) {
  color([0.8, 0, 0], 1)
  difference() {
    union() {
      rect_tube(size=[case_x - (wall_thickness * 2) - $slop, case_y - (wall_thickness * 2) - $slop], isize=[card_safe_zone_x, card_safe_zone_y], wall=wall_thickness, rounding=rounding, h=case_z - plate_thickness, anchor=BOTTOM);
      plate(is_open=is_open, face="back");
    }
    
    // latches
    up(thickness / 2)
    latches();

    // removal slot
    fwd((case_y / 2) - wall_thickness )
    up(thickness / 3)
    cuboid([padding * 3, wall_thickness * 2, 1], anchor=BOTTOM);

    up(case_z - plate_thickness - .2) // Make some space to fit
    cube([case_x, case_y, case_z], anchor=BOTTOM);
  }
}

module latch(zrot=0, length=25) {
  zrot(zrot)
  yrot(45)
  cube([latch_size, length, latch_size], center=true);
}

module latches() {
  union() {
    // Top
    back((case_y / 2) - wall_thickness )
    latch(90);

    // Left
    left((case_x / 2) - wall_thickness )
    latch(length=case_y_window);

    // Right
    right((case_x / 2) - wall_thickness )
    latch(length=case_y_window);
  }
}

module together() {
    front_plate();
    up(case_z)
    xrot(180)
    back_plate();
}

module side_by_side() {
  xdistribute(case_x + 2) {
      front_plate();
      back_plate();
  }
}

side_by_side();