// make a couple of r=2mm pegs to try w/ varying numbers of sides

module make_peg(fn) {
  r=2;
  h=10;
  cylinder(r=r, h=h, $fn=fn);
}

translate([-15,0,0]) make_peg(6);
translate([0,0,0]) make_peg(8);
translate([15,0,0]) make_peg(100); // effectively round
cube([45,10,2],center=true);

// now make some holes (round) starting at r=2mm and increasing by .05mm

module make_hole(r) {
  cylinder(r=r,h=5,center=true);
}

$fn=100; // effectively round holes
translate([0,-15,0]) {
  difference() {
    cube([45,10,2],center=true);
    for (i=[0,1,2,3,4,5]) {
      translate([-18+i*7,0,0]) {
        cylinder(r=2+(i/20),h=5,center=true);
      }
    }
  }
}


