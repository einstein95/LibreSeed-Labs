shader_type canvas_item;

uniform vec2 grid_size = vec2(199.0, 199.0); // 199x199 grid
uniform vec2 atom_size = vec2(60.0, 60.0);   // Size of each atom
uniform vec2 spacing = vec2(120.0, 120.0);   // Distance between atoms

void fragment() {
    // Convert screen position to grid coordinates
    vec2 world_pos = UV * grid_size * spacing;
    vec2 grid_pos = mod(world_pos, spacing);
    
    // Check if we're within an atom's bounds
    vec2 atom_center = spacing * 0.5;
    vec2 atom_offset = grid_pos - atom_center + atom_size * 0.5;
    
    if (atom_offset.x >= 0.0 && atom_offset.x < atom_size.x && 
        atom_offset.y >= 0.0 && atom_offset.y < atom_size.y) {
        
        // Sample the node's texture and apply modulation
        vec2 atom_uv = atom_offset / atom_size;
        COLOR = texture(TEXTURE, atom_uv) * COLOR;
    } else {
        // Transparent background
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}