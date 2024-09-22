extern number time = 0.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    // Offset the noise with time to make it move
    number noise = perlin2d((screen_coords + vec2(time * 20.0, 0.0)) / 4.0);
    noise = noise * 0.5 + 0.5;

    // Apply the noise to the color
    vec3 c = vec3(noise, noise, noise);

    return vec4(c, 1.0);
}
