function idx = choose_rand_off_diag(matrix_dims)

% choose a random entry of a matrix of arbitrary size that is not on the diagonal

idx = zeros(length(matrix_dims),1);

while (length(unique(idx)) == 1)
    idx = choose_rand_matrix_elt(matrix_dims);
end

end

function idx = choose_rand_matrix_elt(matrix_dims)

idx = zeros(length(matrix_dims),1);

for d = 1:length(matrix_dims)
    idx(d) = randi(matrix_dims(d),1);
end

end

