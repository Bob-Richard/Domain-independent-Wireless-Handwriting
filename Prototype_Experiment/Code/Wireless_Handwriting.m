clc
clear
close all
feature('DefaultCharacterSet', 'UTF8');
set(groot,'defaultAxesFontName','Times New Roman')
set(groot,'defaultAxesFontSize',12)

%% Settings
Nr = 4;                                   % Rx number
Nt = 2;                                   % Tx number
lambda = 3e8/3.2e9;            % wavelength
Ts = 2.5e-3;                           % sampling period of CSI
N_path = 38;                         % RB number
N_fft = 38;                            % FFT point
N_path_collect = 38;            % saved path number
N_path_used = 1;                 % used path number
start_shift = 0;                      % number of used paths before main path
vmax = 4;                               % MUSIC maximum velocity
resolution = 0.05;                  % MUSIC peak searching resolution
sig_num = 1;                          % MUSIC velocity number
gestures = {'/G0', '/G1', '/G2','/G3' ,'/G4', '/GA', '/GB', '/GC','/GD' ,'/GE'};
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

%% Velocity Template
v_xyz = load("v_template.mat").v_xyz;
v_len = size(v_xyz, 1);
hd_len = size(hd_cut, 2);
v_cut = interp1(0:v_len-1, v_xyz, 0: v_len/hd_len :v_len-1, "makima");

