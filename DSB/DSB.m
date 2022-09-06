%--------------------------------------------------------------------------
%--------------------------1-READ AUDIO------------------------------------
%--------------------------------------------------------------------------
[y , fs] = audioread('eric.wav');
Y = fftshift(fft(y)); % to get spectrum of original signal
t = linspace(0,length(y)/fs,length(y));
figure; subplot(2,2,1) %PLOTTING OG AUDIO SIGNAL IN TIME DOMAIN
plot(t, y); title('OG Signal in time domain');
f = linspace(-fs/2,fs/2,length(Y));
subplot(2,2,2) %PLOTTING OG AUDIO SIGNAL IN FREQ DOMAIN
plot(f,abs(Y)); title('OG Signal in frequency domain');


%--------------------------------------------------------------------------
%------------2,3,4-IDEAL FILTER TO REMOVE FREQUENCES ABOVE 4 KHZ-----------
%--------------------------------------------------------------------------
Filter = rectpuls(f, 8000);
Filtered_Y = Y.* transpose(Filter); %transpose to be the same size
t=linspace(0,length(y)/fs,length(y));
subplot(2,2,4)  %PLOTTING FILTERED SIGNAL IN FREQ DOMAIN
plot(f,abs(Filtered_Y)); title('Filtered signal in Frequency Domain');
Filtered_y = real(ifft(ifftshift(Filtered_Y)));
subplot(2,2,3)  %PLOTTING FILTERED SIGNAL IN TIME DOMAIN
plot(t,Filtered_y); title('Filtered signal in time Domain');
player = audioplayer(Filtered_y,fs);
play(player)


%--------------------------------------------------------------------------
%-------------------5-MODULATION OF DSBSC AND DSBTC------------------------
%--------------------------------------------------------------------------
%Modulation for DSBSC
RSMBLE_DSBSC = resample(Filtered_y , 125 , 12);
t_resample = linspace(0,length(RSMBLE_DSBSC)/500000,length(RSMBLE_DSBSC));
DSBSC_T = transpose(RSMBLE_DSBSC).*cos(2*pi*100*1000*t_resample);
t1 = linspace(0,length(DSBSC_T)/fs,length(DSBSC_T));
DSBSC_F = fftshift(fft(DSBSC_T));
f_resample = linspace(-250000,250000,length(RSMBLE_DSBSC));
figure; subplot(2,2,1)
plot(t1 , DSBSC_T); title('Modulated signal in time domain (DSBSC)');
subplot(2,2,2)
plot(f_resample , abs(DSBSC_F)); title('Modulated signal in frequency domain (DSBSC)');
%Modulation of DSBTC
A = 2*max(RSMBLE_DSBSC);
DSBTC_T = A* cos(2*pi*100*1000*t_resample) + transpose(RSMBLE_DSBSC).*cos(2*pi*100*1000*t_resample);
t2 = linspace(0,length(DSBTC_T)/fs,length(DSBTC_T));
DSBTC_F = fftshift(fft(DSBTC_T));
subplot(2,2,3)
plot(t2 , DSBTC_T); title('Modulated signal in time domain (DSBTC)');
subplot(2,2,4)
plot(f_resample , abs(DSBTC_F)); title('Modulated signal in frequency domain (DSBTC)');


%--------------------------------------------------------------------------
%-------------------6,7-DETECTION USNIG ENVELOPE DETECTOR------------------
%--------------------------------------------------------------------------
%Demodulation for DSBSC using envelope detector
ED_DSBSC = abs(hilbert(DSBSC_T));
figure; subplot(4,3,1)
plot(t1 , ED_DSBSC); title('DSBSC detection using envelope detector in time domain');
restored_DSBSC_T = resample(ED_DSBSC,12,125);
restored_DSBSC_F = fftshift(fft(ED_DSBSC));
t4 = linspace(0,length(restored_DSBSC_T)/fs,length(restored_DSBSC_T));
F_4 = linspace(-fs/2,fs/2,length(restored_DSBSC_F));
subplot(4,3,3)
plot(t4,restored_DSBSC_T); title('Recieved DEMOD DSBSC after ED in Time domain');
subplot(4,3,5)
plot(F_4,abs(restored_DSBSC_F)); title('Recieved DEMOD DSBSC after ED in Freq domain');
audiowrite('Envlope_DSBSC.wav',restored_DSBSC_T,fs);

