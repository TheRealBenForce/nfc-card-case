include <BOSL2/std.scad>
include <BOSL2/transforms.scad>

/* [Container Size] */
card_x= 54; // [50:60]
card_y = 86; // [80:90]
card_z = 2;  // [1.1:0.1:2.0]

// Total thickness of the case
thickness = 5; // [5:10]

// How much space will be between the card and the case.
padding = 5; // [5:10]

// How much of the NFC card face will be covered.
overhang = 4; // [2:6]

/* [Tolerances] */
// Smoothness of curved surfaces in preview mode
preview_smoothness = 16; // [8:128]

// Smoothness of curved surfaces in render mode
render_smoothness = 64; // [8:128]

// The printer-specific slop value to make parts fit just right. Read more here: https://github.com/BelfrySCAD/BOSL2/wiki/constants.scad#constant-slop
$slop = 0.3;


/* [Experimental] */
rounding= 1.0; // [0.1:1.5]
latch_size = 1; // [0.1:0.5]

/* [Hidden] */
$fn = $preview ? preview_smoothness : render_smoothness;
plate_thickness = 1;
wall_thickness = 3;
inner_wall_height = thickness - (plate_thickness * 2);


case_x = card_x + (padding * 2);
case_y = card_y + (padding * 2);
case_z = (plate_thickness * 2 + inner_wall_height);

echo (str(""));
echo (str("XXXXXXXXX INITIAL VARIABLES XXXXXXXXXXXXX"));
echo (str("Total Width: ", case_x));
echo (str("Total Height: ", case_y));
echo (str("Total Thickness: ", case_z));


module card() {
    color([0.5, 1, 0.5])
    cube([card_x ,card_y,card_z], anchor=CENTER);
}

module magnet() {
    color([0.8, 0.8, 0.8])
    cylinder(1.75, 3, 3);
}

module plate() {
  color([0.5, 0.5, 0.5])
  difference() {
    cuboid([case_x , case_y, plate_thickness], rounding=rounding, edges=[FRONT+LEFT,FRONT+RIGHT,BACK+RIGHT,BACK+LEFT], anchor=BOTTOM);
    down(1)
    cube([card_x - overhang , card_y - overhang, plate_thickness + 2], anchor=BOTTOM);
  }
}



module front_plate() {
  
  union() {
    latches();
    //color([0.5, 0.5, 0.5])
    up(plate_thickness) {
      difference() {

        // walls
        rect_tube(size=[case_x, case_y], wall=padding + (overhang / 2), h=inner_wall_height, rounding=rounding);
        rect_tube(size=[case_x - wall_thickness, case_y - wall_thickness], wall=padding + (overhang / 2) - (wall_thickness), h=100);
        
        // Make space for the card to fit.
        up(inner_wall_height + plate_thickness - card_z)
        cube(size=[case_x - wall_thickness, case_y - wall_thickness, 10], anchor=BOTTOM);
      
        // removal space cutout
        fwd(case_y / 2)
        up(inner_wall_height / 2)
        cube([4, wall_thickness + .1 , inner_wall_height / 2], anchor=BOTTOM);    
      }
    }
    plate();
  }
}


module back_plate() {
  union() {
    up(plate_thickness) {
      card_support();
      
      // outer wall
      difference() {
        rect_tube(size=[case_x - wall_thickness - $slop, case_y - wall_thickness - $slop], wall=wall_thickness / 2, h=inner_wall_height, rounding=rounding);
        latches();
      }
    }
    plate();
  }
}

module card_support() {
  color([1, 0, 0])
  union()  {
    difference() {
      rect_tube(size=[card_x + 3, card_y + 3], wall=wall_thickness / 2, rounding=rounding, h=inner_wall_height, anchor=BOTTOM);
      down(1)
      cube([100, card_y - 8, thickness * 2], anchor=BOTTOM);
      down(1)
      cube([card_x - 8, 100, thickness * 2], anchor=BOTTOM);
    }
      right((card_x / 2) + 1)
      cube([wall_thickness / 2, 16, inner_wall_height], anchor=BOTTOM);

      left((card_x / 2) + 1)
      cube([wall_thickness / 2, 16, inner_wall_height], anchor=BOTTOM);

      // Top
      back((card_y / 2) + 1)
      cube([8, wall_thickness / 2, inner_wall_height], anchor=BOTTOM);

      // Bottom
      left((card_x / 4))
      fwd((card_y / 2) + 1)
      cube([8, wall_thickness / 2, inner_wall_height], anchor=BOTTOM);

      right((card_x / 4))
      fwd((card_y / 2) + 1)
      cube([8, .5, inner_wall_height], anchor=BOTTOM);
  }
}

module latch(zrot=0) {
  up(thickness / 2)
  zrot(zrot)
  yrot(45)
  cube([latch_size, 25, latch_size], center=true);
}

module latches(zrot=0) {
  union() {
    // Top
    back((case_y / 2) - (wall_thickness / 2))
    latch(90);

    // Left
    left((case_x / 2) - (wall_thickness / 2))
    fwd(case_x * .25)
    latch();

    left((case_x / 2) - (wall_thickness / 2))
    fwd(-case_x * .25)
    latch();

    // Right
    right((case_x / 2) - (wall_thickness / 2))
    fwd(case_x * .25)
    latch();

    right((case_x / 2) - (wall_thickness / 2))
    fwd(- case_x * .25)
    latch();
  }
}

color([0.5, 0.5, 0.5]) {
  xdistribute(case_x + 2) {
      front_plate();
      //back_plate();
  }
}


