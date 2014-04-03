classdef LinearKernel < Kernel
    properties
    end
    
    methods
        function obj = LinearKernel()
            obj@Kernel(); 
            obj.name = 'LinearKernel';
        end
            
        function ret = k(obj, x, y)
            ret = x * y';
        end
        
    end
end