%Demodulation for DSBTC using envelope detector
ED_DSBTC = abs(hilbert(DSBTC_T));
ED_DSBTC_WITHOUT_DC = ED_DSBTC - A;
subplot(4,3,7)
plot(t2 , ED_DSBTC); title('DSBTC detection using envelope detector in time domain');
restored_DSBTC_T = resample(ED_DSBTC_WITHOUT_DC,12,125);
restored_DSBTC_F = fftshift(fft(ED_DSBTC_WITHOUT_DC));
t3 = linspace(0,length(restored_DSBTC_T)/fs,length(restored_DSBTC_T));
F_3 = linspace(-fs/2,fs/2,length(restored_DSBTC_F));
subplot(4,3,9)
plot(t3,restored_DSBTC_T); title('Recieved DEMOD DSBTC after ED and removing DC in Time domain');
subplot(4,3,11)
plot(F_3,abs(restored_DSBTC_F)); title('Recieved DEMOD DSBTC after ED and removing DC in Time domain');
audiowrite('Envlope_DSBTC.wav',restored_DSBTC_T,fs);


%--------------------------------------------------------------------------
%-------------------8-DEMODULATION IN PRESENCE OF NOISE--------------------
%--------------------------------------------------------------------------
filter_2 = rectpuls(f_resample , 8000);

NOISE_0 = awgn(DSBSC_T,0);
NOISE_0_T = NOISE_0 .* cos(2*pi*100*1000*t_resample);
NOISE_0_F = fftshift(fft(NOISE_0_T)); 
NOISE_0_F_R = NOISE_0_F .* filter_2;
NOISE_0_T_R = real(ifft(ifftshift(NOISE_0_F_R)));
figure; subplot(3,2,1);plot(t1,NOISE_0_T_R); title('SNR=0 Recived time domain');
subplot(3,2,2);plot(f_resample,abs(NOISE_0_F_R)); title('SNR=0 Recived freq domain');
NOISE_0_T_R = resample(NOISE_0_T_R,12,125);
audiowrite('SNR=0.wav',NOISE_0_T_R,fs);

NOISE_10 = awgn(DSBSC_T,10);
NOISE_10_T = NOISE_10 .* cos(2*pi*100*1000*t_resample);
NOISE_10_F = fftshift(fft(NOISE_10_T)); 
NOISE_10_F_R = NOISE_10_F .* filter_2;
NOISE_10_T_R = real(ifft(ifftshift(NOISE_10_F_R)));
subplot(3,2,3);plot(t1,NOISE_10_T_R); title('SNR=10 Recived time domain');
subplot(3,2,4);plot(f_resample,abs(NOISE_10_F_R)); title('SNR=10 Recived freq domain');
NOISE_10_T_R = resample(NOISE_10_T_R,12,125);
audiowrite('SNR=10.wav',NOISE_10_T_R,fs);

NOISE_30 = awgn(DSBSC_T,30);
NOISE_30_T = NOISE_30 .* cos(2*pi*100*1000*t_resample);
NOISE_30_F = fftshift(fft(NOISE_30_T));
NOISE_30_F_R = NOISE_30_F .* filter_2;
NOISE_30_T_R = real(ifft(ifftshift(NOISE_30_F_R)));
subplot(3,2,5);plot(t1,NOISE_30_T_R); title('SNR=30 Recived time domain');
subplot(3,2,6);plot(f_resample,abs(NOISE_30_F_R)); title('SNR=30 Recived freq domain');
NOISE_30_T_R = resample(NOISE_30_T_R,12,125);
audiowrite('SNR=30.wav',NOISE_30_T_R,fs);


%--------------------------------------------------------------------------
%-------------------9-10DEMODULATION IN PRESENCE OF NOISE------------------
%--------------------------------------------------------------------------
%DSBDC with freq error = 100.1 instead of 100 DISTORTION
carrier_error   =  cos(2*pi*100.1*1000*t_resample);
DSBSC_T_DEMOD_ERROR = DSBSC_T .* carrier_error;
DSBSC_F_DEMOD_ERROR =  fftshift(fft(DSBSC_T_DEMOD_ERROR ));
DSBSC_filtered_F_ERROR =  DSBSC_F_DEMOD_ERROR.*filter_2;
DSBSC_filtered_T_ERROR =  real(ifft(ifftshift(DSBSC_filtered_F_ERROR)));
%DSBSC_filtered_T_ERROR =  2*DSBSC_filtered_T_ERROR;
recieved_filtered_T_ERROR = resample(DSBSC_filtered_T_ERROR,12,125);
recieved_filtered_F_ERROR = fftshift(fft(recieved_filtered_T_ERROR ));
figure; subplot(4,2,1)
plot(t3,recieved_filtered_T_ERROR); title('RECIEVED DSBSC with Fc = 100.1K HZ in Time domain ');
f2 = linspace(-fs/2,fs/2,length(recieved_filtered_F_ERROR));
subplot(4,2,2)
plot(f2,abs(recieved_filtered_F_ERROR)); title('RECIEVED DSBSC with Fc = 100.1 KHZ in Frequency domain ');
audiowrite('FREQ_ERROR.wav',recieved_filtered_T_ERROR,fs);

