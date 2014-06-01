function cmp = comparepvalues(p1, stat1, p2, stat2)
%COMPAREPVALUES Compare p-values.
%   CMP = ORG.MENSXMACHINA.STATS.TESTS.UTILS.COMPAREPVALUES(P1, STAT1, P2,
%   STAT2), where P1 and P2 are two p-values and STAT1 and STAT2 are the
%   corresponding statistics, compares P1 and P2 and uses STAT1 and STAT2
%   to break ties. CMP is -1 if P1 < P2 or P1 == P2 and ABS(STAT1) >
%   ABS(STAT2), 1 if P1 > P2 or P1 == P2 and ABS(STAT1) < ABS(STAT2) and 0
%   if P1 == P2 and ABS(STAT1) == ABS(STAT2).

% (no validation)

if p1 < p2
    cmp = -1; 
elseif p1 > p2
    cmp = 1; 
else

    if abs(stat1) > abs(stat2)
        cmp = -1;
    elseif abs(stat1) < abs(stat2)
        cmp = 1;
    else
        cmp = 0;
    end

end

end