%% DFS Estimation of Preamble Gesture
win_len = 15; stride = 2; snap = 15;
[P_all, S_all, P_max, vd_set, win_center] = music_doppler_new(Nr, hd_cut.', win_len, stride, snap, vmax, resolution, lambda, Ts, sig_num);
win_center = round(win_center);

%% Spectrum
time_range = win_center*Ts;
figure('Name', 'Preamble Doppler Velocity');
for rx = 1:Nr
    subplot(2,2,rx);hold on;
    P_all_rx = squeeze(P_all(rx, :, :));
    imagesc(vd_set, time_range, P_all_rx);
    clim([0 10]);
    view(90,-90);
    xlim([-4 4]);
    ylim([time_range(1) time_range(end)]);
    pmax_sg = hampel(P_max(rx, :), 11);
    pmax_sg = sgolayfilt(pmax_sg,2,61);
    plot(pmax_sg, time_range,  'r');
end

psg = zeros(size(P_max))';
for rx = 1:Nr
    pmax_sg = P_max(rx,:);
    pmax_sg = sgolayfilt(pmax_sg,1,51);
    psg(:, rx) = pmax_sg;
end

%% Transformation Matrix Estimation
if strcmp(load_pos, 'P3') || strcmp(load_pos, 'P6')
    sall = sum(S_all, 1);
    vectors = [[cos(3*pi/4),  0, sin(3*pi/4)]; 
                      [cos(1*pi/4),  0, sin(1*pi/4)]; 
                      [cos(-1*pi/4),  0, sin(-1*pi/4)];
                      [cos(-3*pi/4), 0, sin(-3*pi/4)];
                      [0,                    -1,                  0];
                      [0,                      0,                  0];
                      [0,                     1,                   0]];
    search_idx = round(length(sall)/3:1:2*length(sall)/3);% find pause
    [~, idx] = min(sall(search_idx));
    pause_idx = search_idx(idx);
    circle_len = pause_idx;
    push_pull_len = length(sall) - pause_idx;
    circle_idx = round([1/8; 3/8; 5/8; 7/8]*circle_len);
    push_pull_idx = round(pause_idx + [1/4; 2/4; 3/4] * push_pull_len);
    win_idx = [circle_idx; push_pull_idx];
    p_sam = psg(win_idx, :);
    H_est = pinv(vectors)*p_sam;
    v_sam = vectors;
else
    num = 30;
    win_num = length(win_center);
    if win_num>num
        win_idx = round(1:win_num/num:win_num);
    end
    sam_idx = win_center(win_idx);
    v_sam = v_cut(sam_idx, :);
    p_sam = psg(win_idx, :);
    H_est = pinv(v_sam)*p_sam;%  
end

%% Plot Ht
figure('Name', 'Transformation Matrix', 'Color', [1 1 1]);hold on;
colors = [0 0 1; 1 0 0; 0 1 0; 0 0 0];
for rx = 1:Nr
    quiver3(0, 0, 0, H_est(1,rx), H_est(2,rx), H_est(3,rx),'Color', colors(rx,:),'LineWidth', 2,'LineStyle','-', 'DisplayName', ['TR' num2str(rx)]);
end
xlim([-2 2]);
ylim([-2 2]);
zlim([-2 2]);
view([-45 45]);
box on;
legend();

%% Trajectory Recovery
phi = (-30:0.5:30)/180*pi;%  rotation
scale = 0.5:0.01:1.5;% scaling
error_org_all = [];
error_adj_all = [];

for gesture = gestures
    fprintf(['\n' gesture{1}(2:end) '\n']);
    load_gest = [load_folder load_pos gesture{1} '.mat'];
    if ~exist(load_gest, "file")
        continue;
    end
    load(load_gest);
    gest_num = length(H_gestures);
    figure('Name','Trace');
    for gest = 1:gest_num
        fprintf(num2str(gest));
        %% 
        H_all_freq = H_gestures{gest};
        h_processed = zeros(size(H_all_freq));
        for link = 1:Nr*Nt
            h_tmp = ifft(H_all_freq((1:N_path) + (link - 1) * N_path,:), N_fft);
            h_processed((link-1)*N_path_collect + (1:N_path_collect), :) = h_tmp([N_path - N_path_collect/2 + 1 : N_path, 1 : N_path_collect/2],:);
        end
        %% 
        h_used = valid_path_extract(Nt, Nr, N_path_collect, N_path_used, start_shift, h_processed);
        pre_len = size(h_used, 2);
        %%   
        [h_ratio, Path_d] = dynamic_component_extract(Nr, Nt, h_used);
        %% DFS
        win_len = 5; stride = 1; snap = 5;
        [P_all, S_all, P_max, vd_set, win_center] = music_doppler_new(Nr, Path_d.', win_len, stride, snap, vmax, resolution, lambda, Ts, sig_num);
        P_max = P_max.';
        P_max = interp1(win_center, P_max, 1:size(Path_d, 2), "makima", "extrap");
        P_max = hampel(P_max, 21);
        %% Velocity
        v_rec = P_max*pinv(H_est);
        v_rec = sgolayfilt(v_rec, 1, 101, [], 1);
        v_rec = v_rec(51:end-50, :);
        v_truth = v_gestures{gest};
        %% Trajectory
        s_rec = cumsum(v_rec*2.5e-3, 1);
        s_rec = s_rec - mean(s_rec, 1);
        s_truth = cumsum(v_truth*2.5e-3, 1);
        s_truth = s_truth - mean(s_truth, 1);
        
        s_rec_org = s_rec;
        [s_rec, s_truth, idxs] = trace_scaling_match(s_rec, s_truth, phi, scale, [1 3]);

        s_delta = s_rec - s_truth;
        s_delta_org = s_rec_org - s_truth;
        error_org_all = [error_org_all; sqrt(sum(s_delta_org(:, [1 3]).^2, 2))];
        error_adj_all = [error_adj_all; sqrt(sum(s_delta(:, [1 3]).^2, 2))];

        subplot(2,gest_num, gest);
        plot3(s_truth(:,1), s_truth(:,2), s_truth(:, 3), 'LineWidth', 3);
        hold on
        plot3(s_rec_org(:,1), s_rec_org(:,2), s_rec_org(:, 3), 'LineWidth', 3);
        grid on
        xlim([-0.5 0.5]);
        ylim([-0.5 0.5]);
        zlim([-0.5 0.5]);

        subplot(2, gest_num,  gest+gest_num);
        plot(s_truth(:,1), s_truth(:, 3), 'LineWidth', 3, 'DisplayName', 'Truth');
        hold on
        plot(s_rec(:,1), s_rec(:, 3), 'LineWidth', 3, 'DisplayName', 'Recovery');
        grid on
        xlim([-0.5 0.5]);
        ylim([-0.5 0.5]);
        legend();
    end % for gest = 1:gest_num
end % for gesture = gestures


figure('Name', 'Error');hold on;
prob = (1:length(error_org_all))/length(error_org_all);
plot(sort(error_org_all), prob, 'DisplayName', 'Original Error');
prob = (1:length(error_adj_all))/length(error_adj_all);
plot(sort(error_adj_all), prob, 'DisplayName', 'Adjusted Error');
legend();
xlabel('Error/m');
ylabel('Rate');
title('CDF');

fprintf("\nOriginal Error : %.5f m", mean(error_org_all));
fprintf("\nAdjusted Error : %.5f m", mean(error_adj_all));



