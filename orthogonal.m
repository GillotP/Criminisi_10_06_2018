function v_ortho = orthogonal(v)

% Computes the orthogonal of a 2D-vector

assert(length(v) == 2);
v_ortho = [-v(2);
            v(1)];
        
end

