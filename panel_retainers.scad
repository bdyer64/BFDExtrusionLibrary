include <BOSL2/std.scad>
include <constants.scad>
include <extrusion_clips.scad>
$fn=60;

retainer_render_test = false;

module m3_screw(length) {
    cylinder(h= length, r=1.7, center=true);
    translate([0,0,(length-3.1)/2]) cylinder(h = 3.1, r = 2.8, center=true);
}

module m3_heat_inset() {
    cylinder(h= 4, r=2.25, center=true);
}
 
module panel_retainer(length,lip_width=default_lip_width,lip_height=default_lip_height, cap_height = default_cap_height,clips=[],clip_width = default_clip_width, clip_depth=default_clip_depth,outside_corner_miter_percent = default_outside_miter,inside_corner_miter_percent = default_inside_miter,handles=[],end_treat=END_TREAT_NONE) {
    difference() {
        translate([0,0,lip_height/2])
        cube([extrusion_width,length,cap_height], center = true)
        attach(BOTTOM,TOP) translate([-(extrusion_width-lip_width)/2,0,0]) 
            cube([lip_width,length,lip_height], center = true);
        for(clip = clips) {
            total_h = clip_depth+cap_height+rail_gap_height;
            translate([0,length/2 - clip,(clip_depth+1-total_h/2)-(lip_height+4)/2]) 
            offset_anchored_extrusion_clip_hole(clip_width,clip_depth);
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
 
 module corner_panel_retainer(corner_size,clips,lip_height=3.6, clip_depth = 5, end_connect = CORNER_NONE) {
    clip_offset_x = (corner_size[0] - extrusion_width)*(clips[0])+extrusion_width;
    clip_offset_y = (corner_size[1] - extrusion_width)*(1-clips[1]);
    corner_end_y = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_RIGHT : (end_connect == CORNER_FEMALE) ? FEMALE_CONNECT_RIGHT : MITER_VERT_RIGHT;
    corner_end_x = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_LEFT : (end_connect == CORNER_FEMALE) ? FEMALE_CONNECT_LEF4 : MITER_VERT_LEFT;
    
    union() {
        panel_retainer(length=corner_size[1],clips = [clip_offset_y],lip_height=lip_height,clip_depth=clip_depth,handles=[HANDLE_LEFT],end_treat=MITER_HORIZ_LEFT+corner_end_y);
        translate([-corner_size[0]/2+extrusion_width/2,-corner_size[1]/2+extrusion_width/2,0]) rotate([0,0,-90])
        panel_retainer(length=corner_size[0],clips = [clip_offset_x],lip_height=lip_height,clip_depth=clip_depth,handles=[HANDLE_RIGHT],end_treat=MITER_HORIZ_RIGHT+corner_end_x);   
        translate([-4/2,-(corner_size[1])/2+default_lip_width,-(default_cap_height+lip_height)/2]) rotate([0,-90,0]) wedge([lip_height-3.1,10,10]); 
        
        translate([-extrusion_width/2+default_cap_height,-(corner_size[1])/2+extrusion_width-default_cap_height,-(default_cap_height-lip_height)/2]) 
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
 
 module clip_in_rail_3mm() {
    union() {
      panel_retainer(length=50, lip_width=12,lip_height = 3.5,clip_depth=5,cap_height=5.5, outside_corner_miter_percent=0.6,inside_corner_miter_percent=0.8,clips=[5]);
      translate([0,20,-4.25]) 
      offset_anchored_extrusion_clip(10,5);
    }
}

 module clip_in_rail_5mm() {
    union() {
      panel_retainer(length=50, lip_width=12,lip_height = 5.5,clip_depth=7,cap_height=5.5, outside_corner_miter_percent=0.6,inside_corner_miter_percent=0.8,clips=[5]);
      translate([0,20,-4.25]) 
      offset_anchored_extrusion_clip(10,7);
    }
}

module joint_3mm() {
    translate([0,-25.1,0])
    panel_retainer(length=50,clip_depth=5,end_treat=MALE_CONNECT_RIGHT+MALE_CONNECT_LEFT);
    translate([0,25.1,0])
    panel_retainer(length=50,clip_depth=5,end_treat=FEMALE_CONNECT_LEFT+FEMALE_CONNECT_RIGHT);
}
module joint_5mm() {
    translate([0,-25.1,0])
    panel_retainer(length=50,clip_depth=7,lip_height=5.6, end_treat=MALE_CONNECT_RIGHT+MALE_CONNECT_LEFT);
    translate([0,25.1,0])
    panel_retainer(length=50,clip_depth=7,lip_height=5.6, end_treat=FEMALE_CONNECT_LEFT+FEMALE_CONNECT_RIGHT);
}


module stand_alone_side_retainer_3mm() {
    panel_retainer(length=37,clips=[18.5],handles=[18.7],end_treat=MITER_VERT_RIGHT+MITER_VERT_LEFT);
}

module stand_alone_side_retainer_5mm() {
    panel_retainer(length=45,clips=[22.5],handles=[22.5],lip_height=5.6,clip_depth=7,end_treat=MITER_VERT_RIGHT+MITER_VERT_LEFT);
}

module stand_alone_corner_retainer_3mm() {
    corner_panel_retainer(corner_size=[45,45],clips=[0.4,0.4],end_connect=CORNER_MITER_VERT);
}

module stand_alone_corner_retainer_5mm() {
    corner_panel_retainer(corner_size=[45,45],clips=[0.4,0.4],lip_height=5.6,clip_depth=7,end_connect=CORNER_MITER_VERT);
}


module test() {
    clip_in_rail_3mm();
    translate([25,0,0])
    clip_in_rail_5mm();
    translate([50,0,0])
    joint_3mm();
    translate([75,0,0])
    joint_5mm(); //BFDFIX - this one isn't right, make tab depth constant
    translate([-25,0,0])
    stand_alone_side_retainer_3mm();
    translate([-50,0,0])
    stand_alone_side_retainer_5mm();
    translate([-75,0,0])
    stand_alone_corner_retainer_3mm();
    translate([-125,0,0])
    stand_alone_corner_retainer_5mm();
}

if(retainer_render_test) {
    test();
}