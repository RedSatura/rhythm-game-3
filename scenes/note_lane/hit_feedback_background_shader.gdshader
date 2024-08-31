shader_type canvas_item;

uniform vec3 background_color = vec3(1.0, 1.0, 1.0);
uniform float background_transparency = 0.0;

void fragment() {
	COLOR = vec4(background_color, UV.y);
	COLOR.a *= background_transparency;
}
