include <BOSL2/std.scad>
$fn=60;

extrusion_width = 20;
rail_gap_width = 6;
rail_gap_height = 2.5;
channel_width = 11.8;
channel_height = 4;
ridge_height = 1;
CORNER_NONE = 0;
CORNER_FEMALE = 1;
CORNER_MALE = 2;
CORNER_MITER_VERT = 4; 
END_TREAT_NONE = 0;
MITER_HORIZ_LEFT = 1;
MITER_HORIZ_RIGHT = 2;
MALE_CONNECT_RIGHT = 4;
MALE_CONNECT_LEFT = 8;
FEMALE_CONNECT_RIGHT = 16;
FEMALE_CONNECT_LEFT = 32;
MITER_VERT_LEFT = 64;
MITER_VERT_RIGHT = 128;
HANDLE_LEFT = -9999;
HANDLE_RIGHT = 9999;

default_cap_height = 5.5;
default_lip_height = 3.6;
default_lip_width = 12;
default_outside_miter = 0.6;
default_inside_miter = 0.8;

module rail_interior(length) {
    
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

module rail_clip(length,clip_extension) {
    translate([-rail_gap_width/2,-length/2,channel_height-((channel_height+rail_gap_height+clip_extension)/2)])
    difference() {
        cube([rail_gap_width,length,rail_gap_height+clip_extension])
        attach(BOTTOM) prismoid(size1=[channel_width,length],size2=[rail_gap_width-2,length], h=channel_height);
        translate([-(channel_width-rail_gap_width)/2,0,0])
        rotate([180,0,90])
        wedge([length, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width+(channel_width-rail_gap_width)/2,length,0])
        rotate([180,0,-90])
        wedge([length, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width/2,length/2,-channel_height] ) rotate([0,0,90]) prismoid([length,rail_gap_width-2],[length,rail_gap_width-3],h=channel_height);
        translate([1.5,0,-channel_height])
        cube([rail_gap_width-3,length,channel_height+rail_gap_height+clip_extension-1]);
    }           
}

module rail_clip_hole(length,clip_extension) {
    translate([-rail_gap_width/2,-length/2,channel_height-((channel_height+rail_gap_height+clip_extension)/2)])
    difference() {
        cube([rail_gap_width,length,rail_gap_height+clip_extension])
        attach(BOTTOM) prismoid(size1=[channel_width,length],size2=[rail_gap_width-2,length], h=channel_height);
        translate([-(channel_width-rail_gap_width)/2,0,0])
        rotate([180,0,90])
        wedge([length, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
        translate([rail_gap_width+(channel_width-rail_gap_width)/2,length,0])
        rotate([180,0,-90])
        wedge([length, (channel_width-rail_gap_width)/2, (channel_width-rail_gap_width)/2]);
    }           
}
    
module anchored_rail_clip_hole(length,clip_extension=5) {
    x_scale = 0.03;
    y_scale = 0.10;
    z_scale = 0.03;
    total_h = clip_extension+channel_height+rail_gap_height;
    translate([-x_scale,0,((clip_extension+1)-(total_h/2))*z_scale])
    scale([1+x_scale,1+y_scale,1+z_scale])
    union() {
        total_h = clip_extension+channel_height+rail_gap_height;
        rail_clip_hole(length,clip_extension);
        translate([rail_gap_width/2,-length/2,-(clip_extension+1)+(total_h)/2])
        union() {
            cube([2,length,clip_extension+1]);
            translate([2,0,0]) cube([2,length,1.05]);
        }
        
        translate([-rail_gap_width/2,-length/2,-1.25+(total_h)/2]) rotate([0,0,90]) wedge([length,1,1.25]);
        translate([rail_gap_width/2+2-2*x_scale,length/2,(total_h/2)-clip_extension+1.5]) rotate([0,0,-90]) 
            cube([length,1.25,3]);
    }
}
     
module anchored_rail_clip(length,clip_extension) {
    total_h = clip_extension+channel_height+rail_gap_height;

    rail_clip(length,clip_extension);
    translate([rail_gap_width/2,-length/2,-(clip_extension+1)+(total_h)/2])
    union() {
        difference() {
           cube([2,length,clip_extension+1]);
           cube([1.25,length,clip_extension]);
        }
        translate([2,0,0]) cube([2,length,1]);
    }
    translate([-rail_gap_width/2,-length/2,-1.25+(total_h)/2]) rotate([0,0,90]) wedge([10,1,1.25]);
    translate([rail_gap_width/2+2,length/2,(total_h/2)-clip_extension+1.75]) rotate([0,0,-90]) wedge([10,1,2]);
}

module m3_screw(length) {
    cylinder(h= length, r=1.7, center=true);
    translate([0,0,(length-3.1)/2]) cylinder(h = 3.1, r = 2.8, center=true);
}

module m3_heat_inset() {
    cylinder(h= 4, r=2.25, center=true);
}
 
module panel_rail(length,lip_width=default_lip_width,lip_height=default_lip_height, cap_height = default_cap_height,clips=[],clip_width = 10, clip_depth=5,outside_corner_miter_percent = default_outside_miter,inside_corner_miter_percent = default_inside_miter,handles=[],end_treat=END_TREAT_NONE) {
    difference() {
        translate([0,0,lip_height/2])
        cube([extrusion_width,length,cap_height], center = true)
        attach(BOTTOM,TOP) translate([-(extrusion_width-lip_width)/2,0,0]) 
            cube([lip_width,length,lip_height], center = true);
        for(clip = clips) {
            total_h = clip_depth+cap_height+rail_gap_height;
            translate([0,length/2 - clip,(clip_depth+1-total_h/2)-(lip_height+4)/2]) 
            anchored_rail_clip_hole(clip_width,clip_depth);
        }
        
        translate([extrusion_width/2,-length/2,(cap_height+lip_height)*(1-outside_corner_miter_percent+0.5)])
        rotate([-90,0,90])
        wedge([length,cap_height+lip_height,cap_height+lip_height]);
         
        translate([-extrusion_width/2,-length/2,(cap_height+lip_height)/2+cap_height*(1-inside_corner_miter_percent)+0.005])
        rotate([180,0,90])
        wedge([length,cap_height+0.01,cap_height+0.01]);
        
        if(is_end_treat(end_treat,MITER_HORIZ_LEFT)) {
            translate([-10,-length/2,(lip_height+cap_height+1)/2])
            rotate([0,90,0]) wedge([lip_height+cap_height+1,extrusion_width,extrusion_width]);
        }
        
        if (is_end_treat(end_treat,MITER_HORIZ_RIGHT)) {
            translate([-10,length/2,-(lip_height+cap_height+1)/2]) 
            rotate([0,-90,180]) wedge([lip_height+cap_height+1,extrusion_width,extrusion_width]);
        }
        
        if(is_end_treat(end_treat,FEMALE_CONNECT_LEFT)) {
            translate([(extrusion_width-lip_width-4)/2,-(length/2)+8,-(cap_height/2)+0.54])
            union() {
                cube([lip_width-3.8,16,lip_height+1.1], center = true);
                translate([0,0,(lip_height+1.1)/2+2]) m3_heat_inset();
            }
        }
        
        if(is_end_treat(end_treat,FEMALE_CONNECT_RIGHT)) {
            translate([(extrusion_width-lip_width-4)/2,(length/2)-8,-(cap_height/2)+0.54])
            union() {
                cube([lip_width-3.8,16,lip_height+1.1], center = true);
                translate([0,0,(lip_height+1.1)/2+2]) m3_heat_inset();
            }
        }
       
         if (is_end_treat(end_treat,MITER_VERT_RIGHT)) {
            translate([-extrusion_width/2,length/2,(lip_height+cap_height)/2+0.005]) 
            rotate([180,0,0])wedge([extrusion_width,lip_height+cap_height+0.01,lip_height+cap_height+0.01]);
        }
        
        if (is_end_treat(end_treat,MITER_VERT_LEFT)) {
            translate([-extrusion_width/2,-length/2,(lip_height+cap_height)/2+0.005]) 
            rotate([-90,0,0])wedge([extrusion_width,lip_height+cap_height+0.01,lip_height+cap_height+0.01]);
        }
    }
   
    
            
    total_h = cap_height+lip_height;
    handle_edge_size = (cap_height+lip_height)*outside_corner_miter_percent;
    prismoid_base = sqrt((handle_edge_size*handle_edge_size)*2);
    handle_width = 2*handle_edge_size + 2*sqrt((handle_edge_size*handle_edge_size)/2);
    for (handle = handles) {
        handle_calc = (handle == HANDLE_LEFT) ? length - handle_width/2 : (handle == HANDLE_RIGHT) ? handle_width/2 : handle;
        
        translate([(extrusion_width-handle_edge_size)/2,length/2-handle_calc,(total_h-handle_edge_size)/2])
        rotate([0,45,0])
        difference() {
            prismoid(size1=[prismoid_base,handle_width],size2=[0,handle_width-(2*handle_edge_size)],h=prismoid_base/2); 
            translate([1,0,0])
            prismoid(size1=[prismoid_base-1,handle_width-3],size2=[0,handle_width-(2*handle_edge_size)],h=prismoid_base/2-1);
            }
    }
   
    if(is_end_treat(end_treat,MALE_CONNECT_RIGHT)) {
        translate([(extrusion_width-lip_width-4)/2,length/2+8,-(cap_height/2)+0.45])
        difference() {
            cube([lip_width-4.2,16,lip_height+0.9], center = true);
            translate([0,0.2,7/2-(lip_height+0.9)/2]) rotate([0,180,0]) m3_screw(7);
        }
    }
    if(is_end_treat(end_treat,MALE_CONNECT_LEFT)) {
        translate([(extrusion_width-lip_width-4)/2,-(length/2+8),-(cap_height/2)+0.45])
        difference() {
            cube([lip_width-4.2,16,lip_height+0.9], center = true);
            translate([0,-0.2,7/2-(lip_height+0.9)/2]) rotate([0,180,0]) m3_screw(7);
        }
    }
 }
 
 function is_end_treat(value, treat) = floor(value/treat)%2 == 1;
 
 module corner_rail(corner_size,clips,end_connect = CORNER_NONE) {
    clip_offset_x = (corner_size[0] - extrusion_width)*(clips[0])+extrusion_width;
    clip_offset_y = (corner_size[1] - extrusion_width)*(1-clips[1]);
    corner_end_y = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_RIGHT : (end_connect == CORNER_FEMALE) ? FEMALE_CONNECT_RIGHT : MITER_VERT_RIGHT;
    corner_end_x = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_LEFT : (end_connect == CORNER_FEMALE) ? FEMALE_CONNECT_LEF4 : MITER_VERT_LEFT;
    
    union() {
        panel_rail(length=corner_size[1],clips = [clip_offset_y],clip_depth=5,handles=[HANDLE_LEFT],end_treat=MITER_HORIZ_LEFT+corner_end_y);
        translate([-corner_size[0]/2+extrusion_width/2,-corner_size[1]/2+extrusion_width/2,0]) rotate([0,0,-90])
        panel_rail(length=corner_size[0],clips = [clip_offset_x],clip_depth=5,handles=[HANDLE_RIGHT],end_treat=MITER_HORIZ_RIGHT+corner_end_x);   
        translate([-4/2,-(corner_size[1])/2+default_lip_width,-(default_cap_height+default_lip_height)/2]) rotate([0,-90,0]) wedge([0.5,10,10]); 
        echo(default_cap_height-default_lip_height);
        
        translate([-extrusion_width/2+default_cap_height,-(corner_size[1])/2+extrusion_width-default_cap_height,-(default_cap_height-default_lip_height)/2]) 
            rotate([0,-90,0]) 
                difference() {
                    wedge([default_cap_height,10+default_cap_height,10+default_cap_height]);
                    hyp = sqrt(2 * (10+default_cap_height)*(10+default_cap_height));
                    translate([default_cap_height*(2-default_inside_miter),0,default_cap_height+10])
                    rotate([-90,45,90])
                    wedge([hyp,default_cap_height+0.01,default_cap_height+0.01]);
                }
    }
 }
 
 module clip_in_rail() {
    union() {
      panel_rail(length=50, lip_width=12,lip_height = 3.5,clip_depth=5,cap_height=5.5, outside_corner_miter_percent=0.6,inside_corner_miter_percent=0.8,clips=[5]);
      translate([0,20,-4.25]) 
      anchored_rail_clip(10,5);
    }
}

module joint() {
    translate([0,-25.1,0])
    panel_rail(length=50,clip_depth=5,end_treat=MALE_CONNECT_RIGHT+MALE_CONNECT_LEFT);
    translate([0,25.1,0])
    panel_rail(length=50,clip_depth=5,end_treat=FEMALE_CONNECT_LEFT+FEMALE_CONNECT_RIGHT);
}

module stand_alone_side_retainer() {
    panel_rail(length=37,clips=[18.5],handles=[18.5],end_treat=MITER_VERT_RIGHT+MITER_VERT_LEFT);
}

module stand_alone_corner_retainer() {
    corner_rail(corner_size=[45,45],clips=[0.4,0.4],end_connect=CORNER_MITER_VERT);
}

//translate([0,50,0]) stand_alone_side_retainer();
stand_alone_corner_retainer();
//translate([-12.5,113,0]) rotate([0,0,90]) stand_alone_corner_retainer();
//joint();
//clip_in_rail();
//rail_clip(10,5);
//rail_interior(10);
//rail_clip_hole(10,5);
//anchored_rail_clip(10,5);
//anchored_rail_clip_hole(10,5);
//m3_screw(10);

