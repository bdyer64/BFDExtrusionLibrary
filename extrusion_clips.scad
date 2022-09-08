include <BOSL2/std.scad>
include <constants.scad>
$fn=60;

render_test = false;

module extrusion_interior(length) {
    
    attachable(CENTER,0,UP, size=[channel_width,length,channel_height+rail_gap_height]) {
        translate([0,0,(channel_height-rail_gap_height-ridge_height)/2])
        cube([channel_width,length,ridge_height], center=true)
        {
            attach(CENTER,TOP) cube([rail_gap_width,length,rail_gap_height]);
            attach(BOTTOM) prismoid(size1=[channel_width,length],size2=[channel_width-((channel_height-ridge_height) *2),length], h=channel_height-ridge_height);
        }
        children();
    }
}

module extrusion_clip(width=default_clip_width,clip_extension=default_clip_depth) {
    translate([-rail_gap_width/2,-width/2,channel_height-((channel_height+rail_gap_height+clip_extension)/2)])
    difference() {
        cube([rail_gap_width,width,rail_gap_height+clip_extension])
        attach(BOTTOM) prismoid(size1=[channel_width,width],size2=[rail_gap_width-2,width], h=channel_height);
        translate([-(channel_width-rail_gap_width)/2,0,0])
        rotate([180,0,90])
        wedge([width, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width+(channel_width-rail_gap_width)/2,width,0])
        rotate([180,0,-90])
        wedge([width, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width/2,width/2,-channel_height] ) rotate([0,0,90]) prismoid([width,rail_gap_width-2],[width,rail_gap_width-3],h=channel_height);
        translate([1.5,0,-channel_height])
        cube([rail_gap_width-3,width,channel_height+rail_gap_height+clip_extension-1]);
    }           
}

module extrusion_clip_hole(width=default_clip_width,clip_extension=default_clip_depth) {
    translate([-rail_gap_width/2,-width/2,channel_height-((channel_height+rail_gap_height+clip_extension)/2)])
    difference() {
        cube([rail_gap_width,width,rail_gap_height+clip_extension])
        attach(BOTTOM) prismoid(size1=[channel_width,width],size2=[rail_gap_width-2,width], h=channel_height);
        translate([-(channel_width-rail_gap_width)/2,0,0])
        rotate([180,0,90])
        wedge([width, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width+(channel_width-rail_gap_width)/2,width,0])
        rotate([180,0,-90])
        wedge([width, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
    }           
}
    
module offset_anchored_extrusion_clip(width=default_clip_width,clip_extension=default_clip_depth)  {
    total_h = clip_extension+channel_height+rail_gap_height;

    extrusion_clip(width,clip_extension);
    translate([rail_gap_width/2,-width/2,-(clip_extension+1)+(total_h)/2])
    union() {
        difference() {
           cube([2,width,clip_extension+1]);
           cube([1.25,width,clip_extension]);
        }
        translate([2,0,0]) cube([2,width,1]);
    }
    translate([-rail_gap_width/2,-width/2,-1.25+(total_h)/2]) rotate([0,0,90]) wedge([10,1,1.25]);
    translate([rail_gap_width/2+2,width/2,(total_h/2)-clip_extension+1.75]) rotate([0,0,-90]) wedge([10,1,2]);
}
    
module offset_anchored_extrusion_clip_hole(width=default_clip_width,clip_extension=default_clip_depth) {
    x_scale = 0.03; // BFDFIX- should paramaterize these
    y_scale = 0.10;
    z_scale = 0.03;
    total_h = clip_extension+channel_height+rail_gap_height;
    translate([-x_scale,0,((clip_extension+1)-(total_h/2))*z_scale])
    scale([1+x_scale,1+y_scale,1+z_scale])
    union() {
        total_h = clip_extension+channel_height+rail_gap_height;
        extrusion_clip_hole(width,clip_extension);
        translate([rail_gap_width/2,-width/2,-(clip_extension+1)+(total_h)/2])
        union() {
            cube([2,width,clip_extension+1]);
            translate([2,0,0]) cube([2,width,1.05]);
        }
        
        translate([-rail_gap_width/2,-width/2,-1.25+(total_h)/2]) rotate([0,0,90]) wedge([width,1,1.25]);
        translate([rail_gap_width/2+2-2*x_scale,width/2,(total_h/2)-clip_extension+1.5]) rotate([0,0,-90]) 
            cube([width,1.25,3]);
    }
}
    
if (render_test) {
    extrusion_clip();
    translate([10,0,0])
    extrusion_clip_hole();
    translate([20,0,0])
    offset_anchored_extrusion_clip();
    translate([32,0,0])
    offset_anchored_extrusion_clip_hole();
}
