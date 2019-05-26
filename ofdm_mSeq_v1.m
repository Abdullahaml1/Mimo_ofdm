
clear;
clc;


%-------variables--------------------------------
buffer_lenght = 512;
maxDelaySpreadInSamples = (.2e-6) * 128 /312500; 
M = 16;
SNR_db = 0:3:30;
SNR = 10.^(SNR_db./10);
framesNum = 1000;
channel = ApplyFading(1, 1, 5);
%% Gnearting M-Sequnce

mSeq = mseq( 2, 8, 0, 2) ;
%% Pilot
pilot = mSeq(1:ceil(buffer_lenght/ 4));
BER = [];


genBinary = randi([0 1], buffer_lenght,framesNum); % gnerating random data

sympolMap = reshape(genBinary, [4, ceil(buffer_lenght/4) * framesNum])' ;  %reshaping colum data to (4 x N) in order
                                                                         %to be converted to decimal
                                                                         
                                                             
txDecimalVector = bi2de(sympolMap, 'left-msb');  %converting every row ob bunary to decimal 

%----------reshaping to buffer_lenfht x framesNum

txDecimalMatrix = reshape(txDecimalVector, [ceil(buffer_lenght/4), framesNum]);
% ---------------------QAM 16 modulation --------------
txQamDate = qammod(txDecimalMatrix, M);  %qam modulating and normalizating by factor 1/sqrt(10)
% scatterplot(qamDate(:, 2));
% grid on;


%-----------------applying ifft to every colum-------------------
qamIfftData = ifft(txQamDate);
pilotIfft = ifft(pilot);


%--------adding cyclic perfix of size 32 ---------------------------
txCyclicQamIfftData = [qamIfftData; qamIfftData(1:32, :)];  %adding the last 32 elment at the buttom of the 
                                                        %colum vector
pilotCyclic = [pilotIfft ; pilotIfft(1:32)];                                                        
                             
                          
%----------------- Fading the channel--------------------------- 
% size_cyclic = size(txCyclicQamIfftData);
% txCyclicQamIfftData = ones(size_cyclic);
channelData = conv2(channel, 1, txCyclicQamIfftData, 'same'); %convoluting every colum with the channel
pilitChannel = conv(pilotCyclic, channel, 'same');

for snr = SNR
   %-----------------addin noise ------------------------------
data_size = size(channelData);
channelDataNoise = channelData + (randn(data_size) ./sqrt(2*snr) +randn(data_size) ./sqrt(2*snr)*1j);



%------------------removing cyclic-------------------
rxCyclicFree = channelDataNoise([1: 128], :);
pilotCyclicFree = pilitChannel([1: 128]);


%-----------------Applying FFT-------------------------
rxFft = fft(rxCyclicFree);
pilotFfft = fft(pilotCyclicFree);


%--------------equalization------------------------------
channelEffect = pilot ./pilotFfft;
rxChannelFree = rxFft .* channelEffect;


%-------------Qam demodulatio-------------
rxDecimalMatrix = qamdemod(rxChannelFree, M);

%-----------------reshaping into a colum vector----------------
rxDecimalVector = reshape(rxDecimalMatrix, [ceil(buffer_lenght/4) * framesNum, 1]);

%-------------converting from decimal to binary colum vector----------
rxBinaryMatrix = de2bi(rxDecimalVector, 'left-msb');
rxBinaryMatrix = reshape(rxBinaryMatrix', [buffer_lenght, framesNum]);


%-----------------Bit Error Rate-----------------
correctElments = sum(rxBinaryMatrix == genBinary, 'All');
ber = (buffer_lenght * framesNum - correctElments)/ (buffer_lenght * framesNum);
BER = [BER, ber]; %appending the last ber value to the BER row vector

    
end

BER_mSeq = BER;
save ('BER_mSeq.mat', 'BER_mSeq') ;
%% Plotting

figure;
semilogy(SNR_db, BER);
grid on;
title("BER vs SNR");
ylabel("BER (Bit Error Rate)");
xlabel("SNR (Signal to Noise Ratio)");

