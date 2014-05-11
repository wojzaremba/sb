function [logPrior isCyclic]= cancerGraphLogPrior( dag )

%  A1
% /  \
% v   v
% B2  C3
%  \  /\
%   v   v
%   D4  E5
%
G = zeros(5);
A = 1; B = 2; C = 3; D = 4; E = 5;
G(A,[B C]) = 1;
G(B,D) = 1;
G(C,[D E]) = 1;

isCyclic = ~acyclic(dag);
if isCyclic
  logPrior = -Inf;
else
  %logPrior = log(1);
  if isequal(dag,G)
    logPrior = log(1);
  else
    logPrior = -Inf;
  end
end
