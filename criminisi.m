clc; clear all; close all;

% Crimisini algorithm implementation by Pierre Gillot
% Entirely based on the following publications:
% Criminisi et al. (2004) Region Filling and Object Removal by
%                         Exemplar-Based Image Inpainting
% (http://www.irisa.fr/vista/Papers/2004_ip_criminisi.pdf

% Buyssens et al. (2015) Exemplar-based Inpainting: Technical Review and 
%                        new Heuristics for better Geometric Reconstructions
% (https://hal.archives-ouvertes.fr/hal-01147620/document)

%% Loading an image to inpaint:
im_RGB = imread('femme.jpg');
im_RGB = double(im_RGB);
im_RGB = im_RGB/255;
M = size(im_RGB,1);
N = size(im_RGB,2);

%% Contour of the inpainting zone:
target_mask_contour = zeros(M,N);
target_mask_contour(200:250,55) = 1;
target_mask_contour(200:250,290) = 1;
target_mask_contour(200,55:290) = 1;
target_mask_contour(250,55:290) = 1;

%% Inpainting zone ("target mask"): 
target_mask = imfill(target_mask_contour,'holes');
target = im_RGB.*repmat(target_mask,[1 1 3]);

%% Non-inpainting zone:
source_mask = 1 - target_mask;
source = im_RGB.*repmat(source_mask,[1 1 3]);

%% Displaying image, inpainting zone and non-inpainting zone:
figure(1)
imagesc(im_RGB), title('image');

figure(2)
imagesc(target), title('target');

figure(3)
imagesc(source), title('source');

%% Setting hyperparameters of the Criminisi algorithm:
patch_size = 2; % square patches of width 2*patch_size + 1, centered on the contour of the target mask
max_window_size = 3*patch_size; % square search windows of width 2*window_size + 1
stride = patch_size; % setting space between extracted patches within a search window

%% Computing the color gradient:
G_mag_RGB = cell(3);
G_phase_rad_RGB = cell(3);

for c = 1:3
    [Gx,Gy] = imgradientxy(im_RGB(:,:,c));
    [G_mag,G_phase_deg] = imgradient(Gx,Gy);
    G_mag_RGB{c} = G_mag;
    G_phase_rad_RGB{c} = deg2rad(G_phase_deg);
end

G_mag_RGB_max = max(G_mag_RGB{1},G_mag_RGB{2});
G_mag_RGB_max = max(G_mag_RGB_max,G_mag_RGB{3});

mask_1 = (G_mag_RGB{1} == G_mag_RGB_max);
mask_2 =(G_mag_RGB{2} == G_mag_RGB_max);
mask_3 = (G_mag_RGB{3} == G_mag_RGB_max);

G_phase_rad_RGB_max = G_phase_rad_RGB{1}.*(mask_1) + G_phase_rad_RGB{2}.*(mask_2) + G_phase_rad_RGB{3}.*(mask_3); 

%% Setting a grad threshold:
max_G_mag = max(G_mag_RGB_max(:));
grad_treshold = 0.5*max_G_mag;


%% Initializing the algorithm:
[indX,indY] = find(target_mask_contour > 0); 
offset_map = zeros(M,N,2);
cmpt = 0;
non_target_mask = 1 - target_mask;
inpainted_im = im_RGB.*repmat(non_target_mask,[1 1 3]);
confidence_map = non_target_mask;
full_source_mask = non_target_mask;
patch_history = zeros(M,N); 
im_Lab = RGB2Lab(im_RGB); 

while ((sum(target_mask_contour(:)) > 0)) % while the inpainting zone isn't fully processed
    
    tic
    cmpt = cmpt + 1;
    disp(['------------- Filling patch ' num2str(cmpt) ' -------------']);
    
    %% Computing all priorities of the pixel on target contour, extract pixel with highest priority:
    [opt_priorityX,opt_priorityY,opt_confidence] = compute_opt_priority(indX,indY,G_mag_RGB_max,G_phase_rad_RGB_max,confidence_map,non_target_mask,patch_size);

    %% Masks to separate inner and outer parts of the contour:
    x1 = opt_priorityX - patch_size;
    x2 = opt_priorityX + patch_size;
    y1 = opt_priorityY - patch_size;
    y2 = opt_priorityY + patch_size;
    non_target_mask_gray = non_target_mask(x1:x2,y1:y2);
    target_mask_gray = 1 - non_target_mask_gray;
    non_target_mask_color = repmat(non_target_mask_gray,[1 1 3]);
    target_mask_color = repmat(target_mask_gray,[1 1 3]);
    
    %% Extracting the highest priority patch:
    opt_priority_patch = im_RGB(x1:x2,y1:y2,:);
    
    %% Identifying valid offsets:
    overlap_zone = zeros(M,N);
    overlap_zone(x1:x2,y1:y2) = non_target_mask_gray + target_mask_contour(x1:x2,y1:y2);
    valid_offsets = find_valid_offsets(offset_map,patch_history,overlap_zone,patch_size);

    %% Determining searching sites:
    search_windows = compute_search_windows(im_RGB,opt_priorityX,opt_priorityY,valid_offsets,full_source_mask,max_window_size);

    %% Extracting source patches (in Lab space):
    [source_patches_RGB,source_patches_Lab,source_patch_centers] = collect_source_patches(im_RGB,im_Lab,search_windows,patch_size,stride);
    
    %% Performing matching (in Lab space):
    opt_priority_patch_Lab = RGB2Lab(opt_priority_patch);
    mag_chunk = G_mag_RGB_max(x1:x2,y1:y2);
    phase_chunk = G_phase_rad_RGB_max(x1:x2,y1:y2);
    [best_patch,best_patch_center] = find_best_patch(opt_priority_patch,opt_priority_patch_Lab,source_patches_RGB,source_patches_Lab,source_patch_centers,mag_chunk,phase_chunk,non_target_mask_color,grad_treshold);
    inpainted_im(x1:x2,y1:y2,:) = inpainted_im(x1:x2,y1:y2,:).*non_target_mask_color + best_patch.*target_mask_color;

    %% Updating process:
    confidence_map(x1:x2,y1:y2) = confidence_map(x1:x2,y1:y2).*non_target_mask_gray + opt_confidence*target_mask_gray;
    offset_map(opt_priorityX,opt_priorityY,1) = best_patch_center(1) - opt_priorityX;
    offset_map(opt_priorityX,opt_priorityY,2) = best_patch_center(2) - opt_priorityY;
    patch_history(x1:x2,y1:y2) = 1;
    patch_history(opt_priorityX,opt_priorityY) = 2;
    target_mask(x1:x2,y1:y2) = 0;
    non_target_mask = 1 - target_mask;
    target_mask_contour = keep_bord_surrounding(target_mask);
    [indX,indY] = find(target_mask_contour > 0);
    disp(['Patch ' num2str(cmpt) ' successfully processed']);
    disp(' ');
    toc

    %% Displaying inpainted image iteration after iteration:
    figure(4)
    imagesc(inpainted_im);
 
end

%% Displaying final result:
figure(5)
imagesc(inpainted_im);
