function M_out = bilinear_interpolation_unit_circle(M_in)

% Perform the bilinear interpolation of a 3x3 bloc based on the unit circle

assert((size(M_in,1) == 3)*(size(M_in,2) == 3)*(size(M_in,3) == 1) == 1);

M_out = M_in;
val = 0.5*sqrt(2);
v = [(1-val) ; val];

bilin_top_right = [M_in(2,2) M_in(1,2);
                   M_in(2,3) M_in(1,3)];

bilin_top_right_rotate_90 = [M_in(2,2) M_in(2,1);
                             M_in(1,2) M_in(1,1)];
                         
bilin_top_right_rotate_180 = [M_in(2,2) M_in(3,2);
                              M_in(2,1) M_in(3,1)];
                          
bilin_top_right_rotate_270 = [M_in(2,2) M_in(2,3);
                              M_in(3,2) M_in(3,3)];
                          
M_out(1,3) = v'*bilin_top_right*v;
M_out(1,1) = v'*bilin_top_right_rotate_90*v;
M_out(3,1) = v'*bilin_top_right_rotate_180*v;
M_out(3,3) = v'*bilin_top_right_rotate_270*v;
               
end

