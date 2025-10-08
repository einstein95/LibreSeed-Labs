shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.5;
uniform float speed : hint_range(0.0, 5.0) = 2.0;
uniform float rgb_shift : hint_range(0.0, 10.0) = 2.0;
uniform float pixel_size : hint_range(0.01, 0.1) = 0.05;
uniform float pixel_alpha : hint_range(0.0, 1.0) = 0.01;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

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

	vec2 block_uv = floor(uv / pixel_size);
	float noise = random(block_uv + vec2(TIME * 0.01, TIME * 0.02));
    float black_pixel = smoothstep(0.0, 1.0, progress + noise * pixel_alpha);

    final_color = mix(final_color, vec4(0.0, 0.0, 0.0, 1.0), black_pixel);

    float flicker = smoothstep(0.5, 0.6, random(vec2(TIME * speed, uv.x))) * progress;

    COLOR = mix(final_color, vec4(0.0, 0.0, 0.0, 1.0), flicker * progress);
}
