function search_windows = compute_search_windows(im_rgb,opt_priorityX,opt_priorityY,valid_offsets,full_source_mask,max_window_size)

% Creates a search window for the current processed inpainting point, union 
% of different square windows. Those square windows are selected based on 
% the history of already processed inpainting points in the vicinity of the
% current processed point.

M = size(im_rgb,1);
N = size(im_rgb,2);
search_windows = zeros(M,N);
square_mag_valid_offsets = valid_offsets(:,:,1).^2 + valid_offsets(:,:,2).^2;
valid_offsets_ind = find((square_mag_valid_offsets > 0));
L = length(valid_offsets_ind);
alpha = (80-5*L)/100; 

for l = 1:L
    
    [ind_offset_x,ind_offset_y] = ind2sub([M N],valid_offsets_ind(l));
    mag_offset = sqrt(square_mag_valid_offsets(ind_offset_x,ind_offset_y));
    window_size = max_window_size*((mag_offset == 1) + alpha*sqrt(mag_offset)*(mag_offset > 1));
    window_size = round(window_size);
    offset_x = valid_offsets(ind_offset_x,ind_offset_y,1);
    offset_y = valid_offsets(ind_offset_x,ind_offset_y,2);
    x = ind_offset_x + offset_x;
    y = ind_offset_y + offset_y;
    x1 = max(x - window_size,1);
    x2 = min(x + window_size,M);
    y1 = max(y - window_size,1);
    y2 = min(y + window_size,N);
    search_windows(x1:x2,y1:y2) = 1;

end

x1 = max(opt_priorityX - max_window_size,1);
x2 = min(opt_priorityX + max_window_size,M);
y1 = max(opt_priorityY - max_window_size,1);
y2 = min(opt_priorityY + max_window_size,N);
search_windows(x1:x2,y1:y2) = 1;
search_windows = search_windows.*full_source_mask;

end
