function mkMex(dirName, doRecurse)

if nargin<1
	dirName = '.';
end

if nargin<2
	doRecurse = false;
end

cd(dirName);
src = dir();
for fi=1:length(src)
	[pathstr name ext] = fileparts(src(fi).name);
	if strcmp(ext, '.c')
		mexName = fullfile('.', [name '.' mexext]);
		if ~exist( mexName , 'file' )
			mex(src(fi).name);
		end
	end
	
	if doRecurse && src(fi).isDir
		mkMex(name, doRecurse);
	end
end
cd('..');