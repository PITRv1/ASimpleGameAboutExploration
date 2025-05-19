shader_type spatial;
render_mode  unshaded, cull_back;

uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 primary_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 secondary_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);

uniform sampler2D noise_texture;
uniform sampler2D primaryColorChange;

uniform float speed : hint_range(0.0, 1.0) = 0.5;
uniform float cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float primary_cutoff : hint_range(0.0, 1.0) = 0.5;
uniform float yRippleOffset : hint_range(0.0, 10.0) = 0.5;



void vertex() {
	//VERTEX *= size;
	VERTEX.y += sin(VERTEX.x * yRippleOffset + TIME) * .5 ;
	VERTEX.x += sin(VERTEX.y * 5.0 + TIME + 40.0) * .2;

}

void fragment() {
	vec2 flow = vec2(TIME * speed, TIME * speed);
	vec2 noise_uv = UV + flow;
	
	float noise_val = texture(noise_texture, noise_uv).r; // assuming grayscale
	
	vec4 final_color = primary_color;
	
	float primaryNoise_val = texture(primaryColorChange, noise_uv).r;
	
	if (primaryNoise_val < primary_cutoff){
		final_color = secondary_color;
	}
	
	vec4 color = noise_val > cutoff ? final_color : background_color;

	ALBEDO = color.rgb;
	ALPHA = color.a;
}
