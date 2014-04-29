classdef PKernel < Kernel
    properties
    end
    
    methods
        function obj = PKernel()
            obj@Kernel();
            obj.name = 'PKernel';
        end
            
        function ret = k(obj, x, y)
            T = size(x, 2);
            if T <= 200  
                width = 1.2; 
            elseif T < 1200
                 width = 0.7; 
            else
                width = 0.4;
            end            
            theta = 1/sqrt(width);            
            np = distp(x, y, 0.5);            
%             if theta == 0
%                 theta = 2/median(n2(tril(n2)>0));
%             end                        
            wi2 = theta / 2;
            ret = exp(-np*wi2);
%             fprintf('GaussKernel %f\n', ret(2));
        end
        
    end
end

