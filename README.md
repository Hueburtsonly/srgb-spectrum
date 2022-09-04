# sRGB spectrum
A brief investigation into producing an accurate approximation of a monochromatic light spectrum on an sRGB monitor.  The first thing to note is that this is impossible to do directly, since all pure spectral colours lie outside the sRGB gamut -- some some degree of subjective decision-making has to occur to decide how best to render the spectrum given this limitation.

The first approach I took was to add just enough ambient white light to the scene to desaturate the spectral colours until they fell within the sRGB gamut. This can be though of as a "photo" of a sheet of paper in a dimly lit room, with a light source+prism projecting light onto the sheet of paper. The hope is that the viewer can imagine/extrapolate how vivid the colours would be if the ambient light were removed; in that sense this is about as accurate as an sRGB spectrum can get! But obviously, with the colours desaturated by the white light, the individual colour values are quite dull when interpreted out of context.

![Approach 1](/out1.png)

I also coded up the more common approach of just finding the nearest sRGB approximation for each wavelength (more specifically, the most saturated sRGB colour with chromaticity matching the wavelength). This results in:

![Approach 2](/out2.png)

I recommend [Rendering Spectra](https://aty.sdsu.edu/explain/optics/rendering.html) to follow a more in-depth investigation of this approach.

## Code

[spectrum.m](/spectrum.m) is the main code to run, it generates the two images shown above.  This is MATLAB code, but can also be run for free using GNU Octave (Octave doesn't have the `lin2rgb` or `rgb2lin` functions, so I've included my own implementations here.

## Sources

CIE responsivity and D65 illuminant data from [http://www.cvrl.org/](http://www.cvrl.org/)

Paper texture photo by <a href="https://unsplash.com/@olga_o?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Olga Thelavart</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
  
