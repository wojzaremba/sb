classdef IndKernel < Kernel
    properties
    end
    
    methods
        function obj = IndKernel()
            obj@Kernel(); 
            obj.name = 'IndKernel';
        end
            
        function ret = k(obj, x, y)
            xx = repmat(reshape(x, [size(x, 1), 1, size(x, 2)]),  [1, size(y, 1), 1]);
            yy = repmat(reshape(y, [1, size(y, 1), size(y, 2)]), [size(x, 1), 1, 1]);
            ret = sum(xx == yy, 3) == size(x, 2);
        end
        
    end
end

