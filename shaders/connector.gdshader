shader_type canvas_item;

uniform float progress = 1.0;

void fragment() {
	if (UV.x < progress){
		discard;
	}
}