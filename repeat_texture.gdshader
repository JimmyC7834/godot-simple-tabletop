shader_type canvas_item;
uniform sampler2D noise;
void fragment() {
	vec2 uv = vec2(UV.x, UV.y);
	COLOR.rgba = texture(TEXTURE, uv).rgba;
}

//shader_type spatial;
//
//uniform sampler2D TEXTURE;
//
//void fragment() {
	//vec2 uv = vec2(UV.x, UV.y) + (MODEL_MATRIX * vec4(VERTEX, 1.0)).xy;
	//COLOR.rgba = texture(TEXTURE, uv).rgba;
//}