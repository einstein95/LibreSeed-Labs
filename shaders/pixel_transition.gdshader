shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 glow_color : source_color = vec3(0.0, 0.7, 1.0);
uniform float line_width : hint_range(0.002, 0.02) = 0.008;
uniform int direction : hint_range(0, 3) = 0; // 0=right, 1=left, 2=up, 3=down

void fragment() {
    vec2 uv = UV;
    vec4 original = texture(TEXTURE, uv);
    
    float pos;
    if (direction == 0) pos = uv.x;        // Right
    else if (direction == 1) pos = 1.0 - uv.x; // Left  
    else if (direction == 2) pos = uv.y;        // Up
    else pos = 1.0 - uv.y;                      // Down
    
    // Sharp transition line
    float transition = step(progress, pos);
    
    // Glowing edge
    float edge_dist = abs(pos - progress);
    float glow = exp(-edge_dist / line_width) * step(edge_dist, line_width * 3.0);
    
    // Final output
    vec3 final_color = original.rgb * transition + glow_color * glow;
    float final_alpha = original.a * transition + glow * 0.8;
    
    COLOR = vec4(final_color, final_alpha);
}