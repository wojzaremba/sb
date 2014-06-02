cancerMakeBN;


nObservationCases = 350; % # observational data cases
nInterventionCases = 0; % no interventions
interventions = {};
[data clamped] = mkData(bnet, nObservationCases, interventions, nInterventionCases );

save(fullfile('demos2', 'cancerDataObs.mat'), 'data', 'clamped')


% intervene on A should uniquely resolve the markov equivalence class
nObservationCases = 350; % # observational data cases
nInterventionCases = 350; % no interventions
interventions = { {-1, [], [], [], []} };
% -1 means node 1 is drawn from [0.5 0.5] when clamped
[data clamped] = mkData(bnet, nObservationCases, interventions, nInterventionCases );

save(fullfile('demos2', 'cancerDataInterA.mat'), 'data', 'clamped')


