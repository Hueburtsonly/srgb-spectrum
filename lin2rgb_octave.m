function sRGB = lin2rgb_octave(lin)

sRGB = 12.92 * lin;
sRGB(lin > 0.0031308) = 1.055 * (lin(lin > 0.0031308) .^ (1/2.4)) - 0.055;
