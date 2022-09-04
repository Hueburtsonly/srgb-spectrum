clear
pkg load image

% For no particular reason; all spectral data to be represented as 1000-element arrays corresponding to 1nm, 2nm, 3nm ... 1000nm.

% D65 illuminant
% From http://www.cvrl.org/cie.htm
D65 = [((1:299)'*[1 0]); csvread("illuminantd65.csv"); ((831:1000)'*[1 0 ])];
D65 = D65(:,2:end);
D65 = D65 / 11170.75947;


% 2-deg XYZ CMFs transformed from the CIE (2006) 2-deg LMS cone fundamentals
% From http://cvrl.ucl.ac.uk/cmfs.htm
% lin2012xyz2e_1_7sf.csv
XYZ_spectrum = [((1:389)'*[1,3.769647E-03/390,4.146161E-04/390,1.847260E-02/390]); csvread("lin2012xyz2e_1_7sf.csv"); ((831:1000)'*[1 0 0 0])];
XYZ_spectrum = XYZ_spectrum(:,2:end);
XYZ_spectrum = XYZ_spectrum';

% Apply a slight normalization (within 1.3%) to bring the Chromaticity of D65 whitepoint to 
% (x, y, Y) = (0.3127, 0.3290, 1.0000) as specified by 
% https://en.wikipedia.org/wiki/SRGB
D65_XYZ = XYZ_spectrum * D65;
D65_xyz = D65_XYZ / sum(D65_XYZ);
correction = [1.0000 * 0.3127 / 0.3290, 1.0000, 1.0000 * (1 - 0.3127 - 0.3290) / 0.3290] ./ D65_XYZ';
XYZ_spectrum = XYZ_spectrum .* repmat(correction, [1000 1])';

% Validate correction
%D65_XYZ = XYZ_spectrum * D65
%D65_xyz = D65_XYZ / sum(D65_XYZ)


% sRGB primaries
% sRGB to XYZ (and back)
sRGB_XYZ = inv([
  % R               G        B
  0.4123151515,  0.3576,  0.1805;         % X
  0.2126,        0.7152,  0.0722;         % Y
  0.01932727273, 0.1192,  0.9506333333    % Z
]);


% Apply a slight normalization (within 0.02%) to bring the Chromaticity of D65 
% whitepoint to (1, 1, 1)
correction = 1 ./ (sRGB_XYZ * XYZ_spectrum * D65);
sRGB_XYZ = sRGB_XYZ .* repmat(correction, [1 3]);

% Validate correction
% sRGB_XYZ * XYZ_spectrum * D65

clear D65_XYZ D65_xyz correction


%spectrum_raw = diag(D65 / max(D65));
spectrum_raw = eye(1000);
spectrum_raw = spectrum_raw(:, 300 : 780);
spectrum_raw = imresize(spectrum_raw, [1000 1920]);

% Raw linear sRGB values for pure spectrum.
% This will consist entirely of values outside (0.0, 1.0], since the sRGB gamut
% does not contain any pure spectral colours.
sRGB_spectrum = sRGB_XYZ * XYZ_spectrum * spectrum_raw;

% Dim the spectrum down so that the total range of RGB values is 1.
sRGB_spectrum = sRGB_spectrum / (max(max(sRGB_spectrum)) - min(min(sRGB_spectrum)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Approach 1: Add a D65 haze/"ambient light" across the entire image in order
%              to juuust bring the spectral colours within the sRGB gamut. A 
%              theoretically perfect simulation of what a spectrum projected on
%              a white wall would look like (with some ambient D65 lighting).
%

image_spectrum = repmat(reshape(sRGB_spectrum', [1, size(sRGB_spectrum, 2), 3]), [1080 1 1]);
image_spectrum = repmat(conv(conv(ones(320, 1), ones(10, 1)), [zeros(183+190, 1); ones(6, 1)/50; zeros(183+190, 1)]), [1 size(image_spectrum,2) size(image_spectrum, 3)]) .* image_spectrum;

% Multiply through a scale, lit by a D65 haze across the image
background = repmat(rgb2lin_octave(im2double(imread("scale.png")(:, :, 2))), [1 1 3]);
background = background / max(max(max(background)));
image_spectrum = image_spectrum .* ((background + 1)/2) + -min(min(sRGB_spectrum)) .* background;

% Multiply through a scale and background texture

image_spectrum = image_spectrum ;

% Apply sRGB transfer function
%sRGB_spectrum = image_spectrum .^ (1/2.2);
image_spectrum = lin2rgb_octave(image_spectrum);


imwrite(image_spectrum, "out1.png");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Approach 2: Mix just enough D65 into each spectral colour to bring it within
%              the sRGB gamut, then increase the intensity (Y) of each colour
%              as much as possible without modifying the chromaticity (x, y).
%

app2_sRGB_spectrum = sRGB_spectrum - repmat(min(sRGB_spectrum), [3 1]);
app2_sRGB_spectrum = app2_sRGB_spectrum ./ repmat(max(0.6,max(app2_sRGB_spectrum)), [3 1]);
image_spectrum = repmat(reshape(app2_sRGB_spectrum', [1, size(app2_sRGB_spectrum, 2), 3]), [1080 1 1]);
image_spectrum = lin2rgb_octave(image_spectrum .* background);

imwrite(image_spectrum, "out2.png");