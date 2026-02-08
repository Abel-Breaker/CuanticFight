shader_type canvas_item;

uniform float split_amount : hint_range(0, 1) = 0.0;
uniform float split_position : hint_range(0, 1) = 0.5;
uniform int split_direction : hint_range(0, 1) = 0;  // 0=vertical, 1=horizontal

void fragment() {
    vec2 uv = FRAGCOORD.xy / SCREEN_UV; //textureSize(SCREEN_TEXTURE, 0);// VIEWPORT_SIZE.xy;
    
    if (split_direction == 0) {  // Vertical split
        if (uv.x < split_position) {
            // Left side - show camera 1
            COLOR = texture(TEXTURE, vec2(uv.x * 2.0, uv.y));
        } else {
            // Right side - show camera 2  
            COLOR = texture(TEXTURE, vec2((uv.x - 0.5) * 2.0, uv.y));
        }
    } else {  // Horizontal split
        if (uv.y < split_position) {
            // Top side - show camera 1
            COLOR = texture(TEXTURE, vec2(uv.x, uv.y * 2.0));
        } else {
            // Bottom side - show camera 2
            COLOR = texture(TEXTURE, vec2(uv.x, (uv.y - 0.5) * 2.0));
        }
    }
    
    // Draw split line
    if (split_direction == 0 && abs(uv.x - split_position) < 0.002) {
        COLOR.rgb = vec3(1.0, 1.0, 0.0);
    } else if (split_direction == 1 && abs(uv.y - split_position) < 0.002) {
        COLOR.rgb = vec3(1.0, 1.0, 0.0);
    }
}