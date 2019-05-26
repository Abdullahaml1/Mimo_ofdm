clear;clc;

%% Variables
SNR_db = 0:3:30;

BER_mSeq = load('BER_mSeq.mat');
BER_mSeq = BER_mSeq.BER_mSeq;

BER_gold = load('BER_gold.mat');
BER_gold = BER_gold.BER_gold;

BER_barker = load('BER_barker.mat');
BER_barker = BER_barker.BER_barker;


%% Plotting

figure;
semilogy(SNR_db, BER_mSeq);
hold on;
semilogy(SNR_db, BER_gold);
hold on;
semilogy(SNR_db, BER_barker);

grid on;
title("BER vs SNR");
ylabel("BER (Bit Error Rate)");
xlabel("SNR (Signal to Noise Ratio)");

legend({'M-Sequence','Gold Sequence', 'Barker13 Sequence'},'Location','northeast')