// case for my custom poker timer (uncomment individual parts to generate prints)

// note: 0.1 inch is 2.54mm, my protoboards (buttons are on) have 0.1"
// spacing, so handy to use that conversion to help calculate offsets
// (combined w/ lots of measuring).

use <text_on/text_on.scad>

RESOLUTION = 36; // how nice to draw the circles
$fn = RESOLUTION;

MAIN_RADIUS = 50; // radius of case

RING_RADIUS = 50; // radius of the ring
RING_WIDTH = 10; // width of the ring
RING_HEIGHT = 1.6; // height of the ring
RING_PEG_HEIGHT = 15+RING_HEIGHT;

PEG_RADIUS = 2;
PEG_HOLE_RADIUS = PEG_RADIUS+0.1; // need a little extra for the holes to get the pegs to fit
PEG_RES = 8; // octagon pegs + the 0.1mm extra in the holes seem to work good
PEG_HOLE_RES = 36;

BATTERY_HEIGHT = 20;
BATTERY_PEG_HEIGHT = 7;

ELECTRONICS_HEIGHT = 20;

// not sure if I want just 4 cards or suits at the cardinal
// directions, or text around it?  Oh, acually, can't use the aces
// because of the border, that'll make the centers completely fall
// out...so suits it is!  Might try the text later...
ACES = "🂡🂱🃁🃑"; // why do these look different here in emacs than in the
	        // openscad editor when I'm using the same font in both?
DO_SUITS = 0;
SUITS = "♠♥♦♣";
TEXT_TOP = "CHUCK'S CUSTOM";
TEXT_BOTTOM = "POKER TIMER";
TEXT_SIZE = 5;
//font = "DejaVuSansMono";
//font = "StardosStencil-Bold";
FONT = "SirinStencil-Regular";


module top_ring() {
  // drawing the ring using cylinder:
  difference() {
    cylinder(r = RING_RADIUS, h = RING_HEIGHT);

    // now the cutouts: added a little to the height for the difference
    // cylinder & suits to make odd display issues w/ preview go away.  BTW,
    // for some reason the center=false isn't really working on the
    // text_on_circle, so the extrusion is always centered on Z=0?

    if (DO_SUITS) {
      TEXT_SIZE = TEXT_SIZE + 1; // bump the suit size up a little
      for (i = [0,1,2,3]) {
        text_on_circle(t=SUITS[i],r=RING_RADIUS-RING_WIDTH/2,font=FONT,size=TEXT_SIZE,rotate=i*90,halign="center",valign="center",extrusion_height=RING_HEIGHT*4);
      }
    } else {
      // text, backwards so it looks right when printed & used:
      rotate([0,180,0]){
        text_on_circle(t=TEXT_TOP,r=RING_RADIUS-RING_WIDTH/2,font=FONT,size=TEXT_SIZE,spacing=1.2,valign="baseline",extrusion_height=RING_HEIGHT*4);
        text_on_circle(t=TEXT_BOTTOM,r=RING_RADIUS-RING_WIDTH/2,font=FONT,size=TEXT_SIZE,spacing=1.2,valign="baseline",extrusion_height=RING_HEIGHT*4,ccw=true);
      }
    }

    // cut out the middle
    cylinder(r = RING_RADIUS - RING_WIDTH, h = RING_HEIGHT*4,center=true); 
  }
  draw_pegs(RING_PEG_HEIGHT,PEG_RADIUS,0,PEG_RES);
}

module draw_pegs(h,r,zoff,fn) {
  $fn = fn;
  // now the pegs, first need to locate where to put them (45 degrees off the
  // cardinals) by using a little math...
  peg_offset = sin(45) * (RING_RADIUS - (RING_WIDTH/2));
  for (x = [-peg_offset,peg_offset]) {
    for (y = [-peg_offset,peg_offset]) {
      translate([x,y,zoff]) {
        cylinder(r=r,h=h);
      }
    }
  }
}

OLED_W = 34;
OLED_H = 36;
OLED_X = 0;
OLED_Y = 15;
OLED_PEG_R = 1.4; // pegs are approx r=1.5, 28.5mm apart, centered 1.8mm above top of OLED
OLED_PEG_Y = OLED_Y + OLED_H/2 + 1.8;
OLED_PEGS = [[-14.25,OLED_PEG_Y],[14.25,OLED_PEG_Y]];

BUTTON_SIDE = 6.3; // 6 w/ a little more room to fit through
BUTTON_Xs = [-12.7,0,12.7]; // button centers .5" or 12.7mm apart
BUTTON_Y = -11;
// the pegs need to be approx 76mm apart in the x, 16mm apart in the y ;
// leftmost x is 11.5mm off the middle of power switch ; bottom y is 4.2mm
// lower than power switch middle, top y is 4.2mm higher than button middle.
BUTTON_PEGS = [[-39,BUTTON_Y+4.2],[37,BUTTON_Y+4.2],[-39,BUTTON_Y-11.8],[37,BUTTON_Y-11.8]];
BUTTON_PEG_R = 0.6;

