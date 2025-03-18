shader_type spatial;
uniform sampler2D dirt_texture: source_color;
uniform float PATCH_SCALE;
uniform float distMax;


mat2 inv(mat2 m) {
    float det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
	return mat2(vec2(m[1][1], -m[1][0]),vec2( -m[0][1], m[0][0])) / det;

}


vec2 rnd22(vec2 p) {
    return fract(sin((p) * mat2(vec2(127.1,311.7),vec2(269.5,183.3))) * 43758.5453);
}

/*artéfacts*/


vec4 pavage(vec2 uv) {
    mat2 M0 = mat2(vec2(1.0, 0.0), vec2(0.5, sqrt(3.0)/2.0));
    mat2 M = inverse(M0);

    vec2 U = uv * PATCH_SCALE;
    vec2 V = M * U;
    vec2 I = floor(V);
    vec2 F = fract(V);

    vec2 Gx = dFdx(U / PATCH_SCALE);
    vec2 Gy = dFdy(U / PATCH_SCALE);

    vec4 m = texture(dirt_texture, U,99.);

    vec3 F3 = vec3(F, 0.0);
    F3.z = 1.0 - F3.x - F3.y;

    vec3 W;
    vec4 O;


	if (F3.z > 0.0) {
        W = vec3(F3.z, F3.y, F3.x);
        O = W.x * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I), Gx, Gy) - m)
          + W.y * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m)
          + W.z * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m);
    } else {
        W = vec3(-F3.z, 1.0 - F3.y, 1.0 - F3.x);
        O = W.x * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 1.0)), Gx, Gy) - m)
          + W.y * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m)
          + W.z * (textureGrad(dirt_texture, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m);
    }

    O = m + O / length(W);
    return O;
}



vec4 fractal_texture_mip(sampler2D tex, vec2 uv, float depth)
{
    float LOD = log(depth);
    float LOD_floor = floor(LOD);
    float LOD_fract = LOD - LOD_floor;

    vec2 uv1 = uv / exp(LOD_floor - 1.0);
    vec2 uv2 = uv / exp(LOD_floor + 0.0);
    vec2 uv3 = uv / exp(LOD_floor + 1.0);

    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    vec4 tex0 = pavage(uv1);
    vec4 tex1 = pavage(uv2);
    vec4 tex2 = pavage(uv3);


    return (tex1 + mix(tex0, tex2, LOD_fract)) * 0.5;
}



void fragment()
{

    vec2 uv = UV;
    uv = fract(uv * 1.0);

    vec3 world_camera = (INV_VIEW_MATRIX  * vec4(vec3(0.0), 1.0)).xyz; // pos de la cam

    vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0); // pos du point

    float camera_distance = distance(a.xyz, world_camera);    // distance entre point et cam
	
	vec4 col;
	if(camera_distance>=distMax){
		
		float depth = distMax*0.001;
    	depth *= 1e3 / VIEWPORT_SIZE.y;
    	col = fractal_texture_mip(dirt_texture, uv, depth);
		
	}
	else{
		float depth = camera_distance*0.001;
    	depth *= 1e3 / VIEWPORT_SIZE.y;
    	col = fractal_texture_mip(dirt_texture, uv, depth);
	}



    ALBEDO = col.rgb;
    ALPHA = 1.0;

}
