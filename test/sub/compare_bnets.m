function compare_bnets(bnet1, bnet2)
% compares everything except CPDs

names = fieldnames(bnet1);

assert(isequal(names, fieldnames(bnet2)));

for i = 1:length(names)
  if strcmpi(names{i}, 'CPD')
    continue;
  else
      command = sprintf('assert(isequal(bnet1.%s, bnet2.%s));',names{i}, names{i});
      eval(command);
  end
end
