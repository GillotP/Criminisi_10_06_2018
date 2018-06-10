function LBP_histogram = compute_masked_color_LBP_histogram(Im_color,mask_color)

% Compute the LBP color histogram of a color image. The resulting histogram 
% is one-dimentional (that is the histograms for each color are 
% concatenated). If a mask is passed in second argument, only the masked 
% values are considered when computing the histograms.

assert(size(Im_color,3) == 3);
[M,N] = size(Im_color);

Im_R = Im_color(:,:,1);
Im_G = Im_color(:,:,2);
Im_B = Im_color(:,:,3);

LBP_R = compute_LBP(Im_R);
LBP_G = compute_LBP(Im_G);
LBP_B = compute_LBP(Im_B);

LBP_R = LBP_R/255;
LBP_G = LBP_G/255;
LBP_B = LBP_B/255;

if (nargin == 1)
    LBP_histogram_R = compute_gray_histogram(LBP_R(LBP_R >= 0));
    LBP_histogram_G = compute_gray_histogram(LBP_G(LBP_G >= 0));
    LBP_histogram_B = compute_gray_histogram(LBP_B(LBP_B >= 0));
    normalizer = 3*M*N - 6*(M+N);
else
    mask_R = (LBP_R >= 0).*(mask_color(:,:,1));
    mask_G = (LBP_G >= 0).*(mask_color(:,:,2));
    mask_B = (LBP_B >= 0).*(mask_color(:,:,3));
    LBP_histogram_R = compute_gray_histogram(LBP_R(logical(mask_R)));
    LBP_histogram_G = compute_gray_histogram(LBP_G(logical(mask_G)));
    LBP_histogram_B = compute_gray_histogram(LBP_B(logical(mask_B)));
    normalizer = sum(mask_R(:)) + sum(mask_G(:)) + sum(mask_B(:));
end

LBP_histogram = [LBP_histogram_R;
                 LBP_histogram_G;
                 LBP_histogram_B];
             
LBP_histogram = LBP_histogram/normalizer;

end

