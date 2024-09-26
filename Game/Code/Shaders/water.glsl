// * GLSL to Love2D conversions *
// float -> number
// sampler2D -> Image
// uniform -> extern
// texture2D(tex,uv) -> Texel(tex, uv)

#define TAU 6.28318530718
#define MAX_ITER 12
#define SHORE 0.05
extern number time = 0.0;
extern number screenX;
extern number screenY;

float mid(float x, float a, float b)
{
	return clamp((x-a)/(b-a), 0,1);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 uv = screen_coords / vec2(screenX, screenY);
    vec2 p = mod(uv * TAU * 4, TAU)-250.0;
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .0025;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
    colour = clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0);

	vec4 result = vec4(colour, 0.55) * color;

	
	if (screen_coords.y < 530)
	{
		return mix(result , color * vec4(0.75,0.75,0.75,1), mid(screen_coords.y, 530, 515));
	}

	return result;
}
