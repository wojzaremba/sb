function LL = fit_pval_dist(z)

z = z';

for numpts = 3 : 50
    LL(numpts) = 0;
    for leave_out = 1 : length(z)
        zz = z([1:leave_out-1 leave_out + 1:end]);
        [xx, yy] = fit_pval_dist_numpts(zz, numpts);
        f = interp1(xx,yy,z(leave_out));
        LL(numpts) = LL(numpts) + log(f); 
        if mod(leave_out, 1000) == 0
            fprintf(' leave_out = %d\n', leave_out);
        end
    end
    fprintf('finished numpts = %d\n', numpts);
end

end

function [xx, yy] = fit_pval_dist_numpts(z, numpts)

opt = struct('plot_flag', true, 'color', 'b-');
[p, x] = density_est(z, opt);
hold on
xx = linspace(min(x), max(x), numpts);
yy = spline(x, p, xx);
plot(xx, yy, 'm-');

end
