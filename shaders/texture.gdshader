
/*

shader_type spatial;
uniform sampler2D dirt_texture: source_color;


vec4 fractal_texture_mip(sampler2D tex, vec2 uv, float depth)
{
	//Find the pixel level of detail
	float LOD = log(depth);
    //Round LOD down
	float LOD_floor = floor(LOD);
    //Compute the fract part for interpolating
	float LOD_fract = LOD - LOD_floor;

	//Compute scaled uvs
	vec2 uv1 = uv / exp(LOD_floor - 1.0);
	vec2 uv2 = uv / exp(LOD_floor + 0.0);
	vec2 uv3 = uv / exp(LOD_floor + 1.0);

    //Compute continous derivitives
    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    //Sample at 3 scales
	vec4 tex0 = textureGrad(tex, uv1, dx, dy);
	vec4 tex1 = textureGrad(tex, uv2, dx, dy);
	vec4 tex2 = textureGrad(tex, uv3, dx, dy);

    //Blend samples together
	return (tex1 + mix(tex0, tex2, LOD_fract)) *0.5;
}

void fragment()
{
    //Center coordinates

	// PROBLEME GODOT FAUT METTRE UN - DEVANT

    vec2 uv = -(FRAGCOORD.xy / VIEWPORT_SIZE.xy - 0.5);
	uv=UV;
    //Compute perspective
    //float perspective = 1.0 / abs( 5.0 - uv.y * 8.0 );
    //Scale in and outs

    float scale = exp( cos(TIME * 0.5) * 2.5);

    //Compute perspective coordinates
    vec2 coords = uv  * scale;
    //Add scrolling offset
    coords.x += (TIME+sin(TIME*0.5)/0.5)/5e1;

    //Compute pixel depth
    float depth = length(vec3(uv, 1)) * scale ;

    depth *= 1e3 / VIEWPORT_SIZE.y;

    vec4 tex1 = fractal_texture_mip(dirt_texture, coords, depth);

    ALBEDO = tex1.rgb;
	ALPHA = 1.0;
}

*/


shader_type spatial;

uniform sampler2D dirt_texture: source_color;

//Samples at three scales, interpolating between them (with mipmapping)
vec4 fractal_texture_mip(sampler2D tex, vec2 uv, float depth)
{
	//Find the pixel level of detail
	float LOD = log(depth);
    //Round LOD down
	float LOD_floor = floor(LOD);
    //Compute the fract part for interpolating
	float LOD_fract = LOD - LOD_floor;

	//Compute scaled uvs
	vec2 uv1 = uv / exp(LOD_floor - 1.0);
	vec2 uv2 = uv / exp(LOD_floor + 0.0);
	vec2 uv3 = uv / exp(LOD_floor + 1.0);

    //Compute continous derivitives
    vec2 dx = dFdx(uv) / depth * exp(1.0);
    vec2 dy = dFdy(uv) / depth * exp(1.0);

    //Sample at 3 scales
	vec4 tex0 = textureGrad(tex, uv1, dx, dy);
	vec4 tex1 = textureGrad(tex, uv2, dx, dy);
	vec4 tex2 = textureGrad(tex, uv3, dx, dy);

    //Blend samples together
	return (tex1 + mix(tex0, tex2, LOD_fract)) * 0.5;
}

void fragment()
{
    //Center coordinates
    vec2 uv = -(FRAGCOORD.xy / VIEWPORT_SIZE.xy - 0.5);

    //Compute perspective
    float perspective = 1.0 / abs( 5.0 - uv.y * 8.0 );
    //Scale in and out
    float scale = exp( cos(TIME * 0.5) * 2.5);

    //Compute perspective coordinates
    vec2 coords = uv * perspective * scale;
    //Add scrolling offset
    coords.x += (TIME+sin(TIME*0.5)/0.5)/5e1;

    //Compute pixel depth
    float depth = length(vec3(uv, 1)) * scale * perspective;
    depth *= 1e3 / VIEWPORT_SIZE.y;

    vec4 tex0 = texture(dirt_texture, coords*4.0);
    vec4 tex1 = fractal_texture_mip(dirt_texture, coords, depth);
    vec4 col = (uv.x<0.0) ? tex0 : tex1;
    col *= smoothstep(0.0, 3.0, abs(uv.x) * VIEWPORT_SIZE.x);

    //Output results
    ALBEDO = col.rgb;
	ALPHA = 1.0;
}
