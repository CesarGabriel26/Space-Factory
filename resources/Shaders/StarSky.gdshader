shader_type sky;

#include "res://addons/ShaderLib_v2_2_4/Artistic/Artistic.gdshaderinc"
#include "res://addons/ShaderLib_v2_2_4/UV/UV.gdshaderinc"

uniform float star_height = 5.0;
uniform float star_size = 5.0;
uniform float star_blend : hint_range(0.0, 1.0, 0.01) = .1;
uniform float depth_blend : hint_range(0.0, 1.0, 0.01) = .1;
uniform float flare_ratio : hint_range(0.0, 1.0, 0.01) = .1;
uniform float twinkle_speed = 20.0;
uniform int star_layes = 3;

vec2 RandomVec2(vec2 seed) {
	seed = fract(seed * vec2(123.45, 789.29));
	seed += dot(seed, seed + 874.34);
	float x = fract(seed.x * 164.32);
	float y = fract(seed.y * 287.21);

	return vec2(x,y) - .5;
}

float Star(vec2 uv, float flare) {
	float star = .01 / length(uv);
	float rays = max(0, 1.0 - abs(uv.x * uv.y) * 1000.0) * star;
	star += rays * flare;
	return pow(star, 3);
}

void sky() {
	float blend = smoothstep(star_blend, 1, abs(EYEDIR.y));
	float depth_curve = pow(abs(EYEDIR.y), depth_blend);

	for(float i = 1.; i <= float(star_layes); i++){
		vec2 uv = EYEDIR.xz / depth_curve * star_height * i;
		uv += RandomVec2(vec2(i, i +34.) * i * 4.4);
		if(EYEDIR.y < 0.){
			uv = rotate_uv(uv, vec2(0), 170, true);
		}

		vec2 grid_uv = fract(uv) - .5;
		vec2 grid_id = floor(uv);
		vec3 stars = vec3(0);

		for(float y = -1.0; y <= 1.0; y++){
			for(float x = -1.0; x <= 1.0; x++){
				vec2 offset = vec2(x,y);

				vec2 rv = RandomVec2(grid_id + offset);
				float size = (rv.x + .5)  * star_size;
				float animated_size = (sin(TIME * rv.x * twinkle_speed) * .4 + .6) * size;
				float flare = smoothstep(star_size * (1.0 - flare_ratio), star_size, size);
				vec3 star_color = hue(vec3(1., 0, 0), rv.y * 2., 1);

				star_color *= vec3(1. * size, .4 + (size * rv.y) , 1.5 * (size * rv.y) * i);
				stars += Star(grid_uv - offset - rv, flare) * animated_size * star_color;
			}
		}

		COLOR += stars * blend;
	}
}
