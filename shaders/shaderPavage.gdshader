shader_type spatial;

uniform sampler2D noise_texture: source_color;

const float CONTRAST = 1.0;
const float PATCH_SCALE = 8.0;

vec2 rnd22(vec2 p) {
	return fract(sin((p) * mat2(vec2(127.1,269.5),vec2(311.7,183.3)) )*43758.5453);
}

vec4 srgb2rgb(vec4 v) {
    return pow(max(v, vec4(0.0)), vec4(2.2));
}

vec4 rgb2srgb(vec4 v) {
    return pow(max(v, vec4(0.0)), vec4(1.0/2.2));
}

vec4 get_color(vec2 I, vec2 U, vec2 P, vec2 Gx, vec2 Gy, vec4 m) {
    return srgb2rgb(textureGrad(noise_texture, U/PATCH_SCALE - rnd22(I), Gx, Gy)) - m * float(CONTRAST);
}

vec2 transform_m0(vec2 v) {
    return vec2(v.x + 0.5 * v.y, (sqrt(3.0)/2.0) * v.y);
}

vec2 inverse_transform(vec2 v) {
    float det = sqrt(3.0)/2.0;
    return vec2(v.x - (0.5/det) * v.y, v.y/det);
}

void fragment() {

    vec2 R = 1.0 / VIEWPORT_SIZE;
    vec2 U = (2.0 * UV - R) * R.y * PATCH_SCALE/8.0;
    
    vec2 V = inverse_transform(U);
    vec2 I = floor(V);
    vec2 P = vec2(0.0);
    
    float p = 0.7 * fwidth(U.y);
    vec2 Gx = dFdx(U/PATCH_SCALE);
    vec2 Gy = dFdy(U/PATCH_SCALE);
    vec4 m = srgb2rgb(texture(noise_texture, U));
    
    vec3 F = vec3(fract(V), 0.0);
    F.z = 1.0 - F.x - F.y;
    vec3 W;
    vec4 O;
    
    if (F.z > 0.0) {
        W.x = F.z;
        W.y = F.y;
        W.z = F.x;
        O = W.x * get_color(I, U, P, Gx, Gy, m)
          + W.y * get_color(I + vec2(0.0, 1.0), U, P, Gx, Gy, m)
          + W.z * get_color(I + vec2(1.0, 0.0), U, P, Gx, Gy, m);
    } else {
        W.x = -F.z;
        W.y = 1.0 - F.y;
        W.z = 1.0 - F.x;
        O = W.x * get_color(I + vec2(1.0, 1.0), U, P, Gx, Gy, m)
          + W.y * get_color(I + vec2(1.0, 0.0), U, P, Gx, Gy, m)
          + W.z * get_color(I + vec2(0.0, 1.0), U, P, Gx, Gy, m);
    }
    
    if (CONTRAST == 1.0) {
        O = m + O/length(W);
    }
    
    O = clamp(rgb2srgb(O), vec4(0.0), vec4(1.0));
    if (m.g == 0.0) {
        O = O.rrrr;
    }
    
    ALBEDO = O.rgb;
}