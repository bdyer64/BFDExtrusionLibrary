include <../extrusion_lib.scad>

module corner_rail(corner_size,clips,end_connect = CORNER_NONE) {
    clip_offset_x = (corner_size[0] - extrusion_width)*(clips[0])+extrusion_width;
    clip_offset_y = (corner_size[1] - extrusion_width)*(1-clips[1]);
    corner_end_x = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_RIGHT : FEMALE_CONNECT_RIGHT;
    corner_end_y = (end_connect == CORNER_NONE) ? END_TREAT_NONE : (end_connect == CORNER_MALE) ? MALE_CONNECT_LEFT : FEMALE_CONNECT_LEFT;
    echo(corner_end_x);
    echo(clip_offset_x);
    union() {
        panel_rail(length=corner_size[0],clips = [clip_offset_y],clip_depth=5,cap_height=5.5,outside_corner_miter_percent=0.7,inside_corner_miter_percent=0.8,handles=[HANDLE_LEFT],end_treat=MITER_HORIZ_LEFT+corner_end_x);
        translate([-corner_size[1]/2+extrusion_width/2,-corner_size[0]/2+extrusion_width/2,0]) rotate([0,0,-90])
        panel_rail(length=corner_size[1],clips = [clip_offset_x],clip_depth=5,cap_height=5.5,outside_corner_miter_percent=0.7,inside_corner_miter_percent=0.8,handles=[HANDLE_RIGHT],end_treat=MITER_HORIZ_RIGHT+corner_end_y);    
    }
 }
 
 corner_rail(corner_size=[75,75],clips=[0.5,0.5],end_connect=CORNER_MALE);