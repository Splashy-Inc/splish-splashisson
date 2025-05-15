shader_type canvas_item;

uniform sampler2D TextureMap : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.01);
uniform int NumDivisions = 128;

void fragment()
{
	// MOSTLY COPIED CODE FROM THE INTERNET, STILL NEED TO LEARN SHADERS BETTER
	// quantize the UV value to a stepped value
	// based on number of divisions.
	// the 0.5 added ensures we sample from 
	// the centre of the "pixel"
	vec2 st = (vec2(ivec2( UV * float(NumDivisions) ))+0.5)/float(NumDivisions);
	vec4 noise_col = texture(TextureMap, st + scroll * sin(TIME)/2.0);
	// set the output
	COLOR = noise_col;  
}