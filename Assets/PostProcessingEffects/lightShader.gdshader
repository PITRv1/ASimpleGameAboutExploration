shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_disabled, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float shadow_intensity: hint_range(0.0, 1.0) = 0.5;
uniform float luminance_threshold: hint_range(0.0, 1.0) = 0.3;

void vertex() {
    POSITION = vec4(VERTEX.xy * 2.0 - 1.0, 0.0, 1.0); // Fullscreen quad
}

void fragment() {
    // Get screen color and calculate luminance
    vec3 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    float luminance = dot(screen_color, vec3(0.2126, 0.7152, 0.0722));
    
    // Store values in alpha channel (8-bit precision)
    ALPHA = luminance * 0.5; // Store luminance in upper 4 bits
}

void light() {
    // Retrieve stored luminance from alpha channel
    float luminance = ALPHA * 2.0;
    
    // Calculate geometric shadow strength
    float shadow_strength = 1.0 - smoothstep(0.0, 1.0, ATTENUATION);
    
    // Combine geometric shadows and dark areas
    float final_shadow = clamp(
        shadow_strength * shadow_intensity + 
        (1.0 - smoothstep(luminance_threshold - 0.1, luminance_threshold + 0.1, luminance)),
        0.0, 1.0
    );
    
    // Output final shadow mask
    if (final_shadow > 0.5) {
        DIFFUSE_LIGHT = vec3(0.0);
        ALPHA = 1.0; // Fully opaque
    } else {
        ALPHA = 0.0; // Fully transparent
    }
}