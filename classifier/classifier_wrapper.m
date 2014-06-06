function [rho, info] = classifier_wrapper(emp, triple, f, opt, prealloc)
% CLASSIFIER_WRAPPER calls the classifier f, once for each conditioning set
% listed in triples.cond_set.  Chooses the rho corresponding to the
% strongest evidence for independence among all conditioning sets tested.
%
% INPUTS:
% emp-  entire empirical distribution, num_vars by num_samples matrix
% opt-  contains options to pass to classifier
% f- classifier function handle
% triple-  defines all conditioning sets to consider for a particular pair
% (i,j), should pass triples{t} from output of gen_triples

rho = Inf;
printf(2, 'i,j = %d,%d\n',triple.i,triple.j);

for c = 1:length(triple.cond_set)
    trip = [triple.i,triple.j,triple.cond_set{c}];
    [new_rho, new_info] = f(emp, trip, opt, prealloc);
    
    if new_rho < rho
        rho = new_rho;
        info = new_info;
        info.cond_set = triple.cond_set{c};
        info.i = triple.i;
        info.j = triple.j;
        info.rho = new_rho;
    end
    
end




