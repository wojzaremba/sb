function c = combinations(set,k)

if k==0
    c = [NaN];
elseif k<0
    error('k should be >= 0')
else
    c = combntns(set, k);
end
  
