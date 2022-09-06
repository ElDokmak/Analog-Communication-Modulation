%--------------------------------------------------------------------------
%--------------------------1-READ AUDIO------------------------------------
%--------------------------------------------------------------------------
[y , fs] = audioread('eric.wav');
Y = fftshift(fft(y)); 
t = linspace(0,length(y)/fs,length(y));
figure; subplot(4,4,1) 
plot(t, y); title('OG Signal in time domain');
f = linspace(-fs/2,fs/2,length(Y));
subplot(4,4,2) 
plot(f,abs(Y)); title('OG Signal in frequency domain');


%--------------------------------------------------------------------------
%------------2,3,4-IDEAL FILTER TO REMOVE FREQUENCES ABOVE 4 KHZ-----------
%--------------------------------------------------------------------------
Filter = rectpuls(f, 8000);
Filtered_Y = Y.* transpose(Filter);
t=linspace(0,length(y)/fs,length(y));
subplot(4,4,4)  
plot(f,abs(Filtered_Y)); title('Filtered signal in Frequency Domain');
Filtered_y = real(ifft(ifftshift(Filtered_Y)));
subplot(4,4,3)  
plot(t,Filtered_y); title('Filtered signal in time Domain');
player = audioplayer(Filtered_y,fs);
play(player)


%--------------------------------------------------------------------------
%-------------------4-MODULATION OF DSBSC----------------------------------
%--------------------------------------------------------------------------
%Modulation for DSBSC
RSMBLE_DSBSC = resample(Filtered_y , 125 , 12);
t_resample = linspace(0,length(RSMBLE_DSBSC)/500000,length(RSMBLE_DSBSC));
DSBSC_T = transpose(RSMBLE_DSBSC) .* cos(2*pi*100*1000*t_resample);
t1 = linspace(0,length(DSBSC_T)/fs,length(DSBSC_T));
DSBSC_F = fftshift(fft(DSBSC_T));
f_resample = linspace(-250000,250000,length(DSBSC_T));
subplot(4,4,5)
plot(t1 , DSBSC_T); title('Modulated signal in time domain (DSBSC)');
subplot(4,4,6)
plot(f_resample , abs(DSBSC_F)); title('Modulated signal in frequency domain (DSBSC)');
%Demodulation of DSBSC
DSBSC_demodulated_time = DSBSC_T .* cos(2*pi*100*1000*t_resample);
DSBSC_demodulated_freq = fftshift(fft(DSBSC_demodulated_time));


%--------------------------------------------------------------------------
%-----------------------------LSB------------------------------------------
%--------------------------------------------------------------------------
fc=100e3;
Fs=500e3;
Y1 = DSBSC_F;
Filter1 = rectpuls(f_resample, 200000);
LSB = Y1 .* Filter1;
F_1=linspace(-Fs/2,Fs/2,length(LSB));
subplot(4,4,7);plot(F_1,abs(LSB)); title('LSB in Frequency Domain');
T_lsb = real(ifft(ifftshift(LSB)));
T_lsb_DEMOD = T_lsb .* cos(2*pi*100*1000*t_resample);
F_lsb_DEMOD = fftshift(fft(T_lsb_DEMOD));
F_2 = linspace(-Fs/2,Fs/2,length(F_lsb_DEMOD));
subplot(4,4,8);plot(t1,T_lsb_DEMOD); title('LSB DEMOD in Time Domain');
subplot(4,4,9);plot(F_2,abs(F_lsb_DEMOD)); title('LSB DEMOD in Frequency Domain');
filter_2 = rectpuls(F_2 , 8000);
RES_F_lsb_DEMOD = F_lsb_DEMOD .* filter_2;
RES_T_lsb_DEMOD = real(ifft(ifftshift(RES_F_lsb_DEMOD)));
RES_T_lsb_DEMOD = resample(RES_T_lsb_DEMOD,12,125);
F_3=linspace(-Fs/2,Fs/2,length(RES_F_lsb_DEMOD));
subplot(4,4,10);plot(F_3,abs(RES_F_lsb_DEMOD)); title('RECIEVED MESSAGE AFTER DEMOD');
audiowrite('LSB_SSB_Received.wav',RES_T_lsb_DEMOD,fs);


