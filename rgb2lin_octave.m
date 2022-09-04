function lin = rgb2lin_octave(sRGB)

lin = sRGB / 12.92;
lin(sRGB > 0.04045) = ((sRGB(sRGB > 0.04045) + 0.055) / 1.055) .^ 2.4;
