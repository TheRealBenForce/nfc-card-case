include <BOSL2/std.scad>
include <BOSL2/transforms.scad>

// The parts in this model are made up of planes with each plane being
// an inner cuboid difference from an outer cuboid. 

/* [Container Size] */
// Width of the object.
object_width = 54; // [10:350]

// Height of the object.
object_height = 86; // [10:350]

// Thickness of the object.
object_thickness = 1.6;  // [0.1:0.1:2.0]

// Total thickness of the frame
thickness = 4; // [2:256]

// How much space will be between the object and the frame on each edge. Less than 7 will make 2mm walls too thin.
frame_border = 7; // [2:20] 

// Extended frames offer more customization options, but are still being built.
extended = false; // [true, false]

/* [Max Printer Size] */
printer_max_x = 256; // [100:500]

printer_max_y = 256; // [100:500]

printer_max_z = 256; // [100:500]

/* [Experimental] */
// If parts fit too tight, go up .1, if too loose, go down .1. Read up on BOSL2 $slop if needed.
$slop = 0.3; // [0.0:0.1:0.5]

// This is the thickness of the optional back panel insert. It's a flat piece that can be inserted into the back of the frame.
insert_thickness = .2; // [0.1:0.1:0.5]

overhang = 2; // [1:10]

// 2 seems to be a good value.
wall_thickness = 2; // [1:10]

// Have not noticed any major issues at 1.5
rounding= 1.5; // [0.0:0.5:5.0]

// Some designes allow for magnets to be inserted into the frame. This is the height.
magnet_height = 1.75; // [1:0.1:10]

// Some designes allow for magnets to be inserted into the frame. This is the radius.
magnet_radius = 5.0; // [2.0:0.1:10]

// Haven't tried thinner than .5
plate_thickness = 0.5;  // [0.2:0.1:3.0]


/* [Debug] */
// Smoothness of curved surfaces in preview mode
preview_smoothness = 16; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

opacity = 1; // [0.1:0.1:1.0]
show_object = false; // [true, false]
display = "3D Print"; // [Side by Side, Side by Side Flipped, Together, Front Plate, Back Plate, 3D Print]
rounded_edges = extended ? [BACK+RIGHT,BACK+LEFT] : "Z"; // BOSL2 edge rounding

/* [Hidden] */
$fn = $preview ? preview_smoothness : render_smoothness;
inner_wall_height = thickness - (plate_thickness * 2);
pressure_depth = thickness - object_thickness - insert_thickness; // This is on the front face inside of the frame pushing down on the object
extension_multiplier = .2;
extension_height = extended ? object_height * extension_multiplier : 0; // This is the additional height added.
back_distance = extended ? extension_height / 2: 0; // How far back to move the window from center to keep the desired frame boarder size

// based on thickness but has a max and min value.
latch_size = max(thickness * 0.2, min(thickness * 0.25, 0.8));

object_safe_zone_x = object_width + .5;
object_safe_zone_y = object_height + .5;
object_window_x = object_width - (overhang * 2); // Supports the object from falling through the back

object_window_y = object_height - (overhang * 2); // Supports the object from falling through the back

front_plate_outer_wall_x = object_window_x + (frame_border * 2);
front_plate_outer_wall_y = object_window_y + (frame_border * 2) + extension_height;

back_plate_outer_wall_x = front_plate_outer_wall_x - (wall_thickness * 2) - $slop;
back_plate_outer_wall_y = front_plate_outer_wall_y - (wall_thickness * 2) - $slop;
back_plate_inner_wall_x = back_plate_outer_wall_x - (wall_thickness * 2);
back_plate_inner_wall_y = back_plate_outer_wall_y - (wall_thickness * 2);
back_height = thickness - plate_thickness - $slop;

extension_center_y = (front_plate_outer_wall_y / 2) - (extension_height / 2) - (wall_thickness * 2); // This is the center of the extension space... I think. It's used to place the magnets in the center of the extension space.

echo (str(""));
echo (str("XXXXXXXXX INITIAL VARIABLES XXXXXXXXXXXXX"));
echo (str("Total Thickness: ", thickness));
echo(str("Latch Height: ", latch_size));
echo(str("Pressure Depth: ", pressure_depth));

echo (str("Object Width: ", object_width));
echo (str("Object Height: ", object_height));

echo (str("Object Safe Zone Width: ", object_safe_zone_x));
echo (str("Object Safe Zone Height: ", object_safe_zone_y));

echo (str("Total Width: ", front_plate_outer_wall_x));
echo (str("Total Height: ", front_plate_outer_wall_y));

echo (str("Window Opening Width: ", object_window_x));
echo (str("Window Opening Height: ", object_window_y));

