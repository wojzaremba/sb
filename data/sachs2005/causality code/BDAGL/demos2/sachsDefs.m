%load sachs_data_and_mv;

nNodes = 11;
nConditions = 9;

INHIBIT = 1;
EXCITE = 3;

% nodes
% order from [sachs05]
% raf = 1;
% mek12 = 2;
% erk = 3;
% p38 = 4;
% pka = 5;
% pkc = 6;
% jnk = 7;
% pip2 = 8;
% pip3 = 9;
% picy = 10;
% akt = 11;

% order from excel files
raf = 1;
mek12 = 2;
plcy = 3; % == lcg in the excel files?
pip2 = 4;
pip3 = 5;
erk = 6; % AKA p44/22, pg 4 sachs05
akt = 7;
pka = 8;
pkc = 9;
p38 = 10;
jnk = 11;

labels = {'raf','mek12','plcy','pip2','pip3','erk','akt','pka','pkc','p38','jnk'};

effect = zeros(nConditions, nNodes);

% conditions in order of the excel files
% 1. Anti-CD3/CD28
% 2. Anti-CD3/CD28 + ICAM-2
% 3. Anti-CD3/CD28 + AKT Inhibitor
effect(3, akt) = INHIBIT;
% 4. Anti-CD3/CD28 + G06976 % error in someone's paper, G06975 VS G0076
effect(4, pkc) = INHIBIT;
% 5. Anti-CD3/CD28 + Psitechtorigenin
effect(5, pip2) = INHIBIT;
% 6. Anti-CD3/CD28 + U0126
effect(6, mek12) = INHIBIT;
effect(6, erk) = INHIBIT; % error in Ellis paper
% 7. Anti-CD3/CD28 + LY294002
effect(7, akt) = INHIBIT;
% 8. PMA
effect(8, pkc) = EXCITE;
% 9. B2cAMP
effect(9, pka) = EXCITE;


% % conditions in order [sachs05.pdf]
% % 1. Anti-CD3/CD28
% % 2. Anti-CD3/CD28 + ICAM-2
% % 3. Anti-CD3/CD28 + U0126
% effect(3, mek12) = INHIBIT;
% effect(3, erk) = INHIBIT; % error in Ellis paper
% % 4. Anti-CD3/CD28 + AKT Inhibitor
% effect(4, akt) = INHIBIT;
% % 5. Anti-CD3/CD28 + G06976
% effect(5, pkc) = INHIBIT;
% % 6. Anti-CD3/CD28 + Psitechtorigenin
% effect(6, pip2) = INHIBIT;
% % 7. Anti-CD3/CD28 + LY294002
% effect(7, akt) = INHIBIT;
% % 8. PMA
% effect(8, pkc) = EXCITE;
% % 9. B2cAMP
% effect(9, pka) = EXCITE;

% % conditions in order of data supplement
% % 1. Anti-CD3/CD28
% % 2. Anti-CD3/CD28 + ICAM-2
% % 3. PMA
% effect(3, pkc) = EXCITE;
% % 4. B2cAMP
% effect(4, pka) = EXCITE;
% % 5. Anti-CD3/CD28 + U0126
% effect(5, mek12) = INHIBIT;
% effect(5, erk) = INHIBIT; % error in Ellis paper
% % 6. Anti-CD3/CD28 + G06976 % error in Ellis paper -- G0076??
% effect(6, pkc) = INHIBIT;
% % 7. Anti-CD3/CD28 + Psitechtorigenin
% effect(7, pip2) = INHIBIT;
% % 8. Anti-CD3/CD28 + AKT Inhibitor
% effect(8, akt) = INHIBIT;
% % 9. Anti-CD3/CD28 + LY294002
% effect(9, akt) = INHIBIT;

% order in Ellis is totally different










