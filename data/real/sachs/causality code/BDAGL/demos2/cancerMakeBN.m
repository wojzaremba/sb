%% deterministic randomness
%seed = 149;
seed = 0;
rand('state', seed);
randn('state', seed);

%  A1
% /  \
% v   v
% B2  C3
%  \  /\
%   v   v
%   D4  E5
%
%dag = mk_rnd_dag(nNodes, maxFanIn);
dag = zeros(5);
A = 1; B = 2; C = 3; D = 4; E = 5;
dag(A,[B C]) = 1;
dag(B,D) = 1;
dag(C,[D E]) = 1;

sz = 2*ones(5,1);

bnet = myMkBnet(5, sz,  'dag', dag, 'method', 'meek' );

if 1
%bnet =  mk_bnet(dag, sz);

p = .9;
%cptA = [.4 .6];
cptA = [0.1 0.9]; % must be different from [0.5 0.5] to detect intervention
cptB = [1-p p ; p 1-p];
cptC = [1-p p ; p 1-p];
cptD = zeros(2, 2, 2);
cptD(:,:,1) = [ .15 .3 ; .7 .9];
cptD(:,:,2) = 1-cptD(:,:,1);
cptE = [p 1-p ; 1-p p];

bnet.CPD{A} = tabular_CPD(bnet, A, 'CPT', cptA);
bnet.CPD{B} = tabular_CPD(bnet, B, 'CPT', cptB);
bnet.CPD{C} = tabular_CPD(bnet, C, 'CPT', cptC);
bnet.CPD{D} = tabular_CPD(bnet, D, 'CPT', cptD);
bnet.CPD{E} = tabular_CPD(bnet, E, 'CPT', cptE);
end
