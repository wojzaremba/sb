function [p, x] = plot_dist(z, opt)

if ~isfield(opt, 'nbins')
    opt.nbins = 50;
end
if ~isfield(opt, 'plot_flag')
    opt.plot_flag = true;
end
if ~isfield(opt, 'color')
    opt.color = 'b-';
end
if ~isfield(opt, 'scale')
    opt.scale = 1;
end

[n,x] = hist(z, opt.nbins);

N = sum(n);
width = x(2) - x(1);
p = (n * opt.scale) / (N * width);

if opt.plot_flag
    %figure
    %hold on
    plot(x, p, opt.color);
end


    
