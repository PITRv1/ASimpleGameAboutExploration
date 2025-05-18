shader_type spatial;

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
        (wind_wave - sway) * 0.5,
        wind_direction.y * (wind_wave - sway) * 0.3
    );

    // Apply to vertex position
    VERTEX += wind_offset;

    // Standard position transformation
    POSITION = (PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX) * vec4(VERTEX, 1.0);
}