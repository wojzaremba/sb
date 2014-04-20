classdef GaussKernel < Kernel
    properties
    end
    
    methods
        function obj = GaussKernel()
            obj@Kernel();
            obj.name = 'GaussKernel';
        end
            
        function ret = k(obj, x, y)
            T = size(x, 1);
            if T <= 200  
                width = 1.2; 
            elseif T < 1200
                 width = 0.7; 
            else
                width = 0.4;
            end            
            theta = 1/(width^2);            
            n2 = dist2(x, y);            
%             if theta == 0
%                 theta = 2/median(n2(tril(n2)>0));
%             end                        
            wi2 = theta / 2;
            ret = exp(-n2*wi2);
        end
        
    end
end

