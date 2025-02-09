include <BOSL2/std.scad>
include <BOSL2/transforms.scad>

// The parts in this model are made up of planes with each plane being
// an inner cuboid difference from an outer cuboid. 

/* [Container Size] */
// Width of the card.
card_x= 54; // [50:60]

// Height of the card.
card_y = 86; // [80:90]

// Thickness of the card.
card_z = 1.6;  // [1.1:0.1:2.0]

// Total thickness of the case
thickness = 4; // [4:10]

// How much space will be between the card and the case on each edge. Less than 7 will make the walls too thin.
frame_border = 7; // [7:20] 

/* [Experimental] */
// If parts fit too tight, go up .1, if too loose, go down .1. Read up on BOSL2 $slop if needed.
$slop = 0.2; // [0.0:0.1:0.5]

overhang = 2; // [2:10]

// 2 seems to be a good value.
wall_thickness = 2; // [1:3]

// Have not noticed any major issues at 1.5
rounding= 1.5; // [0.0:0.5:5.0]

// Haven't tried thinner than .5
plate_thickness = 0.5;  // [0.5:0.1:3.0]


/* [Debug] */
// Smoothness of curved surfaces in preview mode
preview_smoothness = 16; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

opacity = 1; // [0.1:0.1:1.0]
show_card = false; // [true, false]
display = "3D Print"; // [Side by Side, Side by Side Flipped, Together, Front Plate, Back Plate, 3D Print]


/* [Hidden] */
$fn = $preview ? preview_smoothness : render_smoothness;
inner_wall_height = thickness - (plate_thickness * 2);

// Good connections at .8
latch_size = wall_thickness * .5;

card_safe_zone_x = card_x + .5;
card_safe_zone_y = card_y + .5;
card_window_x = card_x - (overhang * 2); // Supports the card from falling through the back

card_window_y = card_y - (overhang * 2); // Supports the card from falling through the back

front_plate_outer_wall_x = card_window_x + (frame_border * 2);
front_plate_outer_wall_y = card_window_y + (frame_border * 2);

back_plate_outer_wall_x = front_plate_outer_wall_x - (wall_thickness * 2) - $slop;
back_plate_outer_wall_y = front_plate_outer_wall_y - (wall_thickness * 2) - $slop;
back_plate_inner_wall_x = back_plate_outer_wall_x - (wall_thickness * 2);
back_plate_inner_wall_y = back_plate_outer_wall_y - (wall_thickness * 2);



echo (str(""));
echo (str("XXXXXXXXX INITIAL VARIABLES XXXXXXXXXXXXX"));
echo (str("Total Thickness: ", thickness));

echo (str("Card Width: ", card_x));
echo (str("Card Height: ", card_y));

echo (str("Card Safe Zone Width: ", card_safe_zone_x));
echo (str("Card Safe Zone Height: ", card_safe_zone_y));

echo (str("Total Width: ", front_plate_outer_wall_x));
echo (str("Total Height: ", front_plate_outer_wall_y));

echo (str("Window Opening Width: ", card_window_x));
echo (str("Window Opening Height: ", card_window_y));

assert(frame_border - overhang >= 3, "Frame edges are too narrow. frame_border must be greater than the overhang");
assert(back_plate_inner_wall_x >= card_safe_zone_x, "Card is too wide for the case. Increase case width.");


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
        cuboid([front_plate_outer_wall_x, front_plate_outer_wall_y, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        window();
      }

      // Outer edge
      difference() {
        cuboid([front_plate_outer_wall_x, front_plate_outer_wall_y, thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        cuboid([front_plate_outer_wall_x - (wall_thickness * 2), front_plate_outer_wall_y - (wall_thickness * 2), thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      }
      
      // Inner "pressure" edge. It's too thick so use half a standard wall.
      difference() {
        cuboid([card_window_x + (wall_thickness), card_window_y + (wall_thickness), thickness - card_z], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
        cuboid([card_window_x, card_window_y, thickness - card_z], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      }
      
      up(thickness * .5)
      latches();
    }
}

module back_plate() {
  back_height = thickness - plate_thickness - $slop;
  color([0.8, 0, 0], opacity)
    union() {

    // Outer wall. This surrounds the card
    difference() {
      cuboid([back_plate_outer_wall_x, back_plate_outer_wall_y, back_height], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      cuboid([back_plate_inner_wall_x, back_plate_inner_wall_y, back_height], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);

      up(thickness * .5)
      latches(external=false);
    }
    // Safe zone bummp. Holds the card in place. May not always be visible.
    difference() {
        rect_tube(size=[card_safe_zone_x + wall_thickness, card_safe_zone_y + wall_thickness], isize=[card_safe_zone_x, card_safe_zone_y], h=back_height, rounding=rounding, anchor=BOTTOM);
        cube([card_safe_zone_x + wall_thickness, card_safe_zone_y * .8, back_height], anchor=BOTTOM);
        cube([card_safe_zone_x * .8, card_safe_zone_y + wall_thickness,  back_height], anchor=BOTTOM);
    }

    // Bottom face. Card sits on this
    difference() {
      cuboid([front_plate_outer_wall_x - (wall_thickness * 2) - $slop, front_plate_outer_wall_y - (wall_thickness * 2) - $slop, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
      window();
    }
  }
}

module back_panel_insert() {
  color([0.8, 0, 0], 1)
    cuboid([card_x, card_y, .25], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);

}

module latch(zrot=0, length=0) {
  zrot(zrot)
  yrot(45)
  cube([latch_size, length, latch_size], center=true);
}

module latches(external=true) {

  latch_x = external ? card_window_x * .8 : card_window_x;
  latch_y = external ? card_window_y * .8 : card_window_y;

  union() {
    // Top
    back((front_plate_outer_wall_y / 2) - wall_thickness )
    latch(zrot=90, length=latch_x);

    // Bottom
    fwd((front_plate_outer_wall_y / 2) - wall_thickness )
    latch(zrot=90, length=latch_x);

    // Left
    left((front_plate_outer_wall_x / 2) - wall_thickness )
    latch(length=latch_y);

    // Right
    right((front_plate_outer_wall_x / 2) - wall_thickness )
    latch(length=latch_y);
  }
}

module together() {
   up(thickness)
   xrot(180)
   front_plate();
    back_plate();
}

module side_by_side(flip=false, include_card=false, include_insert=false) {
  xdistribute(front_plate_outer_wall_x + 2) {
      if (include_card) {
        card();
      }

      front_plate();
      if (flip) {
        up(thickness)
        xrot(180)
        back_plate();
      } else {
      back_plate();
      }

      if (include_insert) {
        back_panel_insert();
      } 
  }
}


module render() {
  if (display == "Side by Side") {
    side_by_side();
  } else if (display == "Side by Side Flipped") {
    side_by_side(flip=true);
  } else if (display == "Together") {
    together();
  } else if (display == "Front Plate") {
    front_plate();
  } else if (display == "Back Plate") {
    back_plate();
  } else if (display == "3D Print") {
    side_by_side(include_insert=true);
  }
}

if (show_card) {
  up(plate_thickness)
  card();
}
render();