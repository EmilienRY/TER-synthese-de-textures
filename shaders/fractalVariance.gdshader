shader_type spatial;
uniform sampler2D tex: source_color;


vec4 fractal_texture_mip(sampler2D t, vec2 uv, float depth,float camdis)
{
    float LOD = log(depth);
    float LOD_floor = floor(LOD);
    float LOD_fract = LOD - LOD_floor;

    vec2 uv1 = uv / exp(LOD_floor - 1.0);
    vec2 uv2 = uv / exp(LOD_floor + 0.0);
    vec2 uv3 = uv / exp(LOD_floor + 1.0);



    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    vec4 m1 = texture(tex, uv1, 99.);
    vec4 m2 = texture(tex, uv2, 99.);
    vec4 m3 = texture(tex, uv3, 99.);
    vec4 m = texture(tex, uv, 99.);


    vec4 tex0 = textureGrad(t, uv1, dx, dy) - m1;
    vec4 tex1 = textureGrad(t, uv2, dx, dy) - m2;
    vec4 tex2 = textureGrad(t, uv3, dx, dy) - m3;

	float W= sqrt(LOD_fract*LOD_fract+(1.-LOD_fract)*(1.-LOD_fract));


	vec4 frac=((tex1 + mix(tex0, tex2, LOD_fract))/W + (3.*m)/3.);

	return frac;
}

void fragment()
{

    vec2 uv = UV;
    uv = fract(uv * 1.0);

    vec3 world_camera = (INV_VIEW_MATRIX  * vec4(vec3(0.0), 1.0)).xyz; // pos de la cam

    vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0); // pos du point

    float camera_distance = distance(a.xyz, world_camera);    // distance entre point et cam

    float depth = camera_distance*0.001;
    depth *= 1e3 / VIEWPORT_SIZE.y;


	ALBEDO = fractal_texture_mip(tex, uv, depth,camera_distance).rgb;
	ALPHA = 1.0;



}
