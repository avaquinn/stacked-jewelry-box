//hello！

/*
Use tray to specify the type of tray. 
0 - lid
1 - single tray
2 - double tray
3 - triple tray
4 - ring tray
5 - ring tray lid
?# - default unrounded tray prototype
*/

//Handy conversion: 1in = 25.4mm

//$fn = 60;

show_box = true;
show_projection = true;
tray = 3;
box_height = 1.70 * 25.4;


//NOTE TO SELF! CHANGE NOTHING BELOW THIS LINE!!!!!
wall_thickness = 8;
rounding_radius = 3.175;
tray_rounding = 5;
box_width = 4 * 25.4;
box_length = 5.5 * 25.4;
//box_height = 1 * 25.4;
//NOTE TO SELF! CHANGE NOTHING ABOVE THIS LINE!!!!!!


inner_box_width = box_width - wall_thickness * 2;
inner_box_length = box_length - wall_thickness * 2;
inner_box_height = (box_height - wall_thickness) * 0.97;



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
    translate([0,0, wall_thickness]) rounded_tray(inner_box_width, inner_box_length, inner_box_height, tray_rounding);
}

module double_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Double tray");
    double_tray_length = length / 2 - wall_thickness * 3/2;
    y_transformation = length / 4 - wall_thickness / 4 ;
    
    for(y = [-1 : 2 : 1])    
    {
        translate([0, y *  y_transformation, wall_thickness]) rounded_tray(inner_box_width, double_tray_length, inner_box_height, tray_rounding);
    }
}

module triple_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Triple tray");
    
    PAR_tray_width = width / 2 - wall_thickness * 3/2;
    PAR_tray_length = length * 2/3 - wall_thickness*3/2;
    PAR_x_transformation = (length / 4 - wall_thickness * 3/2);
    PAR_y_transformation = width / 6 + wall_thickness / 2;
    
    SNGL_tray_width = width - wall_thickness * 2;
    SNGL_tray_length = length * 1/3 - wall_thickness * 3/2;
    SNGL_y_transformation = - (width / 3 + 4/3 * wall_thickness);
    
    for(x = [-1 : 2 : 1])  
    {
        translate([x * PAR_x_transformation, PAR_y_transformation, wall_thickness]) rounded_tray(PAR_tray_width, PAR_tray_length, inner_box_height, tray_rounding);
    }
    translate([0, SNGL_y_transformation, wall_thickness]) rounded_tray(SNGL_tray_width, SNGL_tray_length, inner_box_height, tray_rounding);
}

module ring_box(width, length, height, rounding_radius, wall_thickness)
{
    box_width = width - wall_thickness * 2;
    tray_length = length - wall_thickness * 2;
    box_height = (height - wall_thickness) * 0.97;
    y_transformation = (box_width - tray_length) / 2;
    
    translate([0, y_transformation, wall_thickness]) rounded_tray(box_width, box_width, box_height, rounding_radius);
}

module ring_tray(width, length, height, rounding_radius, wall_thickness)
{
    tray_width = width - wall_thickness * 2;
    tray_length = length - wall_thickness * 2;
    tray_height = (height - wall_thickness) * 0.97;
    
    y_transformation = (tray_width - tray_length) / 2;
    
    difference()
    {
        rounded_rectangle(width, length, height, rounding_radius); 
        
        ring_box(width, length, height, rounding_radius, wall_thickness);
        
        translate([0,0, wall_thickness + height  * 1/3]) rounded_rectangle((width - wall_thickness * 2), (length - wall_thickness*2), (height * 2/3 - wall_thickness), tray_rounding);
        
    }
}
module ring_lid(width, length, height, rounding_radius, wall_thickness)
{
    lid_width = (width - wall_thickness * 2) * 0.99;
    lid_length = (length - wall_thickness * 2) * 0.99;
    lid_height = wall_thickness / 2;
    
     x_transformation = width / 2.75;
    
    rounded_rectangle(lid_width, lid_length, lid_height, rounding_radius); 
    
    for(x = [0:1])
    {
        for (y = [0:1]) translate([x_transformation * x - width / 5.5, y * x_transformation, 4])cylinder(8, 3.5, 3);
    }
   
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
    if(tray == 0)
    {
        lid(width, length, height, rounding_radius, wall_thickness);
    }
    else if (tray == 4)
    {
        ring_tray(width, length, height, rounding_radius, wall_thickness);
    }
    else if (tray == 5)
    {
        ring_lid(width, length, height, rounding_radius, wall_thickness);
    }
    else
    {
        difference()
        {
            rounded_rectangle(width, length, height, rounding_radius); 
            tray_type(width, length, height, rounding_radius, wall_thickness);
        } 
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
//foo_cube();
//translate([0,0,24])ring_lid(box_width, box_length, box_height, rounding_radius, wall_thickness);

//if (show_projection) render_projection();
//display_key_vectors();
//translate([10,-23.5,25])cube(wall_thickness, center = true);