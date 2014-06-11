function [E, data, P] = get_data_E(network, num_exp, maxS)

bn_opt = struct('network', network, 'n', []);
dag = get_dag(bn_opt);

[data, E, P] = deal({});
fid = fopen(sprintf('%s_pvals.list', network), 'r');
tline = fgets(fid);
counter = 1;
while (ischar(tline) && counter <= num_exp)
    eval(sprintf('load %s', strtrim(tline)));
    data{end+1} = out.data;
    [P{end+1}, ~] = p2e(size(dag, 1), maxS, out.p, out.set_size, out.ij);
    tline = fgets(fid);
    counter = counter + 1;
end

    