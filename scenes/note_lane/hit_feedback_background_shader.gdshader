shader_type canvas_item;

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	
	//if you forget what this means just take a look at this
	//https://computergraphics.stackexchange.com/questions/4537/what-does-st-mean-in-the-context-of-opengl
	//basically something something texture coordinates
	
	//Normalize coordinate of the fragment (turning it into 0 to 1) by dividing it by the resolution
	vec2 norm_coords = FRAGCOORD.xy / resolution.xy;
}
