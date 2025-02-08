include <BOSL2/std.scad>
include <BOSL2/transforms.scad>

display = "3d_print"; // [side_by_side, together, front_plate, back_plate, 3d_print]

/* [Container Size] */
card_x= 54; // [50:60]
card_y = 86; // [80:90]
card_z = 1.6;  // [1.1:0.1:2.0]

// Total thickness of the case
thickness = 4; // [4:10]

// How much space will be between the card and the case on each edge. Less than 6 will make the walls too thin.
frame_border = 6; // [5:10] 



/* [Tolerances] */
// Smoothness of curved surfaces in preview mode
preview_smoothness = 16; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

// The printer-specific slop value to make parts fit just right. Read more here: https://github.com/BelfrySCAD/BOSL2/wiki/constants.scad#constant-slop
$slop = 0.2;


/* [Experimental] */
// How much of the NFC card face will be covered from each edge.
overhang = 2; // [2:10]

wall_thickness = 2; // [1:3]
rounding= 1.5; // [0.1:1.5]
latch_size = .8; // [0.1:0.5]
plate_thickness = 0.5;  // [0.5:0.1:3.0]
opacity = 1; // [0.1:0.1:1.0]

/* [Hidden] */
$fn = $preview ? preview_smoothness : render_smoothness;
inner_wall_height = thickness - (plate_thickness * 2);


card_safe_zone_x = card_x + .5;
card_safe_zone_y = card_y + .5;


card_window_x = card_x - (overhang * 2); // Supports the card from falling through the back
card_window_y = card_y - (overhang * 2); // Supports the card from falling through the back
case_x = card_window_x + (frame_border * 2);
case_y = card_window_y + (frame_border * 2);

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
    cuboid([card_x ,card_y,card_z], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
}

module magnet() {
    color([0.8, 0.8, 0.8])
    cylinder(1.75, 3, 3);
}

module window() {
    cuboid([card_window_x, card_window_y, thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
}

module front_plate() {
  color([1, 0.94, 0.84], opacity)
    union() {
      
      // Front Face
      difference() {
        cuboid([case_x, case_y, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        window();
      }

      // Outer edge
      difference() {
        cuboid([case_x, case_y, thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        cuboid([case_x - (wall_thickness * 2), case_y - (wall_thickness * 2), thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);

      }
      
      //// Inner "pressure" edge
      difference() {
        cuboid([card_window_x + (wall_thickness * 2), card_window_y + (wall_thickness * 2), thickness - card_z], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        cuboid([card_window_x, card_window_y, thickness - card_z], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      }
      
      up(thickness * (3/5))
      latches();
    }
}

module back_plate() {
  color([0.8, 0, 0], opacity)
    union() {

    // Outer wall. This surrounds the card
    difference() {
      cuboid([card_safe_zone_x + (wall_thickness * 2) - $slop, card_safe_zone_y + (wall_thickness * 2) - $slop, thickness - plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      cuboid([card_safe_zone_x, card_safe_zone_y, thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);

      up(thickness * (2/5))
      latches();
    }

    // Bottom face. Card sits on this
    difference() {
      cuboid([card_safe_zone_x + (wall_thickness * 2) - $slop, card_safe_zone_y + (wall_thickness * 2) - $slop, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      window();
    }
  }
}

module back_panel_insert() {
  color([0.8, 0, 0], 1)
    cuboid([card_x, card_y, .25], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);

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
    latch(length=card_window_y);

    // Right
    right((case_x / 2) - wall_thickness )
    latch(length=card_window_y);
  }
}

module together() {
   up(thickness)
   xrot(180)
   front_plate();
    back_plate();
}

module side_by_side(include_card=false, include_insert=false) {
  xdistribute(case_x + 2) {
      if (include_card) {
        card();
      }
      front_plate();
      back_plate();
      if (include_insert) {
        back_panel_insert();
      } 
  }
}


module render() {
  if (display == "side_by_side") {
    side_by_side();
  } else if (display == "together") {
    together();
  } else if (display == "front_plate") {
    front_plate();
  } else if (display == "back_plate") {
    back_plate();
  } else if (display == "3d_print") {
    side_by_side(include_insert=true);
  }
}

render();