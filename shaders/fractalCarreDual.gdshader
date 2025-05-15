shader_type spatial;
uniform sampler2D tex : source_color;
uniform float PATCH_SCALE = 4.0;
uniform float distMax;

vec2 rnd22(vec2 p) {
    return fract(sin(p * mat2(vec2(127.1, 311.7), vec2(269.5, 183.3))) * 43758.5453) - 0.5;
}

float square_blend(vec2 local_uv) {
    vec2 dist = abs(local_uv - 0.5); 
    return 1.0 - clamp(max(dist.x, dist.y) * 2.0, 0.0, 1.0);
}



vec4 carreDual(vec2 uv){
	
    // Grille 1 (primal)
    vec2 I1 = floor(uv);
    vec2 f1 = fract(uv);
    vec2 offset1 = rnd22(I1);
    vec4 tex1 = texture(tex, (uv - offset1) / PATCH_SCALE);
    float w1 = square_blend(f1);

    // Grille 2 (dual, décalée de 0.5)
    vec2 I2 = floor(uv + 0.5);
    vec2 f2 = fract(uv + 0.5);
    vec2 offset2 = rnd22(I2);
    vec4 tex2 = texture(tex, (uv - offset2) / PATCH_SCALE);
    float w2 = square_blend(f2);

    // Normalisation et mélange
    float norm = w1 + w2 + 0.0001;
    vec4 final_color = (tex1 * w1 + tex2 * w2) / norm;
	
	return final_color;
}



vec4 fractal_texture_mip(sampler2D texBase, vec2 uv, float depth)
{
    float LOD = log(depth);
    float LOD_floor = floor(LOD);
    float LOD_fract = LOD - LOD_floor;

    vec2 uv1 = uv / exp(LOD_floor - 1.0);
    vec2 uv2 = uv / exp(LOD_floor + 0.0);
    vec2 uv3 = uv / exp(LOD_floor + 1.0);

    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    vec4 tex0 = carreDual(uv1);
    vec4 tex1 = carreDual(uv2);
    vec4 tex2 = carreDual(uv3);


    return (tex1 + mix(tex0, tex2, LOD_fract)) * 0.5;
}




void fragment() {
	
	
    vec2 U = UV * PATCH_SCALE;
	
	
	
    vec3 world_camera = (INV_VIEW_MATRIX  * vec4(vec3(0.0), 1.0)).xyz; // pos de la cam

    vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0); // pos du point

    float camera_distance = distance(a.xyz, world_camera);    // distance entre point et cam


	
	vec4 col;
	if(camera_distance>=distMax){

		float depth = distMax*0.001;
    	depth *= 1e3 / VIEWPORT_SIZE.y;
    	col = carreDual(U);

	}
	else{
		float depth = camera_distance*0.001;
    	depth *= 1e3 / VIEWPORT_SIZE.y;
    	col = mix(fractal_texture_mip(tex, U, depth),carreDual(U),camera_distance/distMax);
	}



    ALBEDO = col.rgb;
    ALPHA = 1.0;



}
