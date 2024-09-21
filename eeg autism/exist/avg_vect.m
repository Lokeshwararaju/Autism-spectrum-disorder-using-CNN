function [acc_daq, avg_daq] = avg_vect(vectors)
acc_daq = zeros (size (vectors));
avg_daq = mean (vectors')';   
acc_daq = vectors - avg_daq * ones (1,size (vectors, 2));

