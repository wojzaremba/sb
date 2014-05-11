function [x, y, h] = myDrawGraph(adj, varargin)
% dag with a 'lil razzle dazzle
N = size(adj,1);

[groundTruth thresh labels layout nodeColors] = process_options(varargin, 'GroundTruth', [], 'thresh', 0, ...
    'labels', cellstr(int2str((1:N)')), 'layout', [], 'nodeColors', ones(N,3));

adjWeight = adj;
adj = double (adj>thresh);

FN = -1;
FP = -2;

if ~isempty(groundTruth)
    wrong = groundTruth - adj;
    adj(wrong<0) = FP;
    adj(wrong>0) = FN;
end

adj = double(adj);

node_t = zeros(N,1);

axis([0 1 0 1]);
axis('square');
set(gca,'XTick',[],'YTick',[],'box','on');
% axis('square');
%colormap(flipud(gray));

if isempty(layout)
    step = 2*pi/(N);
    t = 0:step:2*pi;
    x = 0.4*sin(t)+0.5; y = 0.4*cos(t)+0.5;
else
    x = layout(1,:);
    y = layout(2,:);
end

idx1 = find(node_t==0); h1 = []; wd1=[];
if ~isempty(idx1)
    for i=1:length(idx1)
        [h1(i,:) wd1(i,:)] = textoval(x(idx1(i)), y(idx1(i)), labels(idx1(i)), nodeColors(idx1(i),:), varargin{:});
    end
end;

idx2 = find(node_t~=0); h2 = []; wd2 = [];
if ~isempty(idx2)
    [h2 wd2] = textbox(x(idx2), y(idx2), labels(idx2), varargin{:});
end;

wd = zeros(size(wd1,1)+size(wd2,1),2);
if ~isempty(idx1), wd(idx1, :) = wd1;  end;
if ~isempty(idx2), wd(idx2, :) = wd2; end;

tp_col = [0 0 0];
fp_col = [0 1 0];
fn_col = [0 0 1];

fp_h = line([-50 -50], [-51 -50], 'color', fp_col);
fn_h = line([-50 -50], [-51 -50], 'color', fn_col);
tp_h = line([-50 -50], [-51 -50], 'color', tp_col);

% bug: this code assumes [x y] is the center of each box and oval, which
% isn't exactly true.
h_edge_tp = [];
h_edge_fp = [];
h_edge_fn = [];
for i=1:N,
    j = find(adj(i,:)~=0);
    for k=j,
        if x(k)-x(i)==0,
            sign = 1;
            if y(i)>y(k), alpha = -pi/2; else alpha = pi/2; end;
        else
            alpha = atan((y(k)-y(i))/(x(k)-x(i)));
            if x(i)<x(k), sign = 1; else sign = -1; end;
        end;
        dy1 = sign.*wd(i,2).*sin(alpha);   dx1 = sign.*wd(i,1).*cos(alpha);
        dy2 = sign.*wd(k,2).*sin(alpha);   dx2 = sign.*wd(k,1).*cos(alpha);

        wi = 1;
        col = [0 0 0];

        st = '-';

        wt = 1;
        if thresh>0
            wt = (adjWeight(i,k)-thresh)/(1-thresh);
            if wt>1, wt=1; end
            if wt<0, wt=0; end
        end

        if adj(i,k) == FP
            col = [0.25 0.7 0.25] + [0.5 0.3 0.5] * (1-wt);
            %st =
        elseif adj(i,k) == FN
            col = [0.25 0.25 0.7] + [0.3 0.3 0.3] * (wt);
            st = '--';
        else
            col = min([1 1 1] * (1-wt),[0.8,0.8,0.8]);
        end

        p1 = [x(i)+dx1 y(i)+dy1];
        p2 = [x(k)-dx2 y(k)-dy2];
        mp = (p1+p2)/2;
        nml = p2-p1;

        nml = nml([2 1]);
        nml(2) = -nml(2);

        if adj(k,i)~=0
            off = 1/sqrt(nml*nml')/40;
            mp = mp + nml*off;
        end

        if thresh>0
            h = line([p1(1) mp(1)],[p1(2) mp(2)], 'linewidth', wi, 'color', col, 'linestyle', st);
            arrow(mp,p2,'BaseAngle',30, 'linewidth', wi, 'color', col, 'LineStyle', st, 'width', 0);
        else
            h = arrow(p1,p2,'BaseAngle',30, 'linewidth', wi, 'color', col, 'LineStyle', st, 'width', 0);
            %h = line([p1(1) p2(1)], [p1(2) p2(2) ], 'linewidth', wi, 'color', col, 'linestyle', st);
        end

        if adj(i,k) == FP
            h_edge_fp = [h_edge_fp h];
        elseif adj(i,k) == FN
            h_edge_fn = [h_edge_fn h];
        else
            h_edge_tp = [h_edge_tp h];
        end
    end;

end;

if ~isempty(groundTruth)
    na = {};
    hs = [];
    if length(h_edge_tp)>0
        na{length(na)+1} = 'correct';
        hs = [hs tp_h];
    end
    if length(h_edge_fp)>0
        na{length(na)+1} = 'added';
        hs = [hs fp_h];
    end
    if length(h_edge_fn)>0
        na{length(na)+1} = 'missed';
        hs = [hs fn_h];
    end
    if length(hs)>0
        legend(hs, na);
    end
end

color.box = 'black';
color.text = color.box;
color.edge = [1 1 1]*3/4;
%color.edge = 'green';
if ~isempty(idx1)
    set(h1(:,1),'Color',color.text)
    set(h1(:,2),'EdgeColor',color.box)
end
if ~isempty(idx2)
    set(h2(:,1),'Color',color.text)
    set(h2(:,2),'EdgeColor',color.box)
end
% if(~exist('adjWeight','var'))
% 	set(h_edge,'Color',color.edge)
% end

if nargout>2,
    h = zeros(length(wd),2);
    if ~isempty(idx1),
        h(idx1,:) = h1;
    end;
    if ~isempty(idx2),
        h(idx2,:) = h2;
    end;
end;

%%%%%

function [t, wd] = textoval(x, y, str, bgColor, varargin)
% TEXTOVAL		Draws an oval around text objects
%
%  [T, WIDTH] = TEXTOVAL(X, Y, STR)
%  [..] = TEXTOVAL(STR)  % Interactive
%
% Inputs :
%    X, Y : Coordinates
%    TXT  : Strings
%
% Outputs :
%    T : Object Handles
%    WIDTH : x and y Width of ovals
%
% Usage Example : [t] = textoval('Visit to Asia?');
%
%
% Note     :
% See also TEXTBOX

% Uses :

% Change History :
% Date		Time		Prog	Note
% 15-Jun-1998	10:36 AM	ATC	Created under MATLAB 5.1.0.421
% 12-Mar-2004   10:00 AM        minka   Changed placement/sizing.
%
% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl

temp = [];
textProperties = {'BackgroundColor','Color','FontAngle','FontName','FontSize','FontUnits','FontWeight','Rotation'};
varargin = argfilter(varargin,textProperties);

if nargin == 1
    str = x;
end
if ~isa(str,'cell') str=cellstr(str); end;
N = length(str);
wd = zeros(N,2);
for i=1:N,
    if nargin == 1
        [x, y] = ginput(1);
    end
    if str2num(str{i})<10, str{i} = [ str{i} ' ']; end
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center',varargin{:});
    % minka
    [ptc wx wy] = draw_oval(tx, bgColor );
    wd(i,:) = [wx wy];
    % draw_oval will paint over the text, so need to redraw it
    delete(tx);
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center',varargin{:});
    temp = [temp;  tx ptc];
end
if nargout>0, t = temp; end;

%%%%%%%%%


function [ptc, wx, wy] = draw_oval(tx, bgColor)
% Draws an oval box around a tex object
sz = get(tx,'Extent');
% minka
wy = 2/3*sz(4);
wx = 2/3*sz(3);
x = sz(1)+sz(3)/2;
y = sz(2)+sz(4)/2;
ptc = ellipse(x, y, wx, wy);
set(ptc, 'FaceColor',bgColor);


%%%%%%%%%%%%%

function [p] = ellipse(x, y, rx, ry, c)
% ELLIPSE		Draws Ellipse shaped patch objects
%
%  [<P>] = ELLIPSE(X, Y, Rx, Ry, C)
%
% Inputs :
%    X : N x 1 vector of x coordinates
%    Y : N x 1 vector of y coordinates
%    Rx, Ry : Radii
%    C : Color index
%
%
% Outputs :
%    P = Handles of Ellipse shaped path objects
%
% Usage Example : [] = ellipse();
%
%
% Note     :
% See also

% Uses :

% Change History :
% Date		Time		Prog	Note
% 27-May-1998	 9:55 AM	ATC	Created under MATLAB 5.1.0.421

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl

if (nargin < 2) error('Usage Example : e = ellipse([0 1],[0 -1],[1 0.5],[2 0.5]); '); end;
if (nargin < 3) rx = 0.1; end;
if (nargin < 4) ry = rx; end;
if (nargin < 5) c = 1; end;

if length(c)==1, c = ones(size(x)).*c; end;
if length(rx)==1, rx = ones(size(x)).*rx; end;
if length(ry)==1, ry = ones(size(x)).*ry; end;

n = length(x);
p = zeros(size(x));
t = 0:pi/30:2*pi;
for i=1:n,
    px = rx(i)*cos(t)+x(i);
    py = ry(i)*sin(t)+y(i);
    p(i) = patch(px,py,c(i));
end;

if nargout>0, pp = p; end;

%%%%%

function [t, wd] = textbox(x,y,str,varargin)
% TEXTBOX	Draws A Box around the text
%
%  [T, WIDTH] = TEXTBOX(X, Y, STR)
%  [..] = TEXTBOX(STR)
%
% Inputs :
%    X, Y : Coordinates
%    TXT  : Strings
%
% Outputs :
%    T : Object Handles
%    WIDTH : x and y Width of boxes
%%
% Usage Example : t = textbox({'Ali','Veli','49','50'});
%
%
% Note     :
% See also TEXTOVAL

% Uses :

% Change History :
% Date		Time		Prog	Note
% 09-Jun-1998	11:43 AM	ATC	Created under MATLAB 5.1.0.421
% 12-Mar-2004   10:00 AM        minka   Changed placement/sizing.
%
% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl

temp = [];
textProperties = {'BackgroundColor','Color','FontAngle','FontName','FontSize','FontUnits','FontWeight','Rotation'};
varargin = argfilter(varargin,textProperties);

if nargin == 1
    str = x;
end
if ~isa(str,'cell') str=cellstr(str); end;
N = length(str);
wd = zeros(N,2);
for i=1:N,
    if nargin == 1
        [x, y] = ginput(1);
    end
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center',varargin{:});
    % minka
    [ptc wx wy] = draw_box(tx);
    wd(i,:) = [wx wy];
    % draw_box will paint over the text, so need to redraw it
    delete(tx);
    tx = text(x(i),y(i),str{i},'HorizontalAlignment','center',varargin{:});
    temp = [temp; tx ptc];
end;

if nargout>0, t = temp; end;


function [ptc, wx, wy] = draw_box(tx)
% Draws a box around a text object
sz = get(tx,'Extent');
% minka
wy = 1/2*sz(4);
wx = 1/2*sz(3);
x = sz(1)+sz(3)/2;
y = sz(2)+sz(4)/2;
ptc = patch([x-wx x+wx x+wx x-wx], [y+wy y+wy y-wy y-wy],'w');
set(ptc, 'FaceColor','w');



function args = argfilter(args,keep)
%ARGFILTER  Remove unwanted arguments.
% ARGFILTER(ARGS,KEEP), where ARGS = {'arg1',value1,'arg2',value2,...},
% returns a new argument list where only the arguments named in KEEP are
% retained.  KEEP is a character array or cell array of strings.

% Written by Tom Minka

if ischar(keep)
    keep = cellstr(keep);
end
i = 1;
while i < length(args)
    if ~ismember(args{i},keep)
        args = args(setdiff(1:length(args),[i i+1]));
    else
        i = i + 2;
    end
end
