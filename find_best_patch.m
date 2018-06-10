function [best_patch,best_patch_center] = find_best_patch(target_patch_RGB,target_patch_Lab,source_patches_RGB,source_patches_Lab,source_patch_centers,mag_chunk,phase_chunk,non_target_mask_color,treshold)

% Selects the best patch to inpaint the inpainting point currently
% processed. The selection is based on the minimization of a score, which
% corresponds to the multiplication of two terms: an euclidian norm
% multiplied by a an other score which measures the structural similiraty
% between patches.

opt_dist = intmax;
S = size(source_patches_RGB,1);
s = sqrt(S);
best_index = 1;

for k = 1:size(source_patches_RGB,2)/3
    
    offset = 3*k;
    
    candidate_patch_RGB = reshape(source_patches_RGB(:,offset-2:offset),[s s 3]);
%     normalized_LBP_histogram_1 = compute_masked_color_LBP_histogram(target_patch_RGB,non_target_mask_color);
%     normalized_LBP_histogram_2 = compute_masked_color_LBP_histogram(candidate_patch_RGB,non_target_mask_color);
%     dist_stuctural_similarity = sqrt(1-sum(sqrt(normalized_LBP_histogram_1.*normalized_LBP_histogram_2)));

    % Other metric:
    dist_stuctural_similarity = compute_hellinger_distance(target_patch_RGB,candidate_patch_RGB,mag_chunk,phase_chunk,non_target_mask_color,treshold);
    
    candidate_patch_Lab = reshape(source_patches_Lab(:,offset-2:offset),[s s 3]);
    patch_1 = target_patch_Lab.*non_target_mask_color;  
    patch_2 = candidate_patch_Lab.*non_target_mask_color;
    patch_1_vec = reshape(patch_1,[3*S 1]);
    patch_2_vec = reshape(patch_2,[3*S 1]);
    dist_SSD = sum((patch_2_vec-patch_1_vec).^2);
    
    dist = dist_SSD*dist_stuctural_similarity;

    if (dist < opt_dist)
        best_index = offset;
        opt_dist = dist;
    end
    
end

best_patch = reshape(source_patches_RGB(:,best_index-2:best_index),[s s 3]);
best_patch_center = source_patch_centers(:,best_index/3);

end

