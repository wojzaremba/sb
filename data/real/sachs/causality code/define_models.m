% defines all the models in one spot
addpath( [ pwd, '/util/' ] );
addpath( [ pwd, '/algorithms/' ] );
addpath( genpath( [ pwd, '/mark/' ] ));


bernoulli_ig_struct.name = 'Multinomial Ignore'; 
bernoulli_ig_struct.shortname = 'Multinomial Ignore';
bernoulli_ig_struct.typename = 'Mul';
dirPrior = [ .1];
bernoulli_ig_struct.params = num2cell( dirPrior )';
bernoulli_ig_struct.fit = @bernoulli_ig;

bernoulli_ind_struct.name = 'Multinomial Independent';  
bernoulli_ind_struct.shortname = 'Multinomial Independent';
bernoulli_ind_struct.typename = 'Mul';
dirPrior = [ .1];
bernoulli_ind_struct.params = num2cell( dirPrior )';
bernoulli_ind_struct.fit = @bernoulli_ind;

bernoulli_cond_struct.name = 'Multinomial Conditional';   
bernoulli_cond_struct.shortname = 'Multinomial Conditional';
bernoulli_cond_struct.typename = 'Mul';
lambda = [ .1 ];
bernoulli_cond_struct.params = num2cell( lambda )';
bernoulli_cond_struct.fit = @bernoulli_cond;


mob_ig_struct.name = 'MixBer Ignore';
mob_ig_struct.shortname = 'MM Ignore';
mob_ig_struct.typename = 'MM';
nComponents = [ 10 ];
dirPrior = [ .1 ];
mob_ig_struct.params = num2cell( cartprod( nComponents, dirPrior ) );
%model = mixBernoulli(X,nComponents,dirPrior)
mob_ig_struct.fit = @MoB_ig;

mob_ind_struct.name = 'MixBer Independent';
mob_ind_struct.shortname = 'MM Ind';
mob_ind_struct.typename = 'MM';
nComponents = [ 10 ];
dirPrior = [ .1 ];
mob_ind_struct.params = num2cell( cartprod( nComponents, dirPrior ) );
%model = mixBernoulli(X,nComponents,dirPrior)
mob_ind_struct.fit = @MoB_ind;

mob2_cond_struct.name = 'Mixture of Bernoulli Conditional (GEM)';
mob2_cond_struct.shortname = 'MM Cond';
mob2_cond_struct.typename = 'MM';
nComponents = [ 10 ];
lambda = [ .1 ]; % 2.681093
mob2_cond_struct.params = num2cell( cartprod( nComponents, lambda ) );
%model = mixBernoulli(X,nComponents,dirPrior)
mob2_cond_struct.fit = @MoB_cond2;


ugm_p_ig_struct.name = 'UGM Ignore Pseudo';
ugm_p_ig_struct.shortname = 'UGM Ignore';
ugm_p_ig_struct.typename = 'UGM';
ising = [ 0 ];
lambda = [ 1 ];
infer = [ 1 ]; 
gL1 = 0;
ugm_p_ig_struct.params = num2cell( cartprod( ising,lambda,infer,gL1 ) );
%model = mixBernoulli(X,nComponents,dirPrior)
ugm_p_ig_struct.fit = @UGM_ig;

ugm_p_ind_struct.name = 'UGM Ind Pseudo';
ugm_p_ind_struct.shortname = 'UGM Ind';
ugm_p_ind_struct.typename = 'UGM';
ising = [ 0 ];
lambda = [ 1 ];
infer = [ 1 ];
gL1 = 0;
ugm_p_ind_struct.params = num2cell( cartprod( ising,lambda,infer,gL1 ) );
%model = mixBernoulli(X,nComponents,dirPrior)
ugm_p_ind_struct.fit = @UGM_ind;


ugm_cond_struct.name = 'UGM Cond';
ugm_cond_struct.shortname = 'UGM Cond';
ugm_cond_struct.typename = 'UGM';
ising = [ 0 ];
lambda = [ 1 ]; % 2.554406
infer = [ 1 ];
gL1 = 0;
ugm_cond_struct.params = num2cell( cartprod( ising,lambda,infer,gL1 ) );
%model = mixBernoulli(X,nComponents,dirPrior)
ugm_cond_struct.fit = @UGM_cond;


bdagl_ignore_struct.name = 'BDAGL Ignore';
bdagl_ignore_struct.shortname = 'DAG Ignore';
bdagl_ignore_struct.typename = 'DAG';
maxFanIn = [ 6 ];
bdagl_ignore_struct.params = num2cell( cartprod( maxFanIn ) );
% model = BDAGL_perfect( all_data, maxFanIn, nActionVars, regime )
bdagl_ignore_struct.fit = @BDAGL_ignore;

bdagl_perfect_struct.name = 'BDAGL Perfect';
bdagl_perfect_struct.shortname = 'DAG Perfect';
bdagl_perfect_struct.typename = 'DAG';
maxFanIn = [ 6 ];
bdagl_perfect_struct.params = num2cell( cartprod( maxFanIn ) );
% model = BDAGL_perfect( all_data, maxFanIn, nActionVars, regime )
bdagl_perfect_struct.fit = @BDAGL_perfect;

bdagl_uncertain_struct.name = 'BDAGL Uncertain';
bdagl_uncertain_struct.shortname = 'DAG Cond';
bdagl_uncertain_struct.typename = 'DAG';
maxFanIn = [ 4 ];
bdagl_uncertain_struct.params = num2cell( cartprod( maxFanIn ) );
%model = mixBernoulli(X,nComponents,dirPrior)
bdagl_uncertain_struct.fit = @BDAGL_uncertain;