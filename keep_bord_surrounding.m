function new_bin_im = keep_bord_surrounding(bin_im)

% Only keep the contour of a filled shape (expressed as a logical mask).

bin_im_vec = bin_im(:);
for i = 1:length(bin_im_vec)
    if ((bin_im_vec(i) ~= 0)*(bin_im_vec(i) ~= 1) == 1)
        error('Image must be binary !');
    end
end

M = size(bin_im,1);
N = size(bin_im,2);
assert((sum(bin_im(1,:)) + sum(bin_im(M,:)) + sum(bin_im(:,1)) + sum(bin_im(:,N)) == 0));
new_bin_im = zeros(M,N);

bin_im_transpose = bin_im';

for n = 2:(N-1)
    
    v1 = bin_im(:,n);
    v2 = circshift(v1,[1,0]);
    v3 = circshift(v1,[-1,0]);
    v = v1 + v2 + v3;
    ind = logical((v1 == 1).*(v > 0).*(v < 3));
    new_bin_im(ind,n) = 1;
    
    w1 = bin_im_transpose(:,n);
    w2 = circshift(w1,[1,0]);
    w3 = circshift(w1,[-1,0]);
    w = w1 + w2 + w3;
    ind = logical((w1 == 1).*(w > 0).*(w < 3));
    new_bin_im(n,ind) = 1;

end

end

