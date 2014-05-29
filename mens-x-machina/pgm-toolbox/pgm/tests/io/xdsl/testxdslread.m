classdef testxdslread < TestCase
%TESTXDSLREAD XDSLREAD test cases

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

function Obj = testxdslread(name)
    
    clc;

    Obj = Obj@TestCase(name);

end

function testcmpwithbif(Obj)
    
    clc;

    import org.mensxmachina.pgm.bn.io.xdsl.xdslread;
    import org.mensxmachina.pgm.bn.io.bif.bifread;
    import org.mensxmachina.stats.cpd.cpdvartype;

    bnet_bif = bifread('alarm.bif');
    bnet_xdsl = xdslread('alarm.xdsl', true);

    [~, varOrder_bif] = sort(bnet_bif.varNames);
    [~, varOrder_xdsl] = sort(bnet_xdsl.varNames);
        
    upper(bnet_bif.varNames(varOrder_bif))
    upper(bnet_xdsl.varNames(varOrder_xdsl))
    
    G_ordered_bif = bnet_bif.structure(varOrder_bif, varOrder_bif);
    G_ordered_xdsl = bnet_xdsl.structure(varOrder_xdsl, varOrder_xdsl);

    assertEqual(G_ordered_bif, G_ordered_xdsl);
    %assertEqual(bnet_bif.NumLevels(varOrder_bif), bnet_xdsl.NumLevels(varOrder_xdsl));

    cpd_bif = bnet_bif.cpd(varOrder_bif);
    cpd_xdsl = bnet_xdsl.cpd(varOrder_xdsl);

    for i=1:length(bnet_bif.varNames)

        i_bif = varOrder_bif(i);
        i_xdsl = varOrder_xdsl(i);

        varName = bnet_bif.varNames{i_bif};

%         if ismember(varName, {'HREKG', 'HRSAT', 'PVSAT'}) % bifread is wrong 
%             continue;
%         end
%         
%         if ismember(varName, {'VENTALV'}) % small difference
%             continue;
%         end
% 
%         if ismember(varName, {'BP', 'CATECHOL', 'CO', 'EXPCO2', 'PRESS', 'SHUNT', 'VENTLUNG'}) % permuted variables in XDSL compared to BIF
%             continue;
%         end
% 
%         if ismember(varName, {'EXPCO2'}) % bifread is also wrong
%             continue;
%         end
% 
%         if ismember(varName, {'PRESS', 'VENTLUNG'}) % small difference also
%             continue;
%         end

        if ismember(varName, {'HRBP', 'HREKG', 'HRSAT', 'LVEDVOLUME', 'MINVOL', 'PVSAT', 'STROKEVOLUME', 'VENTALV', 'VENTTUBE'}) % permuted probabilities in BIF compared to XDSL
            continue;
        end
 
        if ismember(varName, {'SAO2', 'EXPCO2', 'PRESS', 'CATECHOL', 'VENTLUNG'}) % permuted variables in XDSL compared to BIF
            continue;
        end

        numParents = sum(bnet_bif.structure(:, i_bif));

        parentDims = 1:numParents;

        if numParents > 0
            
            varName
            
            [~, parents_bif] = ismember(cpd_bif{i}.varNames(cpd_bif{i}.varTypes == cpdvartype.Explanatory), bnet_bif.varNames);
            parents_bif_in_ordered_bif = arrayfun(@(parent_bif) find(varOrder_bif == parent_bif, 1), parents_bif);
            [~, parents_bif_in_ordered_bif_order] = sort(parents_bif_in_ordered_bif);
            parentDims_ordered_bif = parentDims(parents_bif_in_ordered_bif_order);

            [~, parents_xdsl] = ismember(cpd_xdsl{i}.varNames(cpd_xdsl{i}.varTypes == cpdvartype.Explanatory), bnet_xdsl.varNames);
            parents_xdsl_in_ordered_xdsl = arrayfun(@(parent_xdsl) find(varOrder_xdsl == parent_xdsl, 1), parents_xdsl);
            [~, parents_xdsl_in_ordered_xdsl_order] = sort(parents_xdsl_in_ordered_xdsl);
            parentDims_ordered_xdsl = parentDims(parents_xdsl_in_ordered_xdsl_order);
            
            % assuming that the last variable is the response variable!
            permuted_cpd_bif = permute(cpd_bif{i}, [parentDims_ordered_bif (numParents + 1)]);
            permuted_cpd_xdsl = permute(cpd_xdsl{i}, [parentDims_ordered_xdsl (numParents + 1)]);
            
            assertElementsAlmostEqual(permuted_cpd_bif.values, permuted_cpd_xdsl.values);

        else
            
            assertElementsAlmostEqual(cpd_bif{i}.values, cpd_xdsl{i}.values);

        end

    end

