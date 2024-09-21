clc;
close all;
clear all;
warning off all;
[filename pathname]=uigetfile('*.txt;','Select EEG ref Signal');
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
yl=input_signals(:,1);

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
    [c,l]=wavedec(Mel_revised,4,'db4');
  ca1=appcoef(c,l,'db4',1);
  ca2=appcoef(c,l,'db4',2);
  ca3=appcoef(c,l,'db4',3);
  ca4=appcoef(c,l,'db4',4);
  
  figure;
  plot(c),title('Decomposed'),grid on
  figure;
  subplot(2,2,1)
  plot(ca1);
  title('1st level reconstructed'),grid on
   subplot(2,2,2)
  %figure;
  plot(ca2);
  title('2nd level reconstructed'),grid on
  subplot(2,2,3)
 %  figure;
  plot(ca3);
  title('3rd level reconstructed'),grid on
    subplot(2,2,4)
   % figure;
  plot(ca4);
  title('4th level reconstructed'),grid on
    for k = 1:frame_calc
    framing(:,k) = fft(Mel_revised(:, k));
    end
    figure;
    subplot(211);
    plot(ii,real(framing));
      subplot(212);
    plot(ii,imag(framing));
    grid on;axis on
    an = abs(Mel_revised);
    en = Mel_revised.^2;
figure;
plot(en);
ylabel('Signl Energy');
grid on;axis on
sen = -an.*log(an);
sn = -en.*log(en);
figure;
subplot(211)
plot(abs(sn));
grid on;axis on
subplot(212)
plot(abs(sen));
title('Entropy');
grid on;axis on
 zzz=1;
GLCM_mat = graycomatrix(yl,'Offset',[2 0;0 2]);
     
     GLCMstruct = Computefea(GLCM_mat,0);
     
     v1=GLCMstruct.contr(1);

     v2=GLCMstruct.corrm(1);

     v5=GLCMstruct.dissi(1);

     v6=GLCMstruct.energ(1);

     v7=GLCMstruct.entro(1);

     v8=GLCMstruct.homom1(1);

     v9=GLCMstruct.homop(1);

     v10=GLCMstruct.maxpr(1);

     v11=GLCMstruct.sosvh(1);

     v12=GLCMstruct.autoc(1);
     
     magg1 = [v1,v2,v5,v6,v7,v8,v9,v10];
     maggni1=v7;
     somenames={'Contrast','Corre','RMS','Energy','Entropy','Homogeneity','Mean','SD'};
     figure;
     bar(magg1);
     set(gca,'xticklabel',somenames);
     xlabel('Parameters');
     ylabel('Values');
     title('Fetaure extracted');
     grid on;axis on;
[maggnil,para] = complex_network(magg1);
if maggni1>.79
    msgbox('Autism');
 else
    msgbox('Normal');
end
fprintf('Accuracy = %f\n',para(1));
fprintf('Specifity = %f\n',para(2));
fprintf('Sensitivity = %f\n',para(3));
fprintf('Precision = %f\n',para(4));