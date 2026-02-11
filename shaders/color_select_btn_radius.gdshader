shader_type canvas_item;

uniform int radius : hint_range(0, 32) = 10;
uniform int stroke_thickness: hint_range(0, 10) = 128;

void fragment() {
    // Get texture size
    vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE;
    
    // Convert UV to discrete pixel coordinates (0 to 63 for 64x64)
    ivec2 pixel_coord = ivec2(floor(UV * tex_size));
    ivec2 tex_size_int = ivec2(tex_size);
    
    // Calculate Euclidean distance squared to each corner
    // Top-left: distance from (0,0)
    int dist_tl_x = pixel_coord.x;
    int dist_tl_y = pixel_coord.y;
	int pix_dif_tl = dist_tl_x - dist_tl_y;
    int dist_tl_sq = dist_tl_x * dist_tl_x + dist_tl_y * dist_tl_y - (pix_dif_tl * pix_dif_tl -32);
    
    // Top-right: distance from (width-1, 0)
    int dist_tr_x = tex_size_int.x - 1 - pixel_coord.x;
    int dist_tr_y = pixel_coord.y;
	int pix_dif_tr = dist_tr_x - dist_tr_y;
    int dist_tr_sq = dist_tr_x * dist_tr_x + dist_tr_y * dist_tr_y - (pix_dif_tr * pix_dif_tr -32);
    
    // Bottom-left: distance from (0, height-1)
    int dist_bl_x = pixel_coord.x;
    int dist_bl_y = tex_size_int.y - 1 - pixel_coord.y;
	int pix_dif_bl = dist_bl_x - dist_bl_y;
    int dist_bl_sq = (dist_bl_x * dist_bl_x + dist_bl_y * dist_bl_y) - (pix_dif_bl * pix_dif_bl -32);
    
    // Bottom-right: distance from (width-1, height-1)
    int dist_br_x = tex_size_int.x - 1 - pixel_coord.x;
    int dist_br_y = tex_size_int.y - 1 - pixel_coord.y;
	int pix_dif_br = dist_br_x - dist_br_y;
    int dist_br_sq = dist_br_x * dist_br_x + dist_br_y * dist_br_y - (pix_dif_br * pix_dif_br -32);
    
    // Get minimum squared distance to any corner
    int min_dist_sq = min(min(dist_tl_sq, dist_tr_sq), min(dist_bl_sq, dist_br_sq));
	//int pix_diff = abs(abs(pixel_coord.x) - abs(pixel_coord.y));
	//int diff_axis = 8 + pix_diff * pix_diff;
	//min_dist_sq -= diff_axis;
    
    // Sample the texture
    vec4 color = texture(TEXTURE, UV);
    
    // Discard pixels that are within the corner radius (using squared distance to avoid sqrt)
    if (min_dist_sq + 48 < radius * radius) {
		discard;
    } else if (min_dist_sq - stroke_thickness < radius * radius){
		COLOR = texture(TEXTURE, UV) - vec4(0.15,0.15,0.15,0);
	}else {
        
		COLOR = color;
    }
}