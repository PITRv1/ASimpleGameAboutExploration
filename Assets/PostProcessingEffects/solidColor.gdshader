shader_type spatial;
render_mode unshaded;

uniform vec4 albedo_color : source_color;

void vertex() {
    //POSITION = vec4(VERTEX.xy, 0.5, 1.0); // Same vertex positioning
}

void fragment() {
    ALBEDO = albedo_color.rgb;
    ALPHA = albedo_color.a;
}