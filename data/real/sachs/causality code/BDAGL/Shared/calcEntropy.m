function ent = calcEntropy( pr )

pr(pr==0)=1;
ent = -sum(sum(log(pr).*pr));