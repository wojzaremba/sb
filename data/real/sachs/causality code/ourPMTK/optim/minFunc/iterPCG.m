function [P] = iterPCG(A,b,optTol,maxIter)

eccThresh = .1;
nVars = length(b);

% Initialize
x = zeros(size(b));
r = -b;
d = b;


while 1
    % 1 iteration of modified CG
    r_old = r;
    alpha = -(d'*A*r)/(d'*A*A*d);
    x = x + alpha*d;
    r = r + alpha*A*d;
    beta = (r'*A*A*d)/(d'*A*A*d);
    d = r + beta*d;

    if norm(r)/norm(r_old) < eccThresh
        fprintf('Eccentric\n');
        break;
    else
        fprintf('Not eccentric\n');
    end

    if norm(r) <= optTol
        fprintf('Solution Found\n');
        return;
    end
    pause;
end

ri = r_old;
eps = ((ri'*A*ri)^2)/((ri'*A*A*ri)*(ri'*ri))
if (ri'*A*A*ri)/(ri'*ri) < sqrt(eps)
    fprintf('Case 2a\n');
    v = A*ri + ri;
elseif (ri'*A*A*ri)/(ri'*A*A*A*A*ri) < sqrt(eps)
    fprintf('Case 2b\n');
    v = A*A*ri + A*ri;
else
    fprintf('No cases\n');
end
delta = (v'*A*((A+eye(nVars))\v))/(v'*v);
sigma = -1 + sqrt(1-delta)/sqrt(delta);
P = eye(nVars) + (sigma/(v'*v))*v*v';