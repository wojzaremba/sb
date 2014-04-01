function test_compute_sb()
disp('test_compute_sb...');

N = 100:10:500;
assert(length(N)>20);
jmax = 50;
arity = 3;
alpha = 1;
rho = zeros(1,jmax);
sb_mean = zeros(1,length(N));

% generate random dependent distribution
mi = 0;
while mi < 0.01
    P = rand_dist_linear(arity);
    mi = mutual_information(P);
end
printf(2,'   mutual information for dependent distribution is %d.\n',mi);
eta = mi/2;

% compute mean_sb for each N
for i = 1:length(N)
    for j = 1:jmax
        D = sample_N_from_dist(P,N(i)); 
        rho(j) = compute_sb(D,eta,alpha);
    end
    sb_mean(i) = mean(rho);
end

% figure;
% plot(N,sb_mean);
% title('Dependent');
% the distribution is dependent, so rho should increase to 1 with N
for i = 1:5
    assert(sb_mean(end-5+i) > sb_mean(i))
end

% independent distribution
P = ones(2,2)*0.25;
eta = 0.01;

% compute mean_sb for each N
for i = 1:length(N)
    for j = 1:jmax
        D = sample_N_from_dist(P,N(i)); 
        rho(j) = compute_sb(D,eta,alpha);
    end
    sb_mean(i) = mean(rho(~isnan(rho)));
end

% figure;
% plot(N,sb_mean,'r*');
% hold on
% plot(N,sb_mean,'b-');
% title('Independent');
% the distribution is independent, so rho should decrease to 1 with N
for i = 1:5
    assert(sb_mean(end-5+i) < sb_mean(i))
end



end
