function [bnet, opt] = make_bnet(opt)

[dag, opt] = get_dag(opt);

n = size(dag, 1);
node_sizes = opt.arity * ones(1,n);
if opt.arity > 1
    dnodes = 1:n;
else
    dnodes = [];
end
bnet = mk_bnet(dag, node_sizes, 'observed', [], 'discrete', dnodes);

for i = 1:n
    numpa =  sum(dag(:,i));
    if strcmpi(opt.data_gen, 'linear_ggm')
        bnet.CPD{i} = gaussian_CPD(bnet, i, 'mean', 0, 'cov', opt.variance, 'weights', sample_dirichlet(ones(1,numpa),1));
    elseif strcmpi(opt.data_gen, 'quadratic_ggm')
        if numpa == 0
            variance = 0.1;
        else
            variance = opt.variance;
        end
        bnet.CPD{i} = polynomial_gaussian_CPD(bnet, i, 'mean', 0, 'cov', variance, 'weights', mk_weights(numpa));
    elseif strcmpi(opt.data_gen, 'random')
        if numpa == 0
            unif = ones(1, opt.arity) / opt.arity;
            bnet.CPD{i} = tabular_CPD(bnet, i, unif);
        else
            bnet.CPD{i} = tabular_CPD(bnet, i, mk_random_cpd(opt.arity,numpa+1));
        end
    else
        error('Unexpected model data_gen');
    end       
end

end

function w = mk_weights(numpa)
    degree = 2;
    w = randn(numpa, degree);
    while (sum(abs(w(:)) < 0.3) > 0)
        w = randn(numpa, degree);
    end
end

