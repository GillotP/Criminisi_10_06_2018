function density = compute_gray_histogram(Im_gray)

% Computes the 8-bit histogram of a gray image.

assert(size(Im_gray,3) == 1);
Im_gray = im2uint8(Im_gray);  
Im_gray_vec = double(Im_gray(:));
density = zeros(256,1);
L = length(Im_gray_vec);

for l = 1:L
    
    value = Im_gray_vec(l);
    if (density(value+1) == 0)
        density(value+1) = sum((Im_gray_vec == value));
    end 

end

end

