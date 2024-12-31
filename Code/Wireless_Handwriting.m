clc
clear
close all
feature('DefaultCharacterSet', 'UTF8');
set(groot,'defaultAxesFontName','Times New Roman')
set(groot,'defaultAxesFontSize',12)

%% Settings
Nr = 4;                                   % Rx number
Nt = 2;                                   % Tx number
N_path = 38;                         % RB number
N_fft = 38;                            % FFT point
N_path_collect = 38;            % saved path number
N_path_used = 1;                 % used path number
start_shift = 0;                      % number of used paths before main path
load_folder = '../Dataset/';
load_pos = 'P2';

%% Frequency Channel Response of Preamble Gesture
H_all_freq = load([load_folder load_pos '/Preamble.mat' ]).H;
h_processed = zeros(size(H_all_freq));
for link = 1:Nr*Nt
    h_tmp = ifft(H_all_freq((1:N_path) + (link - 1) * N_path,:), N_fft);
    h_processed((link-1)*N_path_collect + (1:N_path_collect), :) = h_tmp([N_path - N_path_collect/2 + 1 : N_path, 1 : N_path_collect/2],:);
end

figure('Name','Frequency Domain');
for rx = 1:Nr
    for tx = 1:Nt
        path = (1:N_path)+(tx-1+(rx-1)*Nt)*N_path;
        subplot(Nt,Nr,rx+(tx-1)*Nr),
        mesh(abs(H_all_freq(path,:)));
        xlabel('t'), ylabel('path');
        title(['rx' num2str(rx) ' tx' num2str(tx)]);
    end
end

figure('Name','Time Delay Domain');
for rx = 1:Nr
    for tx = 1:Nt
        path = (1:N_path_collect)+(tx-1+(rx-1)*Nt)*N_path_collect;
        subplot(Nt,Nr,rx+(tx-1)*Nr),
        mesh(abs(h_processed(path,:)));
        xlabel('t'), ylabel('path');
        title(['rx' num2str(rx) ' tx' num2str(tx)]);
    end
end

%% Main Path Extraction
h_used = valid_path_extract(Nt, Nr, N_path_collect, N_path_used, start_shift, h_processed);
pre_len = size(h_used, 2);

%% CSI Ratio
[h_ratio, Path_d] = dynamic_component_extract(Nr, Nt, h_used);
hd_cut = Path_d(:, 51:end-50);

figure('Name', 'Dynamic Path of Preamble Gesture');
for rx = 1:4
    subplot(2,2,rx);
    plot(real(hd_cut(rx, :)));
    hold on
    plot(imag(hd_cut(rx, :)));
    subtitle(['Rx' num2str(rx)]);
end






