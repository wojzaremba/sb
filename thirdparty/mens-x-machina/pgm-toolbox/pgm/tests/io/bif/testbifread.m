classdef testbifread < TestCase
%TESTbifREAD bifREAD test cases

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

methods

function Obj = testbifread(name)
    
    clc;

    Obj = Obj@TestCase(name);

end

function testcmpwithdsl(Obj)

    import org.mensxmachina.pgm.bn.io.bif.bifread;
    import org.mensxmachina.pgm.bn.io.hugin.huginread;
    import org.mensxmachina.stats.cpd.cpdvartype;
    
    hugin_files = {'alarm_h.net'};
    bif_files = {'alarm.bif'};
    
    for k = 1:length(hugin_files)
        
        bnet_dsl = huginread(hugin_files{k});
        bnet_bif = bifread(bif_files{k});

        [~, varOrder_dsl] = sort(upper(bnet_dsl.varNames));
        [~, varOrder_bif] = sort(upper(bnet_bif.varNames));
        
        upper(bnet_dsl.varNames(varOrder_dsl))
        upper(bnet_bif.varNames(varOrder_bif))
       
        % assert equal graph
        assertEqual(bnet_dsl.structure(varOrder_dsl, varOrder_dsl), bnet_bif.structure(varOrder_bif, varOrder_bif));

        % assert equal varnames
        %assertEqual(bnet_dsl.varNames(varOrder_dsl), bnet_bif.varNames(varOrder_bif));

        % assert equal # levels
        %assertEqual(bnet_dsl.NumLevels(varOrder_dsl),
        %bnet_bif.NumLevels(varOrder_bif));

        cpd_dsl = bnet_dsl.cpd(varOrder_dsl);
        cpd_bif = bnet_bif.cpd(varOrder_bif);

        for i=1:length(bnet_dsl.varNames)

            i_dsl = varOrder_dsl(i);
            i_bif = varOrder_bif(i);

            varName = bnet_dsl.varNames{i_dsl};

%             if ismember(varName, {'BP', 'Catechol', 'CO', 'ExpCO2', 'Press', 'Shunt', 'VentLung'}) % permuted variables in bif compared to BIF and HUGIN
%                 continue;
%             end

%             if ismember(varName, {'HRBP', 'HREKG', 'HRSat', 'LVEDVolume', 'MinVol', 'PVSat', 'VentAlv', 'VentTube'}) % permuted probabilities in HUGIN compared to BIF and bif
%                 continue;
%             end

%             if ismember(varName, {'BP', 'Catechol', 'CO', 'Press', 'VentLung'}) % more permuted probabilities in HUGIN compared to BIF
%                 continue;
%             end
% 
%             if ismember(varName, {'Boundaries', 'CldShadeOth', 'CompPlFcst'}) % disagrees with hailfinder
%                 continue;
%             end
% 
%             if ismember(varName, {'BP', 'Catechol', 'CO', 'Press', 'VentLung'}) % dsl is wrong
%                 continue;
%             end
 
            if ismember(varName, {'Catechol'}) % permuted variables (or probabilities)
                continue;
            end
 
            if ismember(varName, {'Disconnect', 'FiO2', 'HR', 'HRBP', 'InsuffAnesth', 'PVSat', 'VentMach'}) % different probabilities
                continue;
            end
 
            if ismember(varName, {'ExpCO2', 'HREKG', 'HRSat', 'LVEDVolume', 'MinVol', 'MinVolSet', 'Press', 'StrokeVolume', 'VentAlv', 'VentLung', 'VentTube'}) % permuted probabilities
                continue;
            end
 
            % diabetes
            
            numParents = sum(bnet_dsl.structure(:, i_dsl));

            parentDims = 1:numParents;

            if numParents > 0

                [~, parents_dsl] = ismember(cpd_dsl{i}.varNames(cpd_dsl{i}.varTypes == cpdvartype.Explanatory), bnet_dsl.varNames);
                parents_dsl_in_ordered_dsl = arrayfun(@(parent_dsl) find(varOrder_dsl == parent_dsl, 1), parents_dsl);
                [~, parents_dsl_in_ordered_dsl_order] = sort(parents_dsl_in_ordered_dsl);
                parentDims_ordered_dsl = parentDims(parents_dsl_in_ordered_dsl_order);

                [~, parents_bif] = ismember(cpd_bif{i}.varNames(cpd_bif{i}.varTypes == cpdvartype.Explanatory), bnet_bif.varNames);
                parents_bif_in_ordered_bif = arrayfun(@(parent_bif) find(varOrder_bif == parent_bif, 1), parents_bif);
                [~, parents_bif_in_ordered_bif_order] = sort(parents_bif_in_ordered_bif);
                parentDims_ordered_bif = parentDims(parents_bif_in_ordered_bif_order);

                iP_dsl = permute(cpd_dsl{i}, [parentDims_ordered_dsl (numParents + 1)]);
                iP_bif = permute(cpd_bif{i}, [parentDims_ordered_bif (numParents + 1)]);
                
                varName
                %iP_dsl.values - iP_bif.values
                assertElementsAlmostEqual(iP_dsl.values, iP_bif.values, 'absolute', 1e-8);

            else
                
                varName
                
                assertElementsAlmostEqual(cpd_dsl{i}.values, cpd_bif{i}.values);

            end

        end
        
    end

end

end

end