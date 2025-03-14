shader_type spatial;
uniform sampler2D noise_texture: source_color;
uniform float PATCH_SCALE;

mat2 inv(mat2 m) {
    float det = m[0][0] * m[1][1] - m[0][1] * m[1][0];
	return mat2(vec2(m[1][1], -m[1][0]),vec2( -m[0][1], m[0][0])) / det;

}


vec2 rnd22(vec2 p) {
    return fract(sin((p) * mat2(vec2(127.1,311.7),vec2(269.5,183.3))) * 43758.5453);
}

/*artéfacts*/

void fragment() {
    mat2 M0 = mat2(vec2(1.0, 0.0), vec2(0.5, sqrt(3.0)/2.0));
    mat2 M = inverse(M0);

    vec2 U = UV * PATCH_SCALE;
    vec2 V = M * U;
    vec2 I = floor(V);
    vec2 F = fract(V);

    vec2 Gx = dFdx(U / PATCH_SCALE);
    vec2 Gy = dFdy(U / PATCH_SCALE);

    vec4 m = texture(noise_texture, U,99.);

    vec3 F3 = vec3(F, 0.0);
    F3.z = 1.0 - F3.x - F3.y;

    vec3 W;
    vec4 O;


	if (F3.z > 0.0) {
        W = vec3(F3.z, F3.y, F3.x);
        O = W.x * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I), Gx, Gy) - m)
          + W.y * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m)
          + W.z * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m);
    } else {
        W = vec3(-F3.z, 1.0 - F3.y, 1.0 - F3.x);
        O = W.x * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 1.0)), Gx, Gy) - m)
          + W.y * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I + vec2(1.0, 0.0)), Gx, Gy) - m)
          + W.z * (textureGrad(noise_texture, U / PATCH_SCALE - rnd22(I + vec2(0.0, 1.0)), Gx, Gy) - m);
    }

    O = m + O / length(W);
    ALBEDO = O.rgb;
}
