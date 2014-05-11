%+
% NAME:
%  sub2indvec()
%
% VERSION:
%  $Id: sub2indvec.m 1067 2007-12-06 13:50:47Z ahjthiel $
%
% AUTHOR:
%  A. Thiel
%
% DATE CREATED:
%  10/2007
%
% AIM:
%  Convert multi dimensional matrix subscripts to linear index.
%
% DESCRIPTION:
%  This routine converts a set of multi dimensional matrix
%  subscripts to linear indices depending on the size of the
%  matrix. It is an addition to MATLAB's own sub2ind routine, with the
%  difference that the subscripts are passed to the routine as a vector
%  or matrix 
%  instead of separate arguments. This enables a more flexible handling
%  of matrixes 
%  with dimensions that are unknown at the time of programming.
%
% CATEGORY:
%  Support Routines<BR>
%  Arrays
%
% SYNTAX:
%* i=sub2indvec(sizeinfo,subs); 
%
% INPUTS:
%  sizeinfo:: The dimension information about the
%  matrix. <VAR>sizeinfo</VAR> is an n-element vector that specifies the
%  size of each array dimension, as returned by MATLAB's size() function.
%  subs:: A matrix or row vector consisting of the multidimensional
%  subscripts. If multiple subscript sets have to be converted into
%  multiple linear indices, the single rows of <VAR>subs</VAR> represent
%  the subscript sets belonging together, and the output has as many rows
%  as the <VAR>subs</VAR> matrix.
%
% OUTPUTS:
%  i:: The linear index or indices equivalent to the set of subscripts
%  <VAR>subs</VAR> 
%  for an array of size <VAR>sizeinfo</VAR>.
%
% PROCEDURE:
%  Just matrix multiplication.
%
% EXAMPLE:
%* >> m=rand(4,3);
%* >> sm=size(m);
%* >> i=sub2indvec(sm,[2,3])
%* i =
%*     10
%* >> m(i)
%* ans =
%*     0.3529
%* >> m(2,3)
%* ans =
%*     0.3529
%* >> i=sub2indvec(sm,[2,3; 1,2])
%* i =
%*     10
%*      5
%
% SEE ALSO:
%  <A>ind2subvec</A>, MATLAB's sub2ind and ind2sub. 
%-


function i=sub2indvec(sizeinfo,subs)
  
  [subrows,subcols]=size(subs);
  
  if (numel(sizeinfo)~=subcols)
    error('Number of dimensions in sizeinfo and subscript vector must agree.')
  end
  
  reduce=[zeros(subrows,1),ones(subrows,subcols-1)];
  
  i=(subs-reduce)*[1 cumprod(sizeinfo(1:end-1))].';