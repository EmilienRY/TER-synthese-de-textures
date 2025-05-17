shader_type spatial;

uniform sampler2D tex : source_color;
uniform sampler2D acf_tex;
uniform float PATCH_SCALE = 4.0;


vec2 sample_acf(vec2 uv) {
	float s = texture(acf_tex, uv).r;
	s = s* 2.0 - 1.0;

	return vec2(s,s);
}

float square_blend(vec2 local_uv) {
    vec2 dist = abs(local_uv - 0.5);
    return 1.0 - clamp(max(dist.x, dist.y) * 2.0, 0.0, 1.0);
}


void fragment() {


    vec2 U = UV * PATCH_SCALE;

    // Grille 1 (primal)
    vec2 I1 = floor(U);
    vec2 f1 = fract(U);

	vec2 seed1 = fract(I1 / PATCH_SCALE);
	vec2 offset1 = sample_acf(seed1);

    vec4 tex1 = texture(tex, (U - offset1) / PATCH_SCALE);
    float w1 = square_blend(f1);



    // Grille 2 (dual, décalée de 0.5)
    vec2 I2 = floor(U + 0.5);
    vec2 f2 = fract(U + 0.5);
	vec2 seed2 = fract(I2 / PATCH_SCALE);
	vec2 offset2 = sample_acf(seed2);

    vec4 tex2 = texture(tex, (U - offset2) / PATCH_SCALE);
    float w2 = square_blend(f2);

    float norm = w1 + w2;
    vec4 final_color = (tex1 * w1 + tex2 * w2) / norm;
	ALBEDO = final_color.rgb;

/*

	//AFFICHAGE GRILLE
    float border_width = 0.05;

    float border1 = step(f1.x, border_width) + step(1.0 - f1.x, border_width)
                 + step(f1.y, border_width) + step(1.0 - f1.y, border_width);

    float border2 = step(f2.x, border_width) + step(1.0 - f2.x, border_width)
                 + step(f2.y, border_width) + step(1.0 - f2.y, border_width);

    vec3 debug_color = vec3(border1 > 0.0 ? 1.0 : 0.0,
                            border2 > 0.0 ? 1.0 : 0.0,
                            0.0);

	ALBEDO = mix(final_color.rgb, debug_color, 0.5);


*/


}
