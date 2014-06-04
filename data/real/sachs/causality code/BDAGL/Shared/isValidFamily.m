function b = isVaildFamily( i, pa, maxFanIn, layering )
% does what mkImpossibleFamilyMask does, except on a single family
% intended for >20 node cases where it's impractical to create full nx2^n mask

b = ~any(pa==i);

if nargin<3 || isempty(maxFanIn)
else
    
    if nargin<4 || isempty(layering)
        b = b & length(pa)<=maxFanIn;
    else
        
        % everything is provided

        uniqueLayers = unique(layering);
        
        if length(maxFanIn)==1 || any( size(maxFanIn)==1 ) % turn it into diagonal matrix
            tv = maxFanIn;
            maxFanIn = repmat(-1, length(uniqueLayers)); % don't cares
            maxFanIn = setDiag(maxFanIn, tv);
        end        
        
        cl = layering(i);
        pl = layering(pa);
        
        if any(pl>cl), b = 0; return; end

        for li=1:min(cl,length(uniqueLayers))
            if maxFanIn(li,cl)==-1, continue; end
            if sum(pl<=li) > maxFanIn(li,cl)
                b = 0; return;
            end
            
        end
        
    end
    
end