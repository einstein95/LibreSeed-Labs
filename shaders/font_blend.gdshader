shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a < 0.1) discard;
    vec4 bg_color = texture(screen_texture, SCREEN_UV);
    float brightness = dot(bg_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 font_color = brightness > 0.5 ? vec3(0.0) : vec3(1.0);
    COLOR = vec4(font_color, tex_color.a);
}
