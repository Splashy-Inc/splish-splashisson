shader_type canvas_item;

uniform vec4 aura_color : source_color = vec4(1.0);
uniform float fade_distance_from_center : hint_range(0, 1.0) = 1.0;
uniform vec2 center = vec2(0.5);

void fragment() {
	if (distance(center, UV) <= 0.5) {
		vec4 color = texture(TEXTURE, UV);
		float fade_amount = (distance(center, UV) - fade_distance_from_center/2.0)/(0.5 - fade_distance_from_center/2.0);
		COLOR = mix(color, aura_color, fade_amount);
	}
}