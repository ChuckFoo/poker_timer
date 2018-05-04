// make a couple of r=2mm pegs to try w/ varying numbers of sides

module make_peg(r,fn) {
  h=10;
  cylinder(r=r, h=h, $fn=fn);
}

module make_pegs(r) {
  translate([-15,0,0]) make_peg(r,6);
  translate([0,0,0]) make_peg(r,8);
  translate([15,0,0]) make_peg(r,100); // effectively round
  cube([45,10,2],center=true);
}

module make_hole(r,fn) {
  cylinder(r=r,h=5,center=true,$fn=fn);
}


module make_holes(r,fn) {
  difference() {
    cube([45,10,2],center=true);
    for (i=[0,1,2,3,4,5]) {
      translate([-18+i*7,0,0]) {
        make_hole(r+(i/20),fn);
      }
    }
  }
}

// make some pegs, r=2mm, with a couple of different number of sides
//make_pegs(2);

// now make some holes (round) starting at r=2mm and increasing by .05mm
//translate([0,-15,0]) {
//  make_holes(2,100);
//}

// for some button covers the button post is round and about 3.34mm diameter,
// so need to test some not round holes starting at half that radius...
//translate([0,-30,0]) {
  bcr = 1.8; // 3.4mm diameter -> 1.7mm radius, pad it slightly to 1.8mm?
  make_holes(bcr,12);
//}
