shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 3.0 * COLOR.a);
}