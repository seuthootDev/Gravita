shader_type canvas_item;

// Removes a flat-ish atlas background from sprites.
// Halos: bilinear filtering blends key yellow into sprite edges — those pixels are often
// NOT "near key" in RGB distance (mix looks olive/brown) but still read as yellow fringe.
// We address that with: transition-band treatment + chroma spill toward key hue.

uniform vec4 key_color : source_color = vec4(0.99216, 0.88235, 0.00392, 1.0); // #fde101
uniform float key_threshold = 0.08;
uniform float edge_softness = 0.03;
uniform float despill_strength = 0.65;

uniform float sat_threshold = 0.0;
uniform float value_threshold = 1.0;

// Extra: bilinear spill (R+G high vs B on yellow keys — works when mixed samples aren't near key)
uniform float spill_remove_strength = 0.72;

// Pixels in partial-key band (keep between ~0 and ~1)
uniform float edge_band_blacken = 0.55;

// Raw samples still near key chroma (legacy path)
uniform float inner_yellow_blacken = 0.55;
uniform float inner_yellow_max_dist = 0.22;

uniform float outline_texels = 1.25;
uniform float outline_empty_alpha = 0.12;
uniform float outline_neighbor_alpha = 0.1;
uniform float outline_alpha = 1.0;

void keyed_from_sample(vec4 tex, out vec3 rgb, out float out_a, out float keep) {
	float key_d = distance(tex.rgb, key_color.rgb);
	float key_mask = smoothstep(key_threshold, key_threshold + edge_softness, key_d);

	float mx = max(tex.r, max(tex.g, tex.b));
	float mn = min(tex.r, min(tex.g, tex.b));
	float sat = (mx <= 0.00001) ? 0.0 : (mx - mn) / mx;

	float low_sat = 1.0 - step(sat_threshold, sat);
	float bright = step(value_threshold, mx);
	float gray_mask = 1.0 - (low_sat * bright);

	keep = key_mask * gray_mask;
	out_a = tex.a * keep;

	float edge = clamp(1.0 - keep, 0.0, 1.0);
	rgb = tex.rgb - key_color.rgb * edge * despill_strength;
	rgb = max(rgb, vec3(0.0));
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 rgb;
	float out_a;
	float keep;
	keyed_from_sample(tex, rgb, out_a, keep);

	// 1) Partial-key band: bilinear often lands here; damp toward dark to hide fringe.
	float band = 4.0 * keep * (1.0 - keep);
	rgb = mix(rgb, rgb * 0.15, band * edge_band_blacken);

	// 2) Yellow spill on "kept" pixels: mixed yellow+dark is rarely near key_color in distance.
	float mn = min(tex.r, min(tex.g, tex.b));
	float mx = max(tex.r, max(tex.g, tex.b));
	float yellow_bias = max(0.0, min(tex.r, tex.g) - tex.b);
	float warm_gray = max(0.0, 1.0 - (mx - mn) * 4.0);
	float spill_w = clamp(yellow_bias * 3.5, 0.0, 1.0) * warm_gray * sqrt(out_a + 1e-4);
	rgb -= key_color.rgb * spill_remove_strength * spill_w;
	rgb = max(rgb, vec3(0.0));

	// 3) Near-key raw samples (anti-alias / soft asset edges)
	if (inner_yellow_blacken > 0.001 && out_a > 0.02) {
		float kd = distance(tex.rgb, key_color.rgb);
		float t = 1.0 - smoothstep(inner_yellow_max_dist * 0.35, inner_yellow_max_dist, kd);
		rgb = mix(rgb, vec3(0.0), t * inner_yellow_blacken);
	}

	vec4 c = vec4(rgb, out_a);

	// 4) Outer outline
	if (outline_alpha > 0.001 && c.a <= outline_empty_alpha) {
		vec2 px = TEXTURE_PIXEL_SIZE * max(outline_texels, 0.01);
		vec3 nr;
		float na;
		float nk;
		float max_na = 0.0;

		keyed_from_sample(texture(TEXTURE, UV + vec2(1.0, 0.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(-1.0, 0.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(0.0, 1.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(0.0, -1.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(1.0, 1.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(1.0, -1.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(-1.0, 1.0) * px), nr, na, nk);
		max_na = max(max_na, na);
		keyed_from_sample(texture(TEXTURE, UV + vec2(-1.0, -1.0) * px), nr, na, nk);
		max_na = max(max_na, na);

		if (max_na > outline_neighbor_alpha) {
			c = vec4(0.0, 0.0, 0.0, outline_alpha);
		}
	}

	COLOR = c;
}
