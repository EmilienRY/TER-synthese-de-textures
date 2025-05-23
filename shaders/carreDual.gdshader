shader_type spatial;

uniform sampler2D tex : source_color;
uniform float PATCH_SCALE = 4.0;


vec2 rnd22(vec2 p) {
    return fract(sin(p * mat2(vec2(127.1, 311.7), vec2(269.5, 183.3))) * 43758.5453) - 0.5;
}


float square_blend(vec2 local_uv) {
    vec2 dist = abs(local_uv - 0.5);
    return (1.0 - clamp(max(dist.x, dist.y) * 2.0, 0.0, 1.0))+0.001;

}


void fragment() {

    vec2 U = UV * PATCH_SCALE;
    vec4 m = texture(tex, U,99.);

    // Grille 1 (primal)
    vec2 I1 = floor(U)*2.;
    vec2 f1 = fract(U);

	vec2 seed1 = I1;
	vec2 offset1 = rnd22(seed1);

    vec4 tex1 = texture(tex, (UV - offset1))-m;
    float w1 = square_blend(f1);



    // Grille 2 (dual, décalée de 0.5)
    vec2 I2 = floor(U + 0.5)*2.+vec2(1.,1.);
    vec2 f2 = fract(U + 0.5);
	vec2 seed2 = I2;
	vec2 offset2 = rnd22(seed2);

    vec4 tex2 = texture(tex, (UV - offset2) )-m;
    float w2 = square_blend(f2);

	float W= sqrt(w1*w1+w2*w2);



    vec4 final_color = (tex1 * w1 + tex2 * w2)/W +m;



	ALBEDO = final_color.rgb;

	

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
/*
*/


}