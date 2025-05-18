shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 color : source_color = vec4(0,0,0,1);
uniform float size : hint_range(1.0, 1.5, 0.01) = 1.12;

void vertex() {
	VERTEX *= size;
	VERTEX.y += sin(VERTEX.x * 5.0 + TIME) * .5 ;
	VERTEX.x += sin(VERTEX.y * 5.0 + TIME + 40.0) * .2;

}

void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
