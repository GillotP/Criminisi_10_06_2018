function LBP = compute_LBP(Im)

% Computes the LBP map (local binary patterns) of a gray image.

[M,N] = size(Im);
LBP = -ones(M,N);

binary_weights = [1   2  4;
                  128 0  8;
                  64  32 16];
     
for m = 2:(M-1)
    for n = 2:(N-1)
        chunk_circular = bilinear_interpolation_unit_circle(Im(m-1:m+1,n-1:n+1));
        chunk_circular = chunk_circular-chunk_circular(2,2);
        chunk_circular = (chunk_circular >= 0);
        LBP(m,n) = sum(sum(binary_weights.*chunk_circular));
    end
end

end

