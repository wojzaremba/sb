function classes = classifier_wrapper(emp, triple, f, prealloc, opt)
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
%
% OUTPUTS:
% classes- binary vector the same length as opt.range, with 1
% signifying independence, and 0 dependence.  opt.range is a set of
% threshold values.

rho = Inf;
printf(2,'i,j = %d,%d\n',triple.i,triple.j);

for c = 1:length(triple.cond_set)
    trip = [triple.i,triple.j,triple.cond_set{c}];
    rho = min(rho,f(emp, trip, prealloc, opt));
    printf(2,'%d, %d\n',length(triple.cond_set{c}),rho);
end
printf(2,'\n');

classes = threshold(opt.range,rho);

