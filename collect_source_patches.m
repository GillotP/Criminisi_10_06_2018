function [source_patches_RGB,source_patches_Lab,source_patch_centers] = collect_source_patches(im_RGB,im_Lab,search_windows,patch_size,stride)

% Extracts the patches from the search window associated with the inpainting
% point currently processed. Patches are extracted both in RGB and in Lab
% color spaces.

S = (2*patch_size + 1)^2;
M = size(im_RGB,1);
N = size(im_RGB,2);
stride_grid = zeros(M,N);

for m = 1:stride:M
    stride_grid(m,1:stride:N) = 1;
end

for n = 1:stride:N
    stride_grid(1:stride:M,n) = 1;
end 

search_mask_ind = find(search_windows.*stride_grid);
L = length(search_mask_ind);
source_patches_RGB = [];
source_patches_Lab = [];
source_patch_centers = [];

for l = 1:L 
    
    [ind_x,ind_y] = ind2sub([M N],search_mask_ind(l));
    x1 = ind_x - patch_size;
    x2 = ind_x + patch_size;
    y1 = ind_y - patch_size;
    y2 = ind_y + patch_size;
    
    if ((x1 >= 1)*(y1 >= 1)*(x2 <= M)*(y2 <= N) == 1)
        patch_mask = search_windows(x1:x2,y1:y2);
        if (sum(sum(patch_mask)) == S)
            patch_RGB = im_RGB(x1:x2,y1:y2,:);
            patch_Lab = im_Lab(x1:x2,y1:y2,:);
            source_patches_RGB = [source_patches_RGB reshape(patch_RGB,[S 3])];
            source_patches_Lab = [source_patches_Lab reshape(patch_Lab,[S 3])];
            source_patch_centers = [source_patch_centers [ind_x ; ind_y]];
        end
    end
    
end

end

