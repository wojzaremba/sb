function bnet = mk_ins_poly_gauss(variance)

randn('seed', 1);

Age = 1;            %
SocioEcon = 2;      %
GoodStudent = 3;    %
RiskAversion = 4;   %
OtherCar = 5;       %
SeniorTrain = 6;    %
DrivingSkill = 7;   %
MakeModel = 8;      %
HomeBase = 9;       %
AntiTheft = 10;     %
DrivHist = 11;      %
DrivQuality = 12;   %
VehicleYear = 13;   %
Mileage = 14;       %
Airbag = 15;        %
Antilock = 16;      %
RuggedAuto = 17;    %
CarValue = 18;      %
Theft = 19;         %
Cushioning = 20;    %
Accident = 21;      %
MedCost = 22;       %
ILiCost = 23;       %
OtherCarCost = 24;  %
ThisCarDam = 25;    %
ThisCarCost = 26;   %
PropCost = 27;      %

n = 27;
dag = zeros(n);
dag(Age, [SocioEcon RiskAversion GoodStudent SeniorTrain DrivingSkill MedCost]) = 1;
dag(SocioEcon, [OtherCar RiskAversion GoodStudent MakeModel VehicleYear HomeBase AntiTheft]) = 1;
dag(RiskAversion, [SeniorTrain DrivHist DrivQuality MakeModel VehicleYear HomeBase AntiTheft]) = 1;
dag(SeniorTrain, DrivingSkill) = 1;
dag(DrivingSkill, [DrivHist DrivQuality]) = 1;
dag(MakeModel, [Airbag Antilock RuggedAuto CarValue]) = 1;
dag(HomeBase, Theft) = 1;
dag(AntiTheft, Theft) = 1;
dag(DrivQuality, Accident) = 1;
dag(VehicleYear, [Airbag Antilock RuggedAuto CarValue]) = 1;
dag(Mileage, [Accident CarValue]) = 1;
dag(Airbag, Cushioning) = 1;
dag(Antilock, Accident) = 1;
dag(RuggedAuto, [Cushioning OtherCarCost ThisCarDam]) = 1;
dag(CarValue, [Theft ThisCarCost]) = 1;
dag(Theft, ThisCarCost) = 1;
dag(Cushioning, MedCost) = 1;
dag(Accident, [MedCost ILiCost OtherCarCost ThisCarDam]) = 1;
dag(OtherCarCost, PropCost) = 1;
dag(ThisCarDam, ThisCarCost) = 1;
dag(ThisCarCost, PropCost) = 1;

assert(length(find(dag)) == 52);
% assert that nodes are already topologically sorted
for i = 1:n
    for j = 1:i
        assert(dag(i,j) == 0);
    end
end

node_sizes = ones(1,n);
bnet = mk_bnet(dag, node_sizes, 'discrete', [],'observed',[]);

source_var = 0.1;
assert(variance <= (source_var / 2));

% source node
bnet.CPD{1} = polynomial_gaussian_CPD(bnet, 1, 'mean',0','cov',source_var); 

for i = 2:n
    % count number of parents
    numpa = sum(dag(:,i));
    bnet.CPD{i} = polynomial_gaussian_CPD(bnet, i, 'mean', 0, 'cov', variance, 'weights', mk_weights(numpa));
end

end

function w = mk_weights(numpa)
    degree = 2;
    w = randn(numpa, degree);
end