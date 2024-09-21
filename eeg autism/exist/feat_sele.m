function [E, D] = feat_sele(E, D,selectedColumns)
E = selcol(E, selectedColumns);
D = selcol(selcol(D, selectedColumns)', selectedColumns);
end