classdef testbiographbayesnetviewer < TestCase
%TESTBIOGRAPHBAYESNET BIOGRAPHBAYESNET test cases

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Probabilistic Graphical Model
% Toolbox.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is free software:
% you can redistribute it and/or modify it under the terms of the GNU
% General Public License alished by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is distributed in
% the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
% the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Probabilistic Graphical Model Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

properties

    BNet
    Viewer

end

methods

function Obj = testbiographbayesnetviewer(name)

    clc;

    import org.mensxmachina.pgm.bn.viewers.biograph.biographbayesnetviewer;

    Obj = Obj@TestCase(name);

    Obj.BNet = org.mensxmachina.pgm.bn.tabular.sprinkler;
    Obj.Viewer = biographbayesnetviewer(Obj.BNet);

end

function testview(Obj)

    Obj.Viewer.viewbayesnet();

end

function testviewbayesnetstructure(Obj)

    Obj.Viewer.viewbayesnetstructure();

end

function testviewbayesnetskeleton(Obj)

    Obj.Viewer.viewbayesnetskeleton();

end

end

end