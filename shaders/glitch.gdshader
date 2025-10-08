shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0; // 0 = normal, 1 = fully glitched out
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.5; // How intense the glitch is
uniform float speed : hint_range(0.0, 5.0) = 2.0; // Flicker speed
uniform float rgb_shift : hint_range(0.0, 10.0) = 2.0; // How much RGB channels shift
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    float glitch = step(1.0 - glitch_intensity, random(vec2(uv.y * progress, TIME * speed)));

    float offset = glitch * random(vec2(TIME * speed, uv.y)) * 0.05 * progress;

    vec4 color_r = texture(screen_texture, uv + vec2(offset * rgb_shift, 0.0));
    vec4 color_g = texture(screen_texture, uv);
    vec4 color_b = texture(screen_texture, uv - vec2(offset * rgb_shift, 0.0));

    vec4 final_color = vec4(color_r.r, color_g.g, color_b.b, 1.0);

    float flicker = smoothstep(0.5, 0.6, random(vec2(TIME * speed, uv.x))) * progress;

    COLOR = mix(final_color, vec4(0.0, 0.0, 0.0, 1.0), flicker * progress);
}
