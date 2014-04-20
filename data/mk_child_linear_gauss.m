function bnet = mk_child_linear_gauss(covariance)

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

node_sizes = ones(1,n);
bnet = mk_bnet(dag, node_sizes, 'discrete', [],'observed',[]);

% source node
bnet.CPD{1} = gaussian_CPD(bnet, 1, 'mean',0','cov',covariance); 

% nodes with one parent
one_parent = [2:8 13 15:16 18:20];
for i = 1:length(one_parent)
    idx = one_parent(i);
    bnet.CPD{idx} = gaussian_CPD(bnet,idx,'mean',0,'cov',covariance,'weights',1);
end

% nodes with two parents
two_parents = [9:12 14 17];
for i = 1:length(two_parents)
    idx = two_parents(i);
    bnet.CPD{idx} = gaussian_CPD(bnet,idx,'mean',0,'cov',covariance,'weights',[0.5 0.5]);
end
