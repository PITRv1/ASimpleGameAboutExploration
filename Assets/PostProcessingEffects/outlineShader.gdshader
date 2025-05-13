shader_type spatial;
render_mode unshaded;

// Textures
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Edge Detection
uniform float edge_threshold = 0.5;
uniform vec3 line_color: source_color = vec3(0.043, 0.282, 0.467);
uniform vec3 background_color: source_color = vec3(0.408, 0.969, 0.694);

// Shadows
uniform vec3 shadow_color: source_color = vec3(0.2, 0.2, 0.5);
uniform float shadow_threshold: hint_range(0.0, 1.0) = 0.4;
uniform vec3 light_direction = vec3(0.5, -1.0, 0.5);

// Sky
uniform vec4 sky_color : source_color = vec4(0.529, 0.808, 0.922, 1.0);

// Sobel Operators
const mat3 sobel_y = mat3(
    vec3(1.0, 0.0, -1.0),
    vec3(2.0, 0.0, -2.0),
    vec3(1.0, 0.0, -1.0)
);

const mat3 sobel_x = mat3(
    vec3(1.0, 2.0, 1.0),
    vec3(0.0, 0.0, 0.0),
    vec3(-1.0, -2.0, -1.0)
);

vec3 normalize_normal(vec3 normal) {
    return normalize(normal * 2.0 - 1.0);
}

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 offset = 0.5 / VIEWPORT_SIZE;
    
    // Depth and sky detection
    float depth_sample = texture(DEPTH_TEXTURE, uv).r;
    bool is_sky = depth_sample <= 0.0; // Direct depth buffer value check
    
    // Initialize with sky or original color
    vec3 final_color;
	if (is_sky) {
	    final_color = sky_color.rgb;
		ALPHA = 0.0;
		
	} else {
	    final_color = texture(SCREEN_TEXTURE, uv).rgb;
	}
	
    if(!is_sky) {
        // Lighting calculation
        vec3 view_normal = normalize_normal(texture(NORMAL_TEXTURE, uv).rgb);
        vec3 view_light_dir = normalize((VIEW_MATRIX * vec4(normalize(light_direction), 0.0)).xyz);
        float NdotL = clamp(dot(view_normal, view_light_dir), 0.0, 1.0);
        float shadow = smoothstep(shadow_threshold, shadow_threshold + 0.1, 1.0 - NdotL);

        // Edge detection
        vec3 n = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, -offset.y)).rgb);
        vec3 s = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(0.0, offset.y)).rgb);
        vec3 e = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(offset.x, 0.0)).rgb);
        vec3 w = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-offset.x, 0.0)).rgb);
        vec3 nw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-offset.x, -offset.y)).rgb);
        vec3 ne = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(offset.x, -offset.y)).rgb);
        vec3 sw = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(-offset.x, offset.y)).rgb);
        vec3 se = normalize_normal(texture(NORMAL_TEXTURE, uv + vec2(offset.x, offset.y)).rgb);

        mat3 surrounding_pixels = mat3(
            vec3(length(nw-view_normal), length(n-view_normal), length(ne-view_normal)),
            vec3(length(w-view_normal), 0.0, length(e-view_normal)),
            vec3(length(sw-view_normal), length(s-view_normal), length(se-view_normal))
        );

        float edge_x = dot(sobel_x[0], surrounding_pixels[0]) + dot(sobel_x[1], surrounding_pixels[1]) + dot(sobel_x[2], surrounding_pixels[2]);
        float edge_y = dot(sobel_y[0], surrounding_pixels[0]) + dot(sobel_y[1], surrounding_pixels[1]) + dot(sobel_y[2], surrounding_pixels[2]);
        float edge = sqrt(pow(edge_x, 2.0) + pow(edge_y, 2.0));

        // Color blending
        vec3 shaded_color = mix(background_color, shadow_color, shadow);
        final_color = edge > edge_threshold ? line_color : shaded_color;
    }
	
    float luminance = dot(final_color, vec3(0.2126, 0.7152, 0.0722));
	
    ALBEDO = final_color;
}