function valid_offsets = find_valid_offsets(offset_map,patch_history,overlap_zone,patch_size)

% Checks history of already processed inpaiting points to determine which
% zones of the image will be likely to contain relevant patchs for the
% inpainting point currently processed.

M = size(offset_map,1);
N = size(offset_map,2);
patch_history_ind = find((patch_history == 2));
L = length(patch_history_ind);
valid_offsets = zeros(M,N,2);

for l = 1:L
    
    [ind_offset_x,ind_offset_y] = ind2sub([M N],patch_history_ind(l));
    x1 = ind_offset_x - patch_size;
    x2 = ind_offset_x + patch_size;
    y1 = ind_offset_y - patch_size;
    y2 = ind_offset_y + patch_size;
    mask_previous_patch = zeros(M,N);
    mask_previous_patch(x1:x2,y1:y2) = patch_history(x1:x2,y1:y2);
    if (sum(sum(mask_previous_patch.*overlap_zone)) > 0)
        valid_offsets(ind_offset_x,ind_offset_y,:) = offset_map(ind_offset_x,ind_offset_y,:);
    end
    
end

end

