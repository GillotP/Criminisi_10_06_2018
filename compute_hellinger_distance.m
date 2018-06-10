function dist_hellinger = compute_hellinger_distance(target_patch,candidate_patch,mag_chunk,phase_chunk,non_target_mask_color,treshold)

density_target_patch_normalized = zeros(768,1);
density_candidate_patch_normalized = zeros(768,1);
s = size(target_patch,1);
patch_size = (s-1)/2;
[~,argmax_grad] = max(mag_chunk(:));
[x_c,y_c] = ind2sub([s s],argmax_grad);
mag_strongest_gradient = mag_chunk(argmax_grad);

if (mag_strongest_gradient > treshold) 
  
    phase_strongest_gradient = phase_chunk(argmax_grad);
    theta_interface = phase_strongest_gradient - pi/2;
    
    y = patch_size:-1:-patch_size;
    y = y(:);
    x = -patch_size:patch_size;
    y = repmat(y,[1 s]);
    x = repmat(x,[s 1]);
    y = y - y(x_c,y_c);
    x = x - x(x_c,y_c);
    cond = (x <= 0).*(y == 0);
    theta = cond*pi + (1 - cond).*atan2(y,x);

    side_1_mask = (theta > theta_interface).*(theta <= (theta_interface + pi));
    side_2_mask = 1 - side_1_mask;
    side_1_mask = repmat(side_1_mask,[1 1 3]);
    side_2_mask = repmat(side_2_mask,[1 1 3]);

    non_target_mask_color_side_1 = non_target_mask_color.*side_1_mask;
    non_target_mask_color_side_2 = non_target_mask_color.*side_2_mask;
    weight_non_target_side_1 = 3*sum(sum(non_target_mask_color_side_1(:,:,1)));
    weight_non_target_side_2 = 3*sum(sum(non_target_mask_color_side_2(:,:,1)));

    if ((weight_non_target_side_1 > 0)*(weight_non_target_side_2 > 0) == 1)

        %disp('Dealing with a structure patch');
        density_target_patch_side_1 = compute_masked_color_histogram_1D(target_patch,non_target_mask_color_side_1);
        density_target_patch_side_1_normalized = density_target_patch_side_1/weight_non_target_side_1;
        density_target_patch_side_2 = compute_masked_color_histogram_1D(target_patch,non_target_mask_color_side_2);
        density_target_patch_side_2_normalized = density_target_patch_side_2/weight_non_target_side_2;

        size_side_1 = sum(sum(side_1_mask(:,:,1)));
        full_size = s^2;
        size_side_2 = full_size - size_side_1;
        density_target_patch_normalized = (size_side_1/full_size)*density_target_patch_side_1_normalized + (size_side_2/full_size)*density_target_patch_side_2_normalized;
        
        density_candidate_patch = compute_masked_color_histogram_1D(candidate_patch);
        density_candidate_patch_normalized = density_candidate_patch/(3*full_size);

    end
    
else

    target_mask_color = 1-non_target_mask_color;
    weight_target = 3*sum(sum(target_mask_color(:,:,1)));
    weight_non_target = 3*sum(sum(non_target_mask_color(:,:,1)));
    
    if ((weight_non_target > 0)*(weight_target > 0) == 1)

        %disp('Dealing with a texture patch');
        density_target_patch = compute_masked_color_histogram_1D(target_patch,non_target_mask_color);
        density_target_patch_normalized = density_target_patch/weight_non_target;
        density_candidate_patch = compute_masked_color_histogram_1D(candidate_patch,target_mask_color);
        density_candidate_patch_normalized = density_candidate_patch/weight_target;

    end

end

dist_hellinger = sqrt(1-sum(sqrt(density_target_patch_normalized.*density_candidate_patch_normalized)));

end

