function hbg = plot_sachs(G)


names = {'Raf', 'Mek', 'PLCg', 'PIP2', 'PIP3', 'Erk', 'Akt', 'PKA', 'PKC', 'P38', 'JNK'};
bg = biograph(G, names);
hbg = view(bg);
radius = 60;
center = [400 400];
for i = 1:11
set(hbg.Nodes(i),'Position',...
   [center(1)-radius.*sin(-2*pi/3 + (i*2*pi/11)),...
    center(2)+radius.*cos(-2*pi/3 + (i*2*pi/11))])
end

set(hbg.Nodes(:), 'Shape', 'ellipse')
set(hbg.Nodes(:), 'Color', [1 1 1])
%set(hbg.Nodes(:), 'FontSize', 8)
set(hbg.Edges(:), 'LineColor', [0 0 0])

% for i = 1:numel(hbg.Edges)
%     name1i = num2str(find(hbg.Nodes == hbg.Edges(i).FromNode));
%     name2i = num2str(find(hbg.Nodes == hbg.Edges(i).ToNode));
%     directed = true;
%     % find undirected edges
%     for j = i+1:numel(hbg.Edges)
%         name1j = num2str(find(hbg.Nodes == hbg.Edges(j).FromNode));
%         name2j = num2str(find(hbg.Nodes == hbg.Edges(j).ToNode));
%         if (strcmpi(name1i, name2j) && strcmpi(name2i, name1j))
%             directed = false;
%         end 
%     end 
%     if ~directed
%         set(hbg.Edges(i), 'ShowArrows','off');
%     end
% end

dolayout(hbg,'pathsOnly',true)


end
