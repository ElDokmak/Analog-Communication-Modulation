%--------------------------------------------------------------------------
%--------------------------1-READ AUDIO------------------------------------
%--------------------------------------------------------------------------
[y , fs] = audioread('eric.wav'); %read data(audio) from the file and returns sampled data(y) and sample rate fs
Y = fftshift(fft(y)); % getting fourir of the signal using fast fourier transform
t = linspace(0,length(y)/fs,length(y));
figure (1)
subplot(2,1,1) %PLOTTING OG AUDIO SIGNAL IN TIME DOMAIN
plot(t, y)
xlabel('time') , ylabel('original signal')
title('OG Signal in time domain')
f = linspace(-fs/2,fs/2,length(Y));
subplot(2,1,2) %PLOTTING OG AUDIO SIGNAL IN FREQ DOMAIN
plot(f,abs(Y))
xlabel('frequency') , ylabel('original signal')
title('OG Signal in frequency domain');

%------------2,3,4-IDEAL FILTER TO REMOVE FREQUENCES ABOVE 4 KHZ-----------
%--------------------------------------------------------------------------
Filter = rectpuls(f, 8000); %the ideal filter using rectpuls which returns a rectangular of width 8KHZ 
Filtered_Y = Y.* transpose(Filter); %transpose to be the same size then 
% the filter passes signal in the range of 4KHZ
t1=linspace(0,length(y)/fs,length(y));
figure (2)
subplot(2,1,1)  %plotting spectrum of the filtered signal
plot(f,abs(Filtered_Y))
title('Filtered signal in Frequency Domain')
Filtered_y = real(ifft(ifftshift(Filtered_Y)));%getting the filtered signal in time
% domain using inverse fourier transform
subplot(2,1,2) %plotting the filtered signal in time domain
plot(t1,Filtered_y); title('Filtered signal in time Domain');
%player = audioplayer(Filtered_y,fs);
%play(player)

%--------------------------------------------------------------------------
%---------3-Generate the NBFM----------------------------------------------
%--------------------------------------------------------------------------


Fc = 100000; %the carrier frequency
Fs = 5*Fc ; %the sampling rate
A = 10;%the amplitude of the carrier which it should be const in the angle modulation
% Resampling the signal to match the new sampling frequency
msg = resample(Filtered_y ,125,12); 
t_resample = linspace(0,length(msg)/Fs,length(msg)); % new time
kf = .1 ; %freq sensetivity ,it should be a very small number
msg_int = cumsum(msg); % geting the integrated message
carrier =  A .* cos(2*pi*Fc*t_resample);%equation of the carrier ,its amplitude A and carrier frequency Fc
carrier_1 =  A .* sin(2*pi*Fc*t_resample);
carr_hil = hilbert(carrier);%to get sin , making hilbert of the oscilator(carrier)
fm_msg =real( carrier - (kf .* carrier_1 .* msg_int.') ); %equation of the NBFM modulation which is
% "Acos(2*pi*Fc*t - A*Kf*integrated message*sin(2*pi*Fc*t))
msg_F = fftshift(fft(msg));%getting the message before modulation in frequency domain
fm_msg_F = fftshift(fft(fm_msg));%getting the message after modulation in frequency domain
f = linspace(-Fs/2,Fs/2,length(msg_F)); % new frequency
figure(3)
subplot(2,2,1) %plotting message in time domain after and before modulation
plot(t_resample,msg);
title('filtered signal in time domain before modulating');
subplot(2,2,2)
plot(t_resample,fm_msg);
title('modulated signal in time domain');
subplot(2,2,3) %plotting message in frequency domain after and before modulation
plot(f,abs(msg_F));
title('filtered signal in freq domain before modulating');
subplot(2,2,4)
plot(f,abs(fm_msg_F));
title('modulated signal in freq domain');


%--------------------------------------------------------------------------
%---------4-demodulation---------------------------------------------------
%--------------------------------------------------------------------------
%envelope detector
B=A*msg_int; %from the modulated signal equation envelope = sqr(A.^2 + A.^2 integrated msg.^2)
ED=sqrt(A.^2 + B.^2);
%extracting message from the envelope by using differentiator
% Differentiaing the signal decreases the length by 1 so we add zero at the
Received_msg = zeros(length(msg),1);
Received_msg(2:end) =(diff(ED));
Received_msg_f = fftshift(fft(Received_msg));
figure(4)
subplot(2,1,1) %plotting recived signal in time domain
plot(t_resample,Received_msg)
title('Message in time Domain')
subplot(2,1,2) %plotting recived signal in frequency domain
plot(f,abs(Received_msg_f));
title('Message in Frequency Domain')