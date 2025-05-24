shader_type spatial;
uniform sampler2D tex: source_color;
uniform float PATCH_SCALE;

vec2 rnd22(vec2 p) {
	return fract(sin((p) * mat2(vec2(127.1,311.7),vec2(269.5,183.3))) * 43758.5453);
}


void fragment() {
    mat2 M0 = mat2(vec2(1.0, 0.0), vec2(0.5, sqrt(3.0)/2.0));
    mat2 M = inverse(M0);
    vec2 R = VIEWPORT_SIZE;

    vec2 U = UV * PATCH_SCALE;

    vec2 V = M * U;
    vec2 I = floor(V);

    vec2 Gx = dFdx(U / PATCH_SCALE);
    vec2 Gy = dFdy(U / PATCH_SCALE);

    vec4 m = texture(tex, U,99.);
	vec3 F = vec3(fract(V),0.0);
    F.z = 1.0 - F.x - F.y;

    vec4 O;
	vec3 W;



	if (F.z > 0.0) {
        W = vec3(F.z, F.y, F.x);
        O = W.x * (textureGrad(tex, U / PATCH_SCALE - rnd22(I), Gx, Gy)-m )
          + W.y * (textureGrad(tex, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m)
          + W.z * (textureGrad(tex, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m);
    } else {
        W = vec3(-F.z, 1.0 - F.y, 1.0 - F.x);
        O = W.x * (textureGrad(tex, U / PATCH_SCALE - rnd22(I+1.0), Gx, Gy) - m)
          + W.y * (textureGrad(tex, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m)
          + W.z * (textureGrad(tex, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m);
    }

    O = m + O / length(W);
	ALBEDO = O.rgb;

/*
	float border_width = 0.03;

	float border = smoothstep(0.0, border_width, min(F.x, min(F.y, F.z)));

	vec3 debug_color = vec3(border); // gris foncé sur bord

	ALBEDO = mix(O.rgb, debug_color, 0.5);
	*/


}
