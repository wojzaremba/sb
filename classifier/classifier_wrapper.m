function rho = classifier_wrapper(emp, triple, f, opt, prealloc)
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
printf(2,'i,j = %d,%d\n',triple.i,triple.j);
%best_S = [];

for c = 1:length(triple.cond_set)
    trip = [triple.i,triple.j,triple.cond_set{c}];
    %old_rho = rho;
    rho = min(rho,f(emp, trip, opt, prealloc));
    assert(length(rho) == 1);
    printf(2,'%d, %d\n',length(triple.cond_set{c}),rho);
    
    %if ~isequal(rho, old_rho)
    %    best_S = triple.cond_set{c};
    %end
    
    if (rho <= 1e-4) % XXX I think I should take this out when I do structure learning
        break
    end
    assert(rho >= 0)
end
%str = sprintf('  %s best conditioning set for (%d,%d) is ', func2str(f), triple.i, triple.j);
%for i = 1:length(best_S)
%    str = [str num2str(best_S(i)) ' '];
%end
%fprintf('%s\n',str);
printf(2,'\n');



