shader_type canvas_item;
render_mode unshaded;

uniform sampler2D TextureMap : repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.01);
uniform float distortion_strength : hint_range(-1,1) = 0.2;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform int NumDivisions = 32;

void fragment()
{
    // quantize the UV value to a stepped value
    // based on number of divisions.
    // the 0.5 added ensures we sample from 
    // the centre of the "pixel"
    vec2 st = (vec2(ivec2( UV * float(NumDivisions) ))+0.5)/float(NumDivisions);
	vec4 noise_col = texture(TextureMap, st + scroll * sin(TIME)/2.0);
	//vec4 screen_col = texture(screen_texture, SCREEN_UV + distortion_strength * noise_col.rr);
    // set the output
    COLOR = noise_col;  
}