end

function testcmpwithdsl(Obj)

    import org.mensxmachina.pgm.bn.io.xdsl.xdslread;
    import org.mensxmachina.pgm.bn.io.hugin.huginread;
    import org.mensxmachina.stats.cpd.cpdvartype;
    
    hugin_files = {'alarm_h.net', 'Diabetes.net', 'hailfinder_h.net', 'Link.net', 'Mildew.net', 'Water.net'};
    xdsl_files = {'alarm.xdsl', 'diabetes.xdsl', 'hailfinder.xdsl', 'link.xdsl', 'Mildew.xdsl', 'Water.xdsl'};
    useNodeNamesAsresponseVarNames = [true false true false false false];
    
    % hugin2dsl can't read Barley, powerplant
    
    for k = 1:length(hugin_files)
        
        bnet_dsl = huginread(hugin_files{k});
        bnet_xdsl = xdslread(xdsl_files{k}, useNodeNamesAsresponseVarNames(k));

        [~, varOrder_dsl] = sort(upper(bnet_dsl.varNames));
        [~, varOrder_xdsl] = sort(upper(bnet_xdsl.varNames));
        
        upper(bnet_dsl.varNames(varOrder_dsl))
        upper(bnet_xdsl.varNames(varOrder_xdsl))
       
        % assert equal graph
        assertEqual(bnet_dsl.structure(varOrder_dsl, varOrder_dsl), bnet_xdsl.structure(varOrder_xdsl, varOrder_xdsl));

        % assert equal varnames
        %assertEqual(bnet_dsl.varNames(varOrder_dsl), bnet_xdsl.varNames(varOrder_xdsl));

        % assert equal # levels
        %assertEqual(bnet_dsl.NumLevels(varOrder_dsl),
        %bnet_xdsl.NumLevels(varOrder_xdsl));

        cpd_dsl = bnet_dsl.cpd(varOrder_dsl);
        cpd_xdsl = bnet_xdsl.cpd(varOrder_xdsl);

        for i=1:length(bnet_dsl.varNames)

            i_dsl = varOrder_dsl(i);
            i_xdsl = varOrder_xdsl(i);

            varName = bnet_dsl.varNames{i_dsl};

%             if ismember(varName, {'BP', 'Catechol', 'CO', 'ExpCO2', 'Press', 'Shunt', 'VentLung'}) % permuted variables in XDSL compared to BIF and HUGIN
%                 continue;
%             end

%             if ismember(varName, {'HRBP', 'HREKG', 'HRSat', 'LVEDVolume', 'MinVol', 'PVSat', 'VentAlv', 'VentTube'}) % permuted probabilities in HUGIN compared to BIF and XDSL
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
 
            if ismember(varName, {'SaO2', 'ExpCO2', 'Press', 'Catechol'}) % permuted variables in XDSL compared to HUGIN
                continue;
            end

            if ismember(varName, {'PVSat', 'Disconnect', 'FiO2', 'HR', 'InsuffAnesth', 'MinVolSet', 'VentMach'}) % different source probabilities
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

                [~, parents_xdsl] = ismember(cpd_xdsl{i}.varNames(cpd_xdsl{i}.varTypes == cpdvartype.Explanatory), bnet_xdsl.varNames);
                parents_xdsl_in_ordered_xdsl = arrayfun(@(parent_xdsl) find(varOrder_xdsl == parent_xdsl, 1), parents_xdsl);
                [~, parents_xdsl_in_ordered_xdsl_order] = sort(parents_xdsl_in_ordered_xdsl);
                parentDims_ordered_xdsl = parentDims(parents_xdsl_in_ordered_xdsl_order);

                % assuming that the last variable is the response variable!
                iP_dsl = permute(cpd_dsl{i}, [parentDims_ordered_dsl (numParents + 1)]);
                iP_xdsl = permute(cpd_xdsl{i}, [parentDims_ordered_xdsl (numParents + 1)]);
                
                varName
                %iP_dsl.values - iP_xdsl.values
                assertElementsAlmostEqual(iP_dsl.values, iP_xdsl.values, 'absolute', 1e-8);

            else

                assertElementsAlmostEqual(cpd_dsl{i}.values, cpd_xdsl{i}.values);

            end

        end
        
    end

end

end

end