function bnet = mk_child_random(arity)

randn('seed', 1);

BirthAsphyxia = 1;
Disease = 2;
Sick = 3;
DuctFlow = 4;
CardiacMixing = 5;
LungParench = 6;
LungFlow = 7;
LVH = 8;
Age = 9;
Grunting = 10;
HypDistrib = 11;
HypoxialnO2 = 12;
CO2 = 13;
ChestXray = 14;
LVHreport = 15;
GruntingReport = 16;
LowerBodyO2 = 17;
RUQO2 = 18;
CO2Report = 19;
XrayReport = 20;


n = 20;
dag = zeros(n);
dag(BirthAsphyxia, Disease) = 1;
dag(Disease, [Age Sick DuctFlow CardiacMixing LungParench LungFlow LVH]) = 1;
dag(Sick, [Age Grunting]) = 1;
dag(DuctFlow, HypDistrib) = 1;
dag(CardiacMixing, [HypDistrib HypoxialnO2]) = 1;
dag(LungParench, [Grunting HypoxialnO2 CO2 ChestXray]) = 1;
dag(LungFlow, ChestXray) = 1;
dag(LVH, LVHreport) = 1;
dag(Grunting, GruntingReport) = 1;
dag(HypDistrib, LowerBodyO2) = 1;
dag(HypoxialnO2, [LowerBodyO2 RUQO2]) = 1;
dag(CO2, CO2Report) = 1;
dag(ChestXray, XrayReport) = 1;

node_sizes = arity * ones(1,n);
discrete_nodes = 1:n;
bnet = mk_bnet(dag, node_sizes, 'discrete', discrete_nodes,'observed',[]);

unif = ones(1, arity) / arity;

% source node
bnet.CPD{1} = tabular_CPD(bnet, 1, unif); 

% nodes with one parent
one_parent = [2:8 13 15:16 18:20];
for i = 1:length(one_parent)
    idx = one_parent(i);
    bnet.CPD{idx} = tabular_CPD(bnet,idx,mk_random_cpd(arity,2));
end

% nodes with two parents
two_parents = [9:12 14 17];
for i = 1:length(two_parents)
    idx = two_parents(i);
    bnet.CPD{idx} = tabular_CPD(bnet,idx,mk_random_cpd(arity,3));
end


% bnet.CPD{Disease} = tabular_CPD(bnet,Disease,);
% bnet.CPD{Sick} = tabular_CPD(bnet,Sick,);
% bnet.CPD{DuctFlow} = tabular_CPD(bnet,DuctFlow,);
% bnet.CPD{CardiacMixing} = tabular_CPD(bnet,CardiacMixing,);
% bnet.CPD{LungParench} = tabular_CPD(bnet,LungParench,);
% bnet.CPD{LungFlow} = tabular_CPD(bnet,LungFlow,);
% bnet.CPD{LVH} = tabular_CPD(bnet,LVH,);
% bnet.CPD{Age} = tabular_CPD(bnet,Age,);
% bnet.CPD{Grunting} = tabular_CPD(bnet,Grunting,);
% bnet.CPD{HypDistrib} = tabular_CPD(bnet,HypDistrib,);
% bnet.CPD{HypoxialnO2} = tabular_CPD(bnet,HypoxialnO2,);
% bnet.CPD{CO2} = tabular_CPD(bnet,CO2,);
% bnet.CPD{ChestXray} = tabular_CPD(bnet,ChestXray,);
% bnet.CPD{LVHreport} = tabular_CPD(bnet,LVHreport,);
% bnet.CPD{GruntingReport} = tabular_CPD(bnet,GruntingReport,);
% bnet.CPD{LowerBodyO2} = tabular_CPD(bnet,LowerBodyO2,);
% bnet.CPD{RUQO2} = tabular_CPD(bnet,RUQO2,);
% bnet.CPD{CO2Report} = tabular_CPD(bnet,CO2Report,);
% bnet.CPD{XrayReport} = tabular_CPD(bnet,XrayReport,);
                    


  
  
