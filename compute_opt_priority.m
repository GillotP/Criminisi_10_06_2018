function [opt_priorityX,opt_priorityY,opt_confidence] = compute_opt_priority(indX,indY,G_mag,G_phase_rad,confidence_map,non_target_mask,patch_size)

% Determines which point within the contour of the remaining inpainting
% zone will be processed in the current iteration of the algorithm. The
% selection is based on a confidence term and on a data term. The
% confidence term emphasizes inpainting points whose vicinity are already
% processed, whereas the data term emphasizes inpainting points located on
% the contour of the inpainting zone such that the gradient is orthogonal
% to the normal of the contour, that is the data term enforces the 
% propagation of isophotes.

L = length(indX);
assert (L == length(indY));
confidences = zeros(L,1);
priorities = zeros(L,1);
indX_circ = [indX(end); 
             indX(:); 
             indX(1)]; 
indY_circ = [indY(end);
             indY(:); 
             indY(1)]; 
s = 2*patch_size+1;
S = s^2;
center = patch_size + 1;
u = 1:s;
v = 1:s;
[U,V] = meshgrid(u,v);
gaussian_weights = (1/(2*pi))*exp(-0.5*((U-center)^2+(V-center)^2));
gaussian_weights_table = [gaussian_weights(:) gaussian_weights(:)];

for l = 1:L

    x1 = indX(l) - patch_size;
    x2 = indX(l) + patch_size;
    y1 = indY(l) - patch_size;
    y2 = indY(l) + patch_size;
    
    confidence_chunk = confidence_map(x1:x2,y1:y2);
    confidences(l) = (sum(sum(confidence_chunk)))/S;
    
    dir_contour_X = indX_circ(l+2) - indX_circ(l);
    dir_contour_Y = indY_circ(l+2) - indY_circ(l);
    n = orthogonal([dir_contour_X dir_contour_Y]);
    n = n/norm(n);

%%%%%%(Crimisini 2004)
%     mag_chunk = G_mag(x1:x2,y1:y2).*non_target_mask(x1:x2,y1:y2);
%     phase_chunk = G_phase_rad(x1:x2,y1:y2).*non_target_mask(x1:x2,y1:y2);
%     [~,argmax_grad] = max(mag_chunk(:));
%     mag = mag_chunk(argmax_grad);
%     phase = phase_chunk(argmax_grad);
%     G_ortho = mag*orthogonal([cos(phase) sin(phase)]);
%     data = abs(sum(n.*G_ortho));

%%%%%%(Buyssens 2015)
    mag_chunk = G_mag(x1:x2,y1:y2);
    phase_chunk = G_phase_rad(x1:x2,y1:y2);
    mask = non_target_mask(x1:x2,y1:y2);
    G_ortho = (mask > 0).*mag_chunk.*(-sin(phase_chunk));
    G_ortho(:,:,2) = (mask > 0).*mag_chunk.*(cos(phase_chunk));
    G_ortho = reshape(G_ortho,[S 2]);
    G_ortho_transpose = G_ortho';
    tensor = G_ortho_transpose*(gaussian_weights_table.*G_ortho);
    data = norm(tensor*n);
    
    priorities(l) = confidences(l)*data;

end
    
[~,ind_opt_priority] = max(priorities);
opt_priorityX = indX(ind_opt_priority);
opt_priorityY = indY(ind_opt_priority);
opt_confidence = confidences(ind_opt_priority);
    
end