%DSBDC with phase error = 20  ATTENUATION
carrier_error_2  =  cos(2*pi*100*1000*t_resample+(20*pi/180));
DSBSC_T_DEMOD_ERROR_2 = DSBSC_T .* carrier_error_2;
DSBSC_F_DEMOD_ERROR_2 =  fftshift(fft(DSBSC_T_DEMOD_ERROR_2));
DSBSC_filtered_F_ERROR_2 =  DSBSC_F_DEMOD_ERROR_2.*filter_2;
DSBSC_filtered_T_ERROR_2 =  real(ifft(ifftshift(DSBSC_filtered_F_ERROR_2)));
%DSBSC_filtered_T_ERROR_2 =  2*DSBSC_filtered_T_ERROR_2;
recieved_filtered_T_ERROR_2 = resample(DSBSC_filtered_T_ERROR_2,12,125);
recieved_filtered_F_ERROR_2 = fftshift(fft(recieved_filtered_T_ERROR_2));
subplot(4,2,3)
plot(t3,recieved_filtered_T_ERROR_2); title('DSBSC with phase error 20 in Time domain');
f3 = linspace(-fs/2,fs/2,length(recieved_filtered_F_ERROR_2));
subplot(4,2,4)
plot(f3,abs(recieved_filtered_F_ERROR_2)); title('DSBSC with phase error 20 in Frequency domain');
audiowrite('PAHSE_ERROR.wav',recieved_filtered_T_ERROR_2,fs);

%DSBDC with freq error = 100.1 instead of 100 AND SNR = 30
carrier_error   =  cos(2*pi*100.1*1000*t_resample);
DSBSC_T_DEMOD_ERROR_SNR30 = NOISE_30 .* carrier_error;
DSBSC_F_DEMOD_ERROR_SNR30 =  fftshift(fft(DSBSC_T_DEMOD_ERROR_SNR30 ));
DSBSC_filtered_F_ERROR_SNR30 =  DSBSC_F_DEMOD_ERROR_SNR30.*filter_2;
DSBSC_filtered_T_ERROR_SNR30 =  real(ifft(ifftshift(DSBSC_filtered_F_ERROR_SNR30)));
%DSBSC_filtered_T_ERROR_SNR30 =  2*DSBSC_filtered_T_ERROR_SNR30;
recieved_filtered_T_ERROR_SNR30 = resample(DSBSC_filtered_T_ERROR_SNR30,12,125);
recieved_filtered_F_ERROR_SNR30 = fftshift(fft(recieved_filtered_T_ERROR_SNR30 ));
subplot(4,2,5)
plot(t3,recieved_filtered_T_ERROR_SNR30); title('RECIEVED DSBSC with Fc = 100.1KHZ and SNR=30 in Time domain');
f2 = linspace(-fs/2,fs/2,length(recieved_filtered_F_ERROR_SNR30));
subplot(4,2,6)
plot(f2,abs(recieved_filtered_F_ERROR_SNR30)); title('RECIEVED DSBSC with Fc = 100.1 KHZ and SNR=30 in Frequency domain ');
audiowrite('FREQ_ERROR_SNR=30.wav',recieved_filtered_T_ERROR_SNR30,fs);

%DSBDC with phase error = 20 AND SNR = 30
carrier_error_2  =  cos(2*pi*100*1000*t_resample+(20*pi/180));
DSBSC_T_DEMOD_ERROR_2_SNR30 = NOISE_30 .* carrier_error_2;
DSBSC_F_DEMOD_ERROR_2_SNR30 =  fftshift(fft(DSBSC_T_DEMOD_ERROR_2_SNR30));
DSBSC_filtered_F_ERROR_2_SNR30 =  DSBSC_F_DEMOD_ERROR_2_SNR30.*filter_2;
DSBSC_filtered_T_ERROR_2_SNR30 =  real(ifft(ifftshift(DSBSC_filtered_F_ERROR_2_SNR30)));
%DSBSC_filtered_T_ERROR_2_SNR30 =  2*DSBSC_filtered_T_ERROR_2_SNR30;
recieved_filtered_T_ERROR_2_SNR30 = resample(DSBSC_filtered_T_ERROR_2_SNR30,12,125);
recieved_filtered_F_ERROR_2_SNR30 = fftshift(fft(recieved_filtered_T_ERROR_2_SNR30));
subplot(4,2,7)
plot(t3,recieved_filtered_T_ERROR_2_SNR30); title('DSBSC with phase error 20 and SNR=30 in Time domain');
f3 = linspace(-fs/2,fs/2,length(recieved_filtered_F_ERROR_2_SNR30));
subplot(4,2,8)
plot(f3,abs(recieved_filtered_F_ERROR_2_SNR30)); title('DSBSC with phase error 20 and SNR=30 in Frequency domain');
audiowrite('PAHSE_ERROR_SNR30.wav',recieved_filtered_T_ERROR_2_SNR30,fs);
%-----------------------END------------------------------------------------