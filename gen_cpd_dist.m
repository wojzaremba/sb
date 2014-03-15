addpath(genpath('.'));
% bnet = mk_alarm_bnet;
bnet = mk_asia_bnet

N = size(bnet.dag, 1);
samples = zeros(N, 1000);

for i = 1 : size(samples, 2)
    tmp = sample_bnet(bnet);
    for j = 1:length(tmp)
        samples(j, i) = tmp{j};
    end
end
dlmwrite('data.dat', samples' - 1, ' ');