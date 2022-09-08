$fn=60;

module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );
       
       }

// This is a bit of a mess but it works for a 20x20 extrusion
// will port it to the BOSL library when I get a chance
module wire_cover(length) {
    rotate([0,-90,0])
    {
    difference() {
        translate([-1.25,0,0]) cube([0.5,10,length],center=true);
        
        translate([1.5,-7.5,(length+2)/2])
        rotate([0,90,90])
        prism(length+2, 3, 3);

        translate([-1.5,4.5,(length+2)/2])
        rotate([0,90,0])
        prism(length+2, 3, 3);
    }

    difference() {
        cube([3,6,length] ,center=true);
        translate([1.25,0,0]) cylinder(length+2,2.25,2.25,center=true);
        
        translate([-1,2.5,(length+2)/2])
        rotate([0,90,0])
        prism(length+2, 3, 3);

        translate([2,-5.5,(length+2)/2])
        rotate([0,90,90])
        prism(length+2, 3, 3);
    }
       
     translate([1.25,3,0]) cylinder(length,0.25,0.25, center=true);
     translate([1.25,-3,0]) cylinder(length,0.25,0.25, center=true);
     
     }
}

wire_cover(50);
