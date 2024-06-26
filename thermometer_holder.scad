// Description:
//
// A 3D model for a holder for aquarium glass thermometer.
// It can thus be inserted into the aquarium gravel.

/* [settings] */
//
type="ground"; // ["ground", "hook"]
//
wall = 1.5;
//
printable_position = false;
//
show_thermometer = true;

/* [thermometer holder] */
//
scape_height    = 40;
scape_diameter  =  6.5;
//
slot_height     = 20;
slot_width      =  4;

/* [ground part] */
//
shaft_height    = 20;
//
ground_height   = 35;
ground_diameter =  8;

/* [hook part] */
//
hook_height = 100;
hook_width  =  10;
hook_gap    =   0.5;

/* [Hidden] */

include <banded.scad>
required_version ([3,0,0]);

if (type=="ground") union()
{
	m = ! printable_position
		? identity_matrix (4)
		: matrix_rotate_y (180) *
		  matrix_translate_z (-shaft_height - scape_height-wall)
	;
	
	multmatrix (m)
	{
		holder_ground();
		//
		translate_z(shaft_height)
		holder_thermometer();
		
		if (show_thermometer && $preview && !printable_position)
			translate_z(shaft_height + wall)
			thermometer();
	}
}
else if (type=="hook") union()
{
	translate_z(scape_height+wall)
	holder_hook();
	//
	holder_thermometer();
	
	if (show_thermometer && $preview && !printable_position)
		translate_z(wall)
		thermometer();
}

$fa=10; $fs=0.3;
//$fn=24;


// TODO - not useable yet -
module holder_hook ()
{
	hook_angle = 120; // in Grad
	//
	rotate_z(90-hook_angle/2)
	translate_z(-epsilon -wall/2)
	funnel(h=epsilon + hook_gap*tan(60),
		di1=scape_diameter,
		di2=scape_diameter+hook_gap,
		w=wall, angle=120
	);
	rotate_z(90-hook_angle/2)
	translate_z(-wall/2 + hook_gap*tan(60))
	ring_square(h=hook_height - (-wall/2 + hook_gap*tan(60)),
		di=scape_diameter+hook_gap, w=wall, angle=hook_angle
	);
	steg_width = scape_diameter+hook_gap;
	translate([-steg_width/2, 0, hook_height])
	cube([steg_width, wall*2+hook_width, wall])
	;
}

module holder_ground ()
{
	cylinder(d=ground_diameter, h=shaft_height);
	//
	translate([0,0,-ground_height+epsilon])
	intersection()
	{
			union()
			{
				linear_extrude(height=ground_height*2/3+epsilon, scale=2, convexity=2)
					cross_object(ground_diameter/2, wall);
				//
			translate([0,0,ground_height*2/3])
			cross_object(ground_diameter, wall*2, ground_height*1/3);
		}
		//
		cylinder(d=ground_diameter, h=ground_height);
	}
}

module holder_thermometer ()
{
	difference()
	{
		cylinder_edges_rounded(d=scape_diameter+2*wall, h=scape_height+wall,
			edges=[max(0,(scape_diameter+2*wall-ground_diameter)/2), wall/2]);
		union()
		{
			translate_z(wall)
			cylinder_edges_rounded (d=scape_diameter, h=scape_height+extra,
				edges=[scape_diameter/3, 0]);
			//
			for (a=[0:360/3:359])
			{
				rotate_z(a)
				translate_z(wall)
				rotate_x(90)
				union()
				{
					height=scape_diameter/2+wall+extra;
					//
					translate_y(slot_width/2)
					cylinder (d=slot_width, h=height);
					translate_y(slot_width/2)  translate_x(-slot_width/2)
					cube      ([slot_width,    (slot_height-slot_width),height]);
					translate_y(slot_width/2 + (slot_height-slot_width))
					cylinder (d=slot_width, h=height);
				}
			}
		}
	}
}

module thermometer()
{
	h_full = 145;
	//
	d_chamber = scape_diameter-1;
	h_chamber = 16;
	d_shaft   = scape_diameter - 0.1;
	
	color ("red", alpha=0.3)
	cylinder_edges_rounded (h=h_chamber, d=d_chamber, edges=[d_chamber/3,0]);
	
	color ("orange", alpha=0.3)
	union()
	{
		translate_z (h_chamber)
		cylinder (h=2, d1=d_chamber, d2=d_shaft);
		
		translate_z (h_chamber+2)
		cylinder_edges_rounded (h=h_full - (h_chamber+2), d=d_shaft, edges=[0,d_shaft/3]);
	}
}

module cross_object (diameter, width, height=0)
{
	if (height==0)
	{
		union()
		{
			square([diameter, width], center=true);
			square([width, diameter], center=true);
		}
		
	}
	else
	{
		translate([0,0,+height/2])
		union()
		{
			cube([diameter, width, height], center=true);
			cube([width, diameter, height], center=true);
		}
	}
}
