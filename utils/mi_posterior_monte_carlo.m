function [V,E] = mi_posterior_monte_carlo(D,num_samples)
% approximate the posterior distribution over mutual information by
% sampling from p(pi|D).  D is a arity-by-arity matrix of counts and num_samples is the number of MC
% samples.


theta = sample_dirichlet(D(:),num_samples);
I = zeros(num_samples,1);

for i = 1:num_samples
    P = reshape(theta(i,:),size(D));
    I(i) = mutual_information_ln(P);
end
 
E = mean(I);
V = var(I);

% nbins = 200;
% hfig = figure;
% hold on;
% [counts,bins] = hist(I,nbins);
% bw = bins(2) - bins(1);
% bar(bins,counts/(num_samples*bw*100),'linestyle','none');
% title(sprintf('Posterior over I with n=%d',sum(D(:))),'fontsize',14);
% xlabel('I (mutual information)','fontsize',14);
% ylabel('P(I | D)','fontsize',14);
% 
% hold on;
% 
% y = linspace(0,1,20);
% %fprintf('Warning: plotting mutual information of input counts.\n');
% true_mi = mutual_information_ln(D ./ sum(D(:)));
% gamma =  true_mi*ones(size(y));
% 
% line(gamma,y,'Color','r','LineWidth',2)

end