function M = mutual_information( X, Y )
% returns the mutual information ( in nats ) of two column vectors.

M = marginal_entropy( X ) + marginal_entropy( Y ) - joint_entropy( [ X Y ] );