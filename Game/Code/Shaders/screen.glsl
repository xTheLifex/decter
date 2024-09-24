float colorSimilarity(vec3 colorA, vec3 colorB) {
    // Calculate the squared difference for each color component
    float diffR = colorA.r - colorB.r;
    float diffG = colorA.g - colorB.g;
    float diffB = colorA.b - colorB.b;
    
    // Compute the squared distance
    float distanceSquared = diffR * diffR + diffG * diffG + diffB * diffB;
    
    // Use a threshold to define what is considered similar (can adjust this)
    float threshold = 3.0; // Adjust based on the color space
    float similarity = smoothstep(0.0, threshold, distanceSquared);
    
    // Return 1.0 - similarity to get a similarity score from 0 to 1
    return 1.0 - similarity;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 pixel = Texel(tex, texture_coords);

    // Apply scanline effect
    if (mod(floor(screen_coords.y), 2.0) == 0.0)
    {
        if (colorSimilarity(vec3(pixel.r,pixel.g,pixel.b), vec3(0,0,0)) > 0.85)
        {
            return pixel * color;
        }
        vec4 dark = pixel * 0.5;
        dark.a = color.a;
        return dark;
    }

    // Return the normal texture color if no darkening is applied
    return pixel * color;
}
