function dummy()
assert(0)
-d function dummy()\nassert(0)
classdef CombKernel < Kernel
    properties
        kernels
        weights
    end
    
    methods
        function obj = CombKernel(kernels, weights)
            obj@Kernel();
            obj.kernels = kernels;
            obj.weights = weights;
            obj.name = 'CombKernel';
            assert(length(obj.kernels) == length(obj.weights));
        end
            
        function ret = k(obj, x, y)
            ret = 0;
            for i = 1:length(obj.weights)
                ker = obj.kernels{i};
                ret = ret + obj.weights{i} * ker.k(x, y);
            end
        end
        
    end
end

