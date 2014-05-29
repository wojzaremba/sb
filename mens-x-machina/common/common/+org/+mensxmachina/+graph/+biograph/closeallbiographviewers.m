function closeallbiographviewers
%CLOSEALLBIOGRAPHVIEWERS Close all biograph viewers.
%   ORG.MENSXMACHINA.GRAPH.BIOGRAPH.CLOSEALLBIOGRAPHVIEWERS closes all
%   Bioinformatics Toolbox(TM) biograph viewers.

% Source: http://www.mathworks.com/support/solutions/en/data/1-A7IKD4/index.html?product=BI&solution=1-A7IKD4

% This finds handles to all the Objects in the current session, filters it to find just the handles to the Biograph Viewers so that they can be selectively closed.
child_handles = allchild(0);
names = get(child_handles,'Name');
k = find(strncmp('Biograph Viewer', names, 15));
close(child_handles(k));

end