function [G, F, H] = sachsTrueDAG()

d = 11;
G = zeros(d,d);
raf= 1; mek12= 2; plcy= 3; pip2= 4; pip3= 5; erk= 6;
akt= 7; pka= 8; pkc= 9; p38= 10; jnk=11;

G(pip3,[akt plcy pip2])=1;
G(plcy,[pkc pip2])=1;
G(pip2,pkc)=1;
G(pkc,[mek12 raf p38 pka jnk])=1;
G(pka,[raf p38 mek12 erk akt jnk])=1;
G(raf,mek12)=1;
G(mek12,erk)=1;
G(erk,akt)=1;

g06976 = 1; aktinh = 2;  psitect = 3; u0126 = 4; b2camp = 5; pma = 6;
e = 6;
F = zeros(e,d);
% activators
F(pma,pkc)=1;
F(b2camp,pka)=1;
% inhibitors
F(g06976,pkc)=1;
F(aktinh,akt)=1;
F(psitect,pip2)=1;
F(u0126,mek12)=1;

%H = [F zeros(e,d);
%     G zeros(d,d)];

H = [zeros(e,e) F;
     zeros(d,e) G];


