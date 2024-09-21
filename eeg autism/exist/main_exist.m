clc;
close all;
clear all;
warning off all;
[filename,pathname]=uigetfile('*.txt;','Select EEG ref Signal');
file=strcat(pathname,filename);
input_signals=load(file);                              % loading 2-channel input_signals
ts_seq=2;                             % sampling time period
database_length=5;
Sampl_bit = 16; 
over_lap = 100;
window_length = 256;
cutoff_daq=500;            %                 % sampling frequency

[n,m]=size(input_signals);                                   % obtain size of input_signals

t=(1:n)*ts_seq;                       % generates time vector
yl=input_signals(:,1)';

figure;
plot(t,yl, 'b-')                            
grid on;axis on
   leng = length(yl);
    frame_calc = floor((leng - window_length) / over_lap) + 1;
       for ii = 1:window_length
    for j = 1:frame_calc
        Mel(ii, j) = yl(((j - 1) * over_lap) + ii);
    end
    end
     ii=1:256;
figure;plot(ii,Mel);
grid on;axis on
fs=360;
N = length(yl);      % Length of the loaded sample
ti= (0:N-1)/fs;
%%%%%%%%%%%%%% Bandpass digital filter design %%%%%%%%%%%%%%%%%%%%%%
[b,a]=cheby1(6,1,[0.05,.25]);  % Bandpass digital filter design         
z = filter(b,a,yl);
hold on
figure
plot(ti,z);
title('Bandpass filtering');
grid on;axis on
dz = z-mean(z);
dz = dz/max(abs(dz));
hold on
figure;
plot(ti,dz);
xlabel('z'), title('Normalizeing Filter');
grid on;axis on
an = abs(dz);
figure;
plot(ti,an);
ylabel('Amp Daq');
grid on;axis on
coeffient = hamming(window_length);
figure;plot(coeffient);
grid on;axis on
    Mel_revised = diag(coeffient) * Mel;
    figure;
    plot(Mel_revised);
    grid on;
    axis on;
   [S1,F,T] = spectrogram(input_signals(:,1),chebwin(128,100),0,cutoff_daq);

S1=abs(S1);
figure;
subplot(131);
plot(S1);
grid on
axis on
subplot(132);
plot(F);
grid on
axis on
subplot(133);
plot(T);
grid on
axis on
    [input_signal, input_avg] = avg_vect(yl);
    
[Dim, NumOfSampl] = size(input_signal);
eig_vect          = 1;      
eig_vect_end           = Dim;
% [evalu, dist_vet]=pca_mat(input_signal, eig_vect, eig_vect_end, modurater);
[evalu, dist_vet,sele_para]=pca_mat(input_signal, eig_vect, eig_vect_end);
[Ed,Dd]=feat_sele(evalu, dist_vet,sele_para);
trfeat=[Ed,Dd];
lab=[F(1,:),T(:,1)];
[result,parr] = svm_classify(trfeat',lab,trfeat');
if result>1
    msgbox('Autism');
 else
    msgbox('Normal');
end
fprintf('Accuracy = %f\n',parr(1));
fprintf('Specifity = %f\n',parr(2));
fprintf('Sensitivity = %f\n',parr(3));
fprintf('Precision = %f\n',parr(4));