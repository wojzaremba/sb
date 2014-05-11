%+
% NAME:
%  ind2subvec()
%
% VERSION:
%  $Id: ind2subvec.m 1067 2007-12-06 13:50:47Z ahjthiel $
%
% AUTHOR:
%  A. Thiel
%
% DATE CREATED:
%  10/2007
%
% AIM:
%  Convert linear array index to multi dimensional matrix subscripts.
%
% DESCRIPTION:
%  ind2subvec() is used to determine the equivalent subscript values
%  corresponding to a given linear index into an array. It works analogous
%  to MATLAB's own ind2sub() routine, with the difference that the resulting
%  subscripts are returned within a single vector or matrix instead of multiple
%  output variables. This enables a more flexible handling of matrixes
%  with dimensions that are unknown at the time of programming.
%
% CATEGORY:
%  Support Routines<BR>
%  Arrays
%
% SYNTAX:
%* out = ind2subvec(siz,ndx); 
%
% INPUTS:
%  siz:: The dimension information about the
%  matrix. <VAR>siz</VAR> is an n-element vector that specifies the
%  size of each array dimension, as returned by MATLAB's size() function.
%  ndx:: The linear indices into the matrix. Multiple indices can be
%  converted by passing them as a row vector.
%
% OUTPUTS:
%  result:: A row vector or two dimensional matrix containing the
%  n-dimensional array 
%  subscripts  
%   equivalent to <VAR>ndx</VAR> for an array of size <VAR>siz</VAR>. If
%   <VAR>ndx</VAR> is an m-element row vector, the result has m rows and
%   n columns.
%
% PROCEDURE:
%  Same as MATLAB's ind2sub() with a different output format.
%
% EXAMPLE:
%* >> m=rand(4,3);
%* >> sm=size(m);
%* >> s=ind2subvec(sm,5)
%* s =
%*     1     2
%* >> m(5)
%* ans =
%*     0.9355
%* >> m(s(1),s(2))
%* ans =
%*     0.9355
%* >> s=ind2subvec(sm,[5 6 10])
%* s =
%*     1     2
%*     2     2
%*     2     3
%
% SEE ALSO:
%  <A>sub2indvec</A>, MATLAB's ind2sub and sub2ind. 
%-

function out = ind2subvec(siz,ndx)
  
  n = length(siz);

  k = [1 cumprod(siz(1:end-1))];
  ndx = ndx - 1;
  out=zeros(length(ndx),n);
  for i = n:-1:2
    out(:,i) = floor(ndx/k(i))+1;
    ndx = rem(ndx,k(i));
  end % for
  out(:,1)=ndx+1;
