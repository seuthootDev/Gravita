shader_type canvas_item;

uniform vec4 bg_a : source_color = vec4(0.02, 0.03, 0.06, 1.0);
uniform vec4 bg_b : source_color = vec4(0.00, 0.00, 0.00, 1.0);
uniform vec4 star_color : source_color = vec4(0.70, 0.85, 1.0, 1.0);

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

float star_layer(vec2 uv, float density, float twinkle_speed) {
	vec2 gv = uv * density;
	vec2 id = floor(gv);
	vec2 f = fract(gv);
	float h = hash(id);
	vec2 p = vec2(hash(id + 1.23), hash(id + 4.56));
	float d = length(f - p);
	float s = smoothstep(0.035, 0.0, d);
	float t = 0.65 + 0.35 * sin(TIME * twinkle_speed + h * 6.2831);
	return s * step(0.965, h) * t;
}

void fragment() {
	vec2 uv = UV;

	// Subtle vertical gradient.
	vec4 col = mix(bg_b, bg_a, smoothstep(0.0, 1.0, uv.y));

	// Stars (3 layers).
	float s1 = star_layer(uv + vec2(0.01 * TIME, 0.0), 70.0, 1.2);
	float s2 = star_layer(uv + vec2(-0.015 * TIME, 0.02 * TIME), 120.0, 1.6);
	float s3 = star_layer(uv + vec2(0.02 * TIME, -0.01 * TIME), 200.0, 2.1);
	float stars = s1 + 0.7 * s2 + 0.45 * s3;
	col.rgb += star_color.rgb * stars;

	// Slight vignette.
	vec2 v = uv - 0.5;
	float vig = smoothstep(0.85, 0.25, dot(v, v));
	col.rgb *= vig;

	COLOR = col;
}