// power swtich center is -15.24 from leftmost button
POWER_W = 7.5;
POWER_H = 7.5;
POWER_X = BUTTON_Xs[0]-15.24;
POWER_Y = BUTTON_Y-7.62;
FACE_THICK = 2;
FACE_RIM = 1.2;
FACE_RIM_THICK = FACE_THICK+4.5;

module face_plate() {
  difference() {
    cylinder(r = RING_RADIUS, h = FACE_THICK);
    // square hole for OLED:
    translate([OLED_X,OLED_Y,0]) {
      cube([OLED_W,OLED_H,FACE_THICK*4], center=true);
    }
    // and some buttons (with square bases):
    for (x=BUTTON_Xs) {
      translate([x,BUTTON_Y,0]) {
        cube([BUTTON_SIDE,BUTTON_SIDE,FACE_THICK*4],center=true);
      }
    }
    // and the power switch (actually, a toggle button now):
    translate([POWER_X,POWER_Y]) {
      cube([POWER_W,POWER_H,FACE_THICK*4],center=true);
    }
    // now the peg holes:
    draw_pegs(FACE_THICK+1,PEG_HOLE_RADIUS,-1,PEG_HOLE_RES);
  }
  // add pegs to secure OLED and buttons (vector of x/y pairs):
  // (note not real values yet)
  for (peg = OLED_PEGS) {
    translate([peg[0],peg[1]]) {
      cylinder(r=OLED_PEG_R,h=FACE_RIM_THICK);
    }
  }
  for (peg = BUTTON_PEGS) {
    translate([peg[0],peg[1]]) {
      cylinder(r=BUTTON_PEG_R,h=FACE_RIM_THICK);
    }
  }
  // how about a ring around the edge to hide the gap?
  difference() {
    cylinder(r=RING_RADIUS,h=FACE_RIM_THICK);
    cylinder(r=RING_RADIUS-FACE_RIM,h=FACE_THICK*4);
  }
}

BACK_PLATE_THICK = 2;
// OLED pins are centered X 16mm wide, Y at top of oled support pegs (about 1mm)
OLED_PINS_W = 25;
OLED_PINS_H = 6;

module back_plate() {
  difference() {
    cylinder(r = RING_RADIUS, h = BACK_PLATE_THICK);
    // need some holes for OLED pins, maybe just a rectangle, and make it a
    // little bigger than just the pins, to run button/switch wires through
    // too:
    translate([OLED_X,OLED_PEG_Y+OLED_PEG_R]) {
      cube([OLED_PINS_W,OLED_PINS_H,BACK_PLATE_THICK*4],center=true);
    }
    // might want a second one for the button wires actually:
    translate([0,BUTTON_Y-BUTTON_SIDE-5]) {
      cube([OLED_PINS_W,OLED_PINS_H,BACK_PLATE_THICK*4],center=true);
    }
    // now the peg holes:
    draw_pegs(BACK_PLATE_THICK*2,PEG_HOLE_RADIUS,-1,PEG_HOLE_RES);
  }
}

module electronics_compartment() {
  difference() {
    cylinder(r = RING_RADIUS, h = ELECTRONICS_HEIGHT);
    // add pegs for holes
    draw_pegs(ELECTRONICS_HEIGHT,PEG_HOLE_RADIUS,0,PEG_HOLE_RES);
    // cut out the middle, but leave some room
    cylinder(r = RING_RADIUS - RING_WIDTH, h = ELECTRONICS_HEIGHT*4,center=true); 
  }
  // now the bottom plate:
  difference() {
    cylinder(r = RING_RADIUS, h = 2);
    // need the peg holes too:
    draw_pegs(ELECTRONICS_HEIGHT+1,PEG_HOLE_RADIUS,0,PEG_HOLE_RES);
    // and a hole for wires to the battery & sd card
    cylinder(r = PEG_HOLE_RADIUS*3,h = 4);
  }
}

module battery_compartment() {
  difference() {
    cylinder(r = RING_RADIUS, h = BATTERY_HEIGHT);
    // cut out the middle
    cylinder(r = RING_RADIUS - RING_WIDTH, h = BATTERY_HEIGHT*4,center=true); 
  }
  // now the bottom plate:
  cylinder(r = RING_RADIUS, h = 2);
  draw_pegs(BATTERY_PEG_HEIGHT,PEG_RADIUS,BATTERY_HEIGHT-1,PEG_RES);
}

// for a "big display" in one image, set SHOW_OFF to 1, otherwise uncomment a
// part at a time in the next section, render, and generate STL files for each
// part...
SHOW_OFF = 1;
if (SHOW_OFF) {
  translate([0,0,110]) {
    rotate([0,180,0]) {
      color("MediumPurple") top_ring();
    }
  }
  translate([0,0,90]) {
    rotate([0,180,0]) {
      color("White") face_plate();
    }
  }
  translate([0,0,70]) {
    color("White") back_plate();
  }
  translate([0,0,30]) {
    color("White") electronics_compartment();
  }
  translate([0,0,0]) {
    color("White") battery_compartment();
  }
} else {
  // uncomment part to create:

  top_ring();
  //face_plate();
  //back_plate();
  //electronics_compartment();
  //battery_compartment();

}

              
