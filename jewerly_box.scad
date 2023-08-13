//hello！
//$fn = 60;

/*
"single_tray" = single pocket tray
"double_tray" = double pocket tray
"triple_tray" = triple pocket tray
foo = funny star, prompts user input
*/
tray = "double_tray";

/*
Use vector_slice for exporting key vectors!
0 - render for cut on tray bottom, to allow trays to stack
1 - render for cutting tray pockets, the middle vector
2 - render for cut on tray top, to allow trays to stack
3 - interesting middle slice
?# - simple display of the 3 key vectors

Use echo_cut_depths to print the required depths to cut when CNC machining to the console! :D
*/
vector_slice = 7;

show_box = false;
show_projection = false;
echo_cut_depths = true;

//Handy conversion: 1in = 25.4mm

wall_thickness = 8;
rounding_radius = 3.175;
tray_rounding = 5;
box_width = 4 * 25.4;
box_length = 5.5 * 25.4;
box_height = 1.70 * 25.4;
is_rounded = true;


inner_box_width = box_width - wall_thickness * 2;
inner_box_length = box_length - wall_thickness * 2;
inner_box_height = (box_height - wall_thickness) * 0.97;
inner_box_z_transformation = box_height - ((box_height - wall_thickness) * 0.97);


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
module star()
{
    linear_extrude(wall_thickness / 2)
    {
         scale([2.5, 2.5, 2.5])polygon(points = [[6*cos(18), 6*sin(18)], [2*cos(54), 2*sin(54)], [0, 6], [2*cos(126), 2*sin(126)], [6*cos(162), 6*sin(162)], [2*cos(198), 2*sin(198)], [6*cos(234), 6*sin(234)], [0, -2], [6*cos(306), 6*sin(306)], [2*cos(342), 2*sin(342)]]);
    }
   
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
     if(tray == "single_tray") single_tray(width, length, height, rounding_radius, wall_thickness);
           
    else if(tray == "double_tray") double_tray(width, length, height, rounding_radius, wall_thickness);
             
    else if(tray == "triple_tray") triple_tray(width, length, height, rounding_radius, wall_thickness);
                
    else {
         scale([2,2.7,1])translate([0,0,height - wall_thickness])star();
        echo("please select tray type.....");
    }
    if(is_rounded)echo("Rounded.");
    else echo("Unrounded.");
}

module build_tray(inner_box_width, inner_box_length, inner_box_height, tray_rounding)
{
    if(is_rounded)rounded_tray(inner_box_width, inner_box_length, inner_box_height, tray_rounding);
    else rounded_rectangle(inner_box_width, inner_box_length, inner_box_height, rounding_radius);
    
}

module single_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Single tray");
    translate([0,0, inner_box_z_transformation]) #build_tray(inner_box_width, inner_box_length, inner_box_height, tray_rounding);
}
translate([0,0,wall_thickness])cube(10);

module double_tray(width, length, height, rounding_radius, wall_thickness)
{
    echo("Double tray");
    double_tray_length = length / 2 - wall_thickness * 3/2;
    y_transformation = length / 4 - wall_thickness / 4 ;
    
    for(y = [-1 : 2 : 1])    
    {
        translate([0, y *  y_transformation, inner_box_z_transformation]) build_tray(inner_box_width, double_tray_length, inner_box_height, tray_rounding);
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
        translate([x * PAR_x_transformation, PAR_y_transformation, inner_box_z_transformation]) build_tray(PAR_tray_width, PAR_tray_length, inner_box_height, tray_rounding);
    }
    translate([0, SNGL_y_transformation, inner_box_z_transformation]) build_tray(SNGL_tray_width, SNGL_tray_length, inner_box_height, tray_rounding);
}

module ring_lid(width, length, height, rounding_radius, wall_thickness)
{
    lid_width = (width - wall_thickness * 2) * 0.97;
    lid_length = (length - wall_thickness * 2) * 0.97;
    lid_height = wall_thickness / 2;
    
     x_transformation = width / 2.75;
    
    rounded_rectangle(lid_width, lid_length, lid_height, rounding_radius); 
    
    for(x = [0:1])
    {
        for (y = [0:1]) translate([x_transformation * x - width / 5.5, y * x_transformation, 4])cylinder(8, 3.5, 3);
    }
   
}

module print_tray_star()
{
    scale([0.94, 0.94, 0.94])star();
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
    translate([0,0, wall_thickness]) rounded_rectangle(inner_box_width, inner_box_length, inner_box_height, rounding_radius);
}

module box(width, length, height, rounding_radius, wall_thickness)
{   
    if(tray == 0)
    {
        lid(width, length, height, rounding_radius, wall_thickness);
    }
    else if (tray == 4)
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

module pocket_vector() {
    projection(cut = true) translate([0,0,-box_height * 2/3]) render_box();
}

//THIS IS WEIRDDDD
module inner_pocket_vector() {
    projection(cut = true) translate([0,0, - wall_thickness - 0.1]) render_box();
}
module top_vector() {
    projection(cut = true) translate([0,0,-(box_height - wall_thickness / 4)]) render_box();
}

module middle_slice() {
    projection(cut = true)rotate([0,90,0])
    translate([-wall_thickness,0,0])render_box();
}

module display_key_vectors()
{
    bottom_vector();
    translate([0,0,box_height * 2/3]) pocket_vector();
    translate([0,0,box_height - wall_thickness / 4])top_vector();
}

module render_box() {
    cut_box(box_width, box_length, box_height, rounding_radius, wall_thickness);
}

module render_projection() {
    if(vector_slice == 0)bottom_vector();
    else if(vector_slice == 1)pocket_vector();
    else if(vector_slice == 2)top_vector();
    else if(vector_slice == 3)middle_slice();
    else display_key_vectors();
}

module print_depths_to_console()
{
    top_cut_depth =  wall_thickness / 2;
    pocket_cut_depth = (box_height - wall_thickness) * 0.97;
    bottom_cut_depth = (wall_thickness / 2) * 0.97;
    pocket_crude_cut_depth = (box_height - wall_thickness) * 0.97 - tray_rounding;
    
    echo();
    if(is_rounded)echo("Having a rounded tray is slightly more complicated, because it requires both an end mill and a ball mill");
    echo("Top slice depth: ", top_cut_depth, "mm");
    if(is_rounded){
        echo("You will want an end mill to cut the pocket(s) to less than or equal to", pocket_crude_cut_depth, "mm");
        echo("You will then want a ball mill to round the pocket(s) down to ", pocket_cut_depth, "mm");
        echo("And finish with the end mill");
    }
    else {
         echo("Pocket(s) depth ", pocket_cut_depth, "mm");
    }
    echo("Bottom slice depth ", bottom_cut_depth, "mm");
}

if (show_box)render_box();
if (show_projection)render_projection();
if (echo_cut_depths)print_depths_to_console();
    
module shit()
{
    //translate([0,0,10])pocket_vector();
    //translate([0,0,10])inner_pocket_vector();
    render_box();
}

difference(){
    shit();
    translate([10,0,0])foo_cube();
}