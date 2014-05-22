function [dag, opt] = get_dag(opt)

if ~isfield(opt, 'moralize')
    opt.moralize = false;
end

if isnumeric(opt.network)
    dag = opt.network;
    
elseif strcmpi(opt.network, 'sachs')
   % consensus network according to Kevin Murphy's paper
    n = 11;
    
    Raf = 1;
    Mek = 2;
    PLCg = 3;
    PIP2 = 4;
    PIP3 = 5;
    Erk = 6;
    AKT = 7;
    PKA = 8; 
    PKC = 9;
    P38 = 10;
    JNK = 11;
    
    dag = zeros(n);
    dag(Raf, Mek) = 1;
    dag(Mek, Erk) = 1;
    dag(PLCg, [PIP2, PKC]) = 1;
    dag(PIP2, PKC) = 1;
    dag(PIP3, [PIP2, PLCg, AKT]) = 1;
    dag(PKA, [AKT, Erk, Mek, Raf, JNK, P38]) = 1;
    dag(PKC, [Mek, Raf, JNK, P38]) = 1;
    
    assert(length(find(dag)) == 18);
    

elseif strcmpi(opt.network, 'large')
    
    opt = init_n(opt, 50);
    n = opt.n;
    p = 2.5*n / (n^2 - n); % will generate a dag with ~(5/4)n edges
    P = p * ones(n);
    for i = 1 : opt.n
        for j = 1 : i
            P(i, j) = 0;
        end
    end
    dag = sample_dag(P);
    
elseif strcmpi(opt.network,'child')
   
    opt = init_n(opt, 20);
    
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
    
    dag = zeros(opt.n);
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
    
elseif strcmpi(opt.network, 'asia')
    
    opt = init_n(opt, 8);
    
    Smoking = 1;
    Bronchitis = 2;
    LungCancer = 3;
    VisitToAsia = 4;
    TB = 5;
    TBorCancer = 6;
    Dys = 7;
    Xray = 8;
    
    dag = zeros(opt.n);
    dag(Smoking, [Bronchitis LungCancer]) = 1;
    dag(Bronchitis, Dys) = 1;
    dag(LungCancer, TBorCancer) = 1;
    dag(VisitToAsia, TB) = 1;
    dag(TB, TBorCancer) = 1;
    dag(TBorCancer, [Dys Xray]) = 1;
        
elseif (strcmpi(opt.network, 'ins') || strcmpi(opt.network, 'insurance'))
    
    opt = init_n(opt, 27);
    
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
    
    dag = zeros(opt.n);
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
    for i = 1:opt.n
        for j = 1:i
            assert(dag(i,j) == 0);
        end
    end
    
elseif strcmpi(opt.network,'chain')
    
    opt = init_n(opt, 4);
    
    dag = zeros(opt.n);
    
    for i = 1:(opt.n-1)
        dag(i,i+1) = 1;
    end
    
elseif strcmpi(opt.network,'vstruct')
    
    opt = init_n(opt, 3);
    dag = zeros(opt.n);
    for i = 1:opt.n - 1
        dag(i, opt.n) = 1;
    end

elseif strcmpi(opt.network, 'Y')
    opt = init_n(opt, 4);
    dag = zeros(opt.n);
    dag(1,3) = 1;
    dag(2,3) = 1;
    dag(3,4) = 1;
    
elseif strcmpi(opt.network, 'kite')
   opt = init_n(opt, 4);
    dag = zeros(opt.n);
    dag(1,[2 3]) = 1;
    dag(2,3) = 1;
    dag(3,4) = 1;
    
elseif strcmpi(opt.network, 'empty')
    opt = init_n(opt, 8);
    dag = zeros(opt.n);
  
else
    error('Unexpected network name');
end

if opt.moralize
    dag = moralize_dag(dag);
    %assert(isequal(dag, moralize_dag(dag)));
    assert(is_topol_sorted(dag));
end

opt.maxpa = get_maxpa(dag);

end

function opt = init_n(opt, default)
    if ~isfield(opt, 'n')
        opt.n = default;
    end
end

function pa = get_maxpa(dag)
    pa = max(sum(dag, 1));
end
    