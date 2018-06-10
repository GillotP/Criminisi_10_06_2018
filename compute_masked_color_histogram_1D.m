function density = compute_masked_color_histogram_1D(Im_color,mask_color)

% Compute the color histogram of a color image. The resulting histogram is
% one-dimentional (that is the histograms for each color are concatenated).
% If a mask is passed in second argument, only the masked values are
% considered when computing the histograms.

assert(size(Im_color,3) == 3);
Im_R = Im_color(:,:,1);
Im_G = Im_color(:,:,2);
Im_B = Im_color(:,:,3);

if (nargin == 1)
    density_R = compute_gray_histogram(Im_R);
    density_G = compute_gray_histogram(Im_G);
    density_B = compute_gray_histogram(Im_B);
else
    density_R = compute_gray_histogram(Im_R(mask_color(:,:,1) == 1));
    density_G = compute_gray_histogram(Im_G(mask_color(:,:,2) == 1));
    density_B = compute_gray_histogram(Im_B(mask_color(:,:,3) == 1));
end

density = [density_R;
           density_G;
           density_B];

end

