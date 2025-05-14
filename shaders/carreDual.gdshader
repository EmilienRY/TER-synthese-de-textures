shader_type spatial;

uniform sampler2D tex : source_color;
uniform float PATCH_SCALE = 4.0;

vec2 rnd22(vec2 p) {
    return fract(sin((p) * mat2(vec2(127.1, 311.7), vec2(269.5, 183.3))) * 43758.5453);
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
	vec2 offset1 = rnd22(seed1);

    vec4 tex1 = texture(tex, (U - offset1) / PATCH_SCALE);
    float w1 = square_blend(f1);



    // Grille 2 (dual, décalée de 0.5)
    vec2 I2 = floor(U + 0.5);
    vec2 f2 = fract(U + 0.5);
	vec2 seed2 = fract(I2 / PATCH_SCALE);
	vec2 offset2 = rnd22(seed2);

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



/*

// Importance sampler basé sur l’ACF (pdf)



// Fonction de blend carré avec adoucissement
float square_blend(vec2 local_uv) {
    vec2 dist = abs(local_uv - 0.5);
    float weight = 1.0 - clamp(max(dist.x, dist.y) * 2.0, 0.0, 1.0);
    return pow(weight, blend_sharpness);
}

void fragment() {
    vec2 U = UV * PATCH_SCALE;

    // --- Grille 1 : primal
    vec2 I1 = floor(U);
    vec2 f1 = fract(U);
    vec2 seed1 = fract(I1 / PATCH_SCALE); // coordonnée UV dans ACF
    vec2 offset1 = importance_sample(seed1);
    vec4 tex1 = texture(tex, (U - offset1) / PATCH_SCALE);
    float w1 = square_blend(f1);

    // --- Grille 2 : dual
    vec2 I2 = floor(U + 0.5);
    vec2 f2 = fract(U + 0.5);
    vec2 seed2 = fract(I2 / PATCH_SCALE); // coordonnée UV dans ACF
    vec2 offset2 = importance_sample(seed2);
    vec4 tex2 = texture(tex, (U - offset2) / PATCH_SCALE);
    float w2 = square_blend(f2);

    // --- Mélange final (avec normalisation)
    float norm = w1 + w2 + 0.0001;
    vec4 final_color = (tex1 * w1 + tex2 * w2) / norm;

    ALBEDO = final_color.rgb;
}


*/

