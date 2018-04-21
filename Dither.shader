shader_type canvas_item;
render_mode unshaded;

void vertex() {
	// pixel snap the circle
	VERTEX.x = round(VERTEX.x);
	VERTEX.y = round(VERTEX.y);
}

void fragment() {
	// COLOR = vec4(1,0,0, 1);
	// float x = 1.0 / SCREEN_PIXEL_SIZE.x * SCREEN_UV.x;
	// float y = 1.0 / SCREEN_PIXEL_SIZE.y * SCREEN_UV.y;
	float x = FRAGCOORD.x;
	float y = FRAGCOORD.y;
	if (int(x) % 2 == int(y) % 2) {
		COLOR.a = 0.0;
	}
}
