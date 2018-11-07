shader_type canvas_item;

uniform float lines_distance = 4.0;
uniform float pixel_size = 2.0;
uniform float size_screen = 600;
uniform float scanline_alpha = 0.9;
uniform float lines_velocity = 30.0;

void fragment()
{
	float line_row = floor((SCREEN_UV.y * size_screen/pixel_size) + mod(TIME*lines_velocity, lines_distance));

	float n = 1.0 - ceil((mod(line_row,lines_distance)/lines_distance));

vec4 c = texture(SCREEN_TEXTURE,SCREEN_UV);
c = c - n*c*(1.0 - scanline_alpha);
c.a = 1.0;
COLOR = c;
}