%--------------------------------------------------------------------------
%-------------7-MODULATION OF DSBSC USING BUTTERWORTH FILTER---------------
%--------------------------------------------------------------------------
[B ,A] = butter(4,[fc-4000 fc]/(Fs/2));
Filterd_LSB_SSB_Butter = filter(B,A,DSBSC_T');
Filterd_LSB_SSB_Butter = Filterd_LSB_SSB_Butter';
Filterd_LSB_SSB_Butter_F = fftshift(fft(Filterd_LSB_SSB_Butter));
subplot(4,4,11);plot(f_resample,abs(Filterd_LSB_SSB_Butter_F)); title('Modulated Butter worth filter Signal');
%Reciving the Signal%
Filterd_LSB_SSB_Butter_R = Filterd_LSB_SSB_Butter .* cos(2*pi*100*1000*t_resample);
[B,A] =butter(4,4000/Fs/2);
Filterd_LSB_SSB_Butter_R = filter(B,A,Filterd_LSB_SSB_Butter_R);
Filterd_LSB_SSB_Butter_R_F = real(fftshift(fft(Filterd_LSB_SSB_Butter_R)));
subplot(4,4,12);plot(f_resample,abs(Filterd_LSB_SSB_Butter_R_F)); title('Recieved Butter worth filterd Signal');
Filterd_LSB_SSB_Butter_R =resample(Filterd_LSB_SSB_Butter_R,12,125);
audiowrite('Butter_ssb.wav',Filterd_LSB_SSB_Butter_R,fs);


%--------------------------------------------------------------------------
%--------------------8-SSBSC IN PRESENCE OF NOISE--------------------------
%--------------------------------------------------------------------------
%SNR = 0
NOISE_0 = awgn(T_lsb,0);
NOISE_0_T = NOISE_0 .* cos(2*pi*100*1000*t_resample);
NOISE_0_F = fftshift(fft(NOISE_0_T)); 
NOISE_0_F_R = NOISE_0_F .* filter_2;
NOISE_0_T_R = real(ifft(ifftshift(NOISE_0_F_R)));
subplot(4,4,13);plot(f_resample,abs(NOISE_0_F_R)); title('SNR=0 Recived freq domain');
NOISE_0_T_R = resample(NOISE_0_T_R,12,125);
audiowrite('SNR=0.wav',NOISE_0_T_R,fs);
%SNR = 10
NOISE_10 = awgn(T_lsb,10);
NOISE_10_T = NOISE_10 .* cos(2*pi*100*1000*t_resample);
NOISE_10_F = fftshift(fft(NOISE_10_T)); 
NOISE_10_F_R = NOISE_10_F .* filter_2;
NOISE_10_T_R = real(ifft(ifftshift(NOISE_10_F_R)));
subplot(4,4,14);plot(f_resample,abs(NOISE_10_F_R)); title('SNR=10 Recived freq domain');
NOISE_10_T_R = resample(NOISE_10_T_R,12,125);
audiowrite('SNR=10.wav',NOISE_10_T_R,fs);
%SNR = 30
NOISE_30 = awgn(T_lsb,30);
NOISE_30_T = NOISE_30 .* cos(2*pi*100*1000*t_resample);
NOISE_30_F = fftshift(fft(NOISE_30_T));
NOISE_30_F_R = NOISE_30_F .* filter_2;
NOISE_30_T_R = real(ifft(ifftshift(NOISE_30_F_R)));
subplot(4,4,15);plot(f_resample,abs(NOISE_30_F_R)); title('SNR=30 Recived freq domain');
NOISE_30_T_R = resample(NOISE_30_T_R,12,125);
audiowrite('SNR=30.wav',NOISE_30_T_R,fs);


%--------------------------------------------------------------------------
%--------------------------9-SSBTC-----------------------------------------
%--------------------------------------------------------------------------
A = 2*max(RSMBLE_DSBSC);
SSBTC_T = A* cos(2*pi*100*1000*t_resample) + transpose(RSMBLE_DSBSC).*cos(2*pi*100*1000*t_resample); 
SSBTC_F = fftshift(fft(SSBTC_T));
SSBTC_F = SSBTC_F .* Filter1;
SSBTC_T = real(ifft(ifftshift(SSBTC_F)));
%DEMODULATION
ED_SSBTC = abs(hilbert(SSBTC_T ));
ED_SSBTC_WITHOUT_DC = ED_SSBTC - A;
restored_SSBTC_T = resample(ED_SSBTC_WITHOUT_DC,12,125);
restored_SSBTC_F = fftshift(fft(restored_SSBTC_T));
t2 = linspace(0,length(restored_SSBTC_T)/fs,length(restored_SSBTC_T));
F_3 = linspace(-fs/2,fs/2,length(restored_SSBTC_F));
figure;subplot(2,2,1)
plot(t2,restored_SSBTC_T); title('SSB-TC modulated signal in time domaian after envelope detection and removing DC component');
subplot(2,2,3)
plot(F_3,abs(restored_SSBTC_F)); title('SSB-TC modulated signal in frequency domaian after envelope detection and removing DC component');
audiowrite('ED_SSBTC.wav',restored_SSBTC_T,fs);
%----------------------END-------------------------------------------------