function [nll] = GLoss(XX,Xy,yy,w)
    nll = w'*XX*w - 2*w'*Xy + yy;
end