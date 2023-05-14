//hello！

/*
Use tray to specify the type of tray. 
0 - lid
1 - single tray
2 - double tray
3 - triple tray
?# - default unrounded tray prototype
*/

//Handy conversion: 1in = 25.4mm

//$fn = 60;

// TO DO: FIX DOUBLE TRAY TRANSLATION

show_box = true;
show_projection = true;
tray = 1;

wall_thickness = 8;
rounding_radius = 3.175;
tray_rounding = 5;

box_width = 4 * 25.4;
box_length = 5.5 * 25.4;
box_height = 1 * 25.4;


module build_four(x, y, z) {
    translate([0, 0, z]) {
        translate([x, y, 0]) {
            children();
        }
        translate([-x, y, 0]) {
            children();
        }
        translate([x, -y, 0]) {
            children();
        }
        translate([-x, -y, 0]) {
            children();
        }      
    }
}

module foo_cube()
{
    translate([0,-20,-55])cube([110,110,110]);
}

module rounded_rectangle(width, length, height, rounding_radius)
{
    x = width /2 - rounding_radius;
    y = length /2 - rounding_radius;
    
    hull(){
        translate([x, y, 0])cylinder(r = rounding_radius, h = height);
        translate([-x, y, 0])cylinder(r = rounding_radius, h = height);
        translate([-x, -y, 0])cylinder(r = rounding_radius, h = height);
        translate([x, -y, 0])cylinder(r = rounding_radius, h = height);
    }
}

module rounded_tray(width, length, height, tray_rounding)
{   
    x = width /2 - tray_rounding;
    y = length /2 - tray_rounding;
    
    hull(){
        build_four(x, y, tray_rounding)
        {
            sphere(r = tray_rounding);
            translate([0, 0, height - tray_rounding]) cylinder(r = tray_rounding, h = 1);
        }
        
        build_four(x, y, height)
        {
            cylinder(r = tray_rounding, h = 1);
        }
    }
}

module tray_type(width, length, height, rounding_radius, wall_thickness)
{
     if(tray == 1) single_tray(width, length, height, rounding_radius, wall_thickness);
                
    else if(tray == 2) double_tray(width, length, height, rounding_radius, wall_thickness);
                
    else if(tray == 3) triple_tray(width, length, height, rounding_radius, wall_thickness);
                
    else basic_unrounded_tray(width, length, height, rounding_radius, wall_thickness);
}

module single_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Single tray");
    translate([0,0, wall_thickness]) rounded_tray((width - wall_thickness * 2), (length - wall_thickness*2), (height - wall_thickness)*0.97, tray_rounding);
}

module double_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Double tray");
    
    translate([0, width / 4 + wall_thickness, wall_thickness]) rounded_tray((width - wall_thickness * 2), (length / 2 - wall_thickness*3/2), (height - wall_thickness)*0.97, tray_rounding);
            
    translate([0, - (width / 4 + wall_thickness), wall_thickness]) rounded_tray((width - wall_thickness * 2), (length / 2 - wall_thickness*3/2), (height - wall_thickness)*0.97, tray_rounding);
}

module triple_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Triple tray");
    translate([length / 4 - wall_thickness * 3/2, width / 6 + wall_thickness / 2, wall_thickness]) rounded_tray((width / 2 - wall_thickness * 3/2), (length * 2/3 - wall_thickness*3/2), (height - wall_thickness)*0.97, tray_rounding);
            
    translate([-(length / 4 - wall_thickness * 3/2), width / 6 + wall_thickness / 2, wall_thickness]) rounded_tray((width / 2 - wall_thickness * 3/2), (length * 2/3 - wall_thickness*3/2), (height - wall_thickness)*0.97, tray_rounding);
                   
    translate([0, - (width / 3 + 4/3 * wall_thickness), wall_thickness]) rounded_tray((width - wall_thickness * 2), (length * 1/3 - wall_thickness * 3/2), (height - wall_thickness)*0.97, tray_rounding);
}

module lid(width, length, height, rounding_radius, wall_thickness)
{
    echo("lid");
        difference()
    {
        rounded_rectangle(width, length, wall_thickness*1.5, rounding_radius); 
    }
}

module basic_unrounded_tray(width, length, height, rounding_radius, wall_thickness)
{
    translate([0,0, wall_thickness]) rounded_rectangle((width -     wall_thickness * 2), (length - wall_thickness*2), (height - wall_thickness)*0.97, rounding_radius);
}

module box(width, length, height, rounding_radius, wall_thickness)
{   
    if(tray != 0)
    {
        difference()
        {
            rounded_rectangle(width, length, height, rounding_radius); 
            tray_type(width, length, height, rounding_radius, wall_thickness);
        } 
    }
    else {
        lid(width, length, height, rounding_radius, wall_thickness);
    }
}

module top_cut(width, length, height, rounding_radius, wall_thickness)
{
    translate([0,0, height - wall_thickness * 1/2])rounded_rectangle(width - wall_thickness, length - wall_thickness, wall_thickness/2, rounding_radius);
}

module bottom_cut(width, length, height, rounding_radius, wall_thickness)
{
    difference()
    {
       translate([0, 0, wall_thickness * 0.97 /4])cube([width*1.01, length*1.01, wall_thickness * 0.97 / 2], center = true);
        rounded_rectangle((width - wall_thickness) * 0.98, (length - wall_thickness) * 0.98, wall_thickness/2, rounding_radius);
    }
   
}

module cut_box(width, length, height, rounding_radius, wall_thickness)
{   
    difference(){
        box(width, length, height, rounding_radius, wall_thickness);
        if(tray != 0) top_cut(width, length, height, rounding_radius, wall_thickness);
        bottom_cut(width, length, height, rounding_radius, wall_thickness);
    }
}

module bottom_vector() {
    projection(cut = true) render_box();
}

module middle_vector() {
    projection(cut = true) translate([0,0,-box_height * 2/3]) render_box();
}


module top_vector() {
    projection(cut = true) translate([0,0,-(box_height - wall_thickness / 4)]) render_box();
}

module display_key_vectors()
{
    bottom_vector();
    translate([0,0,box_height * 2/3]) middle_vector();
    translate([0,0,box_height - wall_thickness / 4])top_vector();
}

module render_box() {
    cut_box(box_width, box_length, box_height, rounding_radius, wall_thickness);
}

module render_projection() {
    projection(cut = true) render_box();
}
    
if (show_box) render_box();
//if (show_projection) render_projection();
//display_key_vectors();