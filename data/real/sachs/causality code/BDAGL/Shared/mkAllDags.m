function Gs = mkAllDags(N, k)
% MK_ALL_DAGS generate all DAGs on N variables
% k is the optional maximum inbound
% G = mkAllDags(N)

if nargin<2
    fname = sprintf('Cache/DAGS%d.mat', N);
    k = 0;
else
    fname = sprintf('Cache/DAGS%d_%d.mat', N, k);
end

if exist(fname, 'file')
	S = load(fname, '-mat');
	fprintf('loading %s\n', fname);
	Gs = S.Gs;
	return;
end

global HT;


seed = zeros(N);
HT = java.util.Hashtable(2^22);
HT.put(dag2char(seed), 0);

mkAllDagsHelper(seed, zeros(size(seed)), k);

keys = HT.keys;

nb = ceil( (N^2-N)/8 );

Gs = zeros( HT.size(), nb , 'uint16');

j = 1;
while keys.hasMoreElements()
	Gs(j,:) = keys.nextElement();
	j = j+1;
end

if ~exist(fname,'file')
    fprintf('mkAllDags: saving to %s\n', fname);
    save(fname, 'Gs', '-v6');
end

clear HT;

function mkAllDagsHelper(G0, A, k)

global HT;

n = length(G0);
% [I,J] = find(G0); % I(k), J(k) is the k'th edge
% E = length(I);    % num edges present in G0

Gbar = ~G0;  % Gbar(i,j)=1 iff there is no i->j edge in G0
Gbar = setdiag(Gbar, 0); % turn off self loops

GbarL = Gbar-A;
[IbarL, JbarL] = find(GbarL);  % I(k), J(k) is the k'th legal edge to add
EbarL = length(IbarL);

bar_edge_ndx = find(GbarL);

Grep = repmat(G0(:), 1, EbarL); % each column is a copy of G0
ndx = subv2ind(size(Grep), [bar_edge_ndx(:) (1:EbarL)']);
Grep(ndx) = 1;
Gadd = reshape(Grep, [n n EbarL]);

for i=1:EbarL
	key = dag2char(Gadd(:,:,i));
	
    if k>0
        tooManyParents = max(sum( Gadd(:,:,i) ))>k ;
    else
        tooManyParents = false;
    end
    
	if ~HT.containsKey(key) && ~tooManyParents
		HT.put(key, 0);
		Ap = do_addition(A, IbarL(i), JbarL(i) );
		mkAllDagsHelper(Gadd(:,:,i), Ap, k);
	end
end

function A = do_addition(A, i, j)

A(j,i) = 1; % i is an ancestor of j
anci = find(A(i,:));
if ~isempty(anci)
	A(j,anci) = 1; % all of i's ancestors are added to Anc(j)
end
ancj = find(A(j,:));
descj = find(A(:,j));
if ~isempty(ancj)
	for k=descj(:)'
		A(k,ancj) = 1; % all of j's ancestors are added to each descendant of j
	end
end

function A = update_row(A, j, dag)

% We compute row j of A
A(j, :) = 0;
ps = parents(dag, j);
if ~isempty(ps)
	A(j, ps) = 1;
end
for k=ps(:)'
	anck = find(A(k,:));
	if ~isempty(anck)
		A(j, anck) = 1;
	end
end