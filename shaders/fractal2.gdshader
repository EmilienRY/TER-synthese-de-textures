shader_type spatial;
uniform sampler2D dirt_texture: source_color;


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

    vec4 tex0 = textureGrad(tex, uv1, dx, dy);
    vec4 tex1 = textureGrad(tex, uv2, dx, dy);
    vec4 tex2 = textureGrad(tex, uv3, dx, dy);

    return (tex1 + mix(tex0, tex2, LOD_fract)) * 0.5;
}

void fragment()
{

    vec2 uv = UV;
    uv = fract(uv * 1.0);

    vec3 world_camera = (INV_VIEW_MATRIX  * vec4(vec3(0.0), 1.0)).xyz; // pos de la cam

    vec4 a = INV_VIEW_MATRIX * vec4(VERTEX, 1.0); // pos du point

    float camera_distance = distance(a.xyz, world_camera);    // distance entre point et cam

    float depth = camera_distance*0.00005;
    depth *= 1e3 / VIEWPORT_SIZE.y;


    vec4 col = fractal_texture_mip(dirt_texture, uv, depth);

    ALBEDO = col.rgb;
    ALPHA = 1.0;

}