// Everything fits ardound the object:
assert(frame_border - overhang >= 3, "Frame edges are too narrow. frame_border must be greater than the overhang");
assert(back_plate_inner_wall_x >= object_safe_zone_x, "Object is too wide for the frame. Increase frame width.");

// Everything fits on print bed:
assert(thickness <= printer_max_z, "Total thickness is too large for the printer.");
assert(front_plate_outer_wall_x <= printer_max_x, "Total width is too large for the printer.");
assert(front_plate_outer_wall_y <= printer_max_y, "Total height is too large for the printer.");

module object() {
    color([0.5, 1, 0.5])
    cuboid([object_width, object_height,object_thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
}

module magnet_space(support=false) {
    color([0.8, 0.8, 0.8])
    difference() {

      // Outer wall of the magnet holder
      cylinder(back_height, magnet_radius * 1.3, magnet_radius * 1.3, anchor=BOTTOM);
      
      // Slightly larger than the magnet size.
      // Also recesed from the back face a bit to consider
      // magnet height.
      up(back_height - magnet_height - $slop)
      cylinder(magnet_height + $slop, magnet_radius + $slop, magnet_radius + $slop, anchor=BOTTOM);
    }
}

module extension_space() {
  if (extended) {
    xdistribute((back_plate_outer_wall_x / 3)) {
      magnet_space();
      cuboid([wall_thickness, extension_height, back_height], anchor=BOTTOM);
      magnet_space();
    }
  }
}

module window() {
      cuboid([object_window_x, object_window_y, thickness * 2], rounding=rounding, edges=["Z"], anchor=BOTTOM);
}

module front_plate() {
  color([1, 0.94, 0.84], opacity)
    union() {
      
      // Front Face
      difference() {
        cuboid([front_plate_outer_wall_x, front_plate_outer_wall_y, plate_thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
        back(back_distance)
        window();
      }

      // Outer edge
      difference() {
        cuboid([front_plate_outer_wall_x, front_plate_outer_wall_y, thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
        cuboid([front_plate_outer_wall_x - (wall_thickness * 2), front_plate_outer_wall_y - (wall_thickness * 2), thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
      }
      
      // Inner "pressure" edge. It's too thick so use half a standard wall.
      back(back_distance)
      difference() {
        cuboid([object_window_x + (wall_thickness), object_window_y + (wall_thickness), pressure_depth], rounding=rounding, edges=["Z"], anchor=BOTTOM);
        cuboid([object_window_x, object_window_y, thickness - object_thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
      }

      up(thickness * .5)
      latches();
    }
}

module back_plate() {
  color([0.8, 0, 0], opacity)
    union() {

    // Outer wall. This surrounds the object
    difference() {
      cuboid([back_plate_outer_wall_x, back_plate_outer_wall_y, back_height], rounding=rounding, edges=["Z"], anchor=BOTTOM);
      cuboid([back_plate_inner_wall_x, back_plate_inner_wall_y, back_height], rounding=rounding, edges=["Z"], anchor=BOTTOM);

      up(thickness * .5)
      latches(external=false);
    }

    // Safe zone bummp. Holds the object in place. May not always be visible.
    back(back_distance)
    difference() {
        rect_tube(size=[object_safe_zone_x + wall_thickness, object_safe_zone_y + wall_thickness], isize=[object_safe_zone_x, object_safe_zone_y], h=back_height, rounding=rounding, anchor=BOTTOM);
        cube([object_safe_zone_x + wall_thickness, object_safe_zone_y * .8, back_height], anchor=BOTTOM);
        cube([object_safe_zone_x * .8, object_safe_zone_y + wall_thickness,  back_height], anchor=BOTTOM);
    }

    // Bottom face. Object sits on this
    difference() {
      cuboid([front_plate_outer_wall_x - (wall_thickness * 2) - $slop, front_plate_outer_wall_y - (wall_thickness * 2) - $slop, plate_thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);
      back(back_distance)
      window();
    }

    // Everything that goes inside or on top of the extesion space goes here
    fwd(extension_center_y)
    extension_space();
  }
}

module back_panel_insert() {
  color([0.8, 0, 0], 1)
    cuboid([object_width, object_height, insert_thickness], rounding=rounding, edges=["Z"], anchor=BOTTOM);

}

module latch(zrot=0, length=0) {
  zrot(zrot)
  yrot(45)
  cube([latch_size, length, latch_size], center=true);
}

module latches(external=true) {

  latch_x = external ? object_window_x * .8 : object_window_x;
  latch_y = external ? object_window_y * .8 : object_window_y;

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

module side_by_side(flip=false, include_object=false, include_insert=false) {
  xdistribute(front_plate_outer_wall_x + 2) {
      if (include_object) {
        object();
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

if (show_object) {
  up(plate_thickness)
  object();
}
render();