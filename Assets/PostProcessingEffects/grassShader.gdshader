// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform float distance_fade_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_max : hint_range(0.0, 4096.0, 0.01);
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec4 backlight : source_color;
uniform sampler2D texture_backlight : hint_default_black, filter_linear_mipmap, repeat_enable;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

// Wind controls
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wind_strength : hint_range(0.0, 2.0) = 0.5;
uniform float wind_frequency : hint_range(0.0, 5.0) = 2.0;
uniform vec2 wind_direction = vec2(1.0, 0.5); // XZ plane direction

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

    // Calculate wind effect
    float wind_wave = sin(TIME * wind_speed + VERTEX.x * wind_frequency) * wind_strength;
    float sway = cos(TIME * wind_speed * 0.8 + VERTEX.z * wind_frequency * 1.2) * wind_strength * 0.5;

    // Combine wind effects
    vec3 wind_offset = vec3(
        wind_direction.x * (wind_wave + sway) * 0.3,
        (wind_wave - sway) * 0.1,
        wind_direction.y * (wind_wave - sway) * 0.3
    );

    // Apply to vertex position
    VERTEX += wind_offset;

    // Standard position transformation
    POSITION = (PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX) * vec4(VERTEX, 1.0);
	
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	// Vertex Color Use as Albedo: Enabled
	albedo_tex *= COLOR;

	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	ALPHA *= albedo.a * albedo_tex.a;

	// Distance Fade: Pixel Alpha
	ALPHA *= clamp(smoothstep(distance_fade_min, distance_fade_max, length(VERTEX)), 0.0, 1.0);

	// Backlight: Enabled
	vec3 backlight_tex = texture(texture_backlight, base_uv).rgb;
	BACKLIGHT = (backlight.rgb + backlight_tex);
}
