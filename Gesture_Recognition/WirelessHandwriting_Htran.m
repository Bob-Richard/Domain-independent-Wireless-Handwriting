%% Estimate the transformation matrix Ht at each position
%% Perform trajectory recovery and recognition
%% Thanks to Widar3.0 open-source dataset

clc;clear;close all;
%% Settings
total_mo = 10;   % Total motion count
total_pos = 5;  % Total position count
total_ori = 5;  % Total orientation count
total_ges = 2;  % Use two '0' gestures to estimate Ht
rx_cnt = 6;     % Receiver count(no less than 3)
rx_acnt = 3;    % Antenna count for each receiver
dpth_pwd = './';% The path of origin csi data 
dpth_date = '20181112/user2';% Used data folder
dpth_people = 'user2';% User id
dpth_ges = [dpth_pwd, dpth_date, '/'];
% MUSIC settings
Ts = 1e-3;
win_len = 15;
stride = 5;
snap = 5;
vmax = 3;
resolution = 0.05;

%% Htran estimation
Ht_all = zeros(25, 2, 6);% [5 positions*5 orientations, 2 dimensions, 6 TRx links]
net = load("PretrainedModel.mat").net;
for mo_sel = 10 % only digit 0
    for pos_sel = 1:total_pos
        for ori_sel = 1:total_ori
            Ht_tmp = zeros(2, 6);
            est_num = 0;
            for ges_sel = 1:total_ges
                spfx_ges = [dpth_people, '-', num2str(mo_sel), '-', num2str(pos_sel),...
                    '-', num2str(ori_sel), '-', num2str(ges_sel)];
                if exist([dpth_ges spfx_ges '-r1.dat'], 'file')
                    disp(['Running ', spfx_ges]); 
                    [vrx, hds, ss] = get_dfs([dpth_ges, spfx_ges], rx_cnt, rx_acnt, Ts, win_len, stride, snap, vmax, resolution);
                    Pd_abs_sum = diag(ss*ss').';
                    valid_idx = find(Pd_abs_sum>0.1);
                    % Cut out
                    vrx_used = vrx(valid_idx(1):valid_idx(end), :);
                    % Preamble velocities
                    vectors = [-0.8660 0.5;-0 1;0.8660 0.5;0.8660   -0.5;0 -1;-0.8660 -0.5]*0.75;
                    v_num = size(vectors, 1);
                    win_idx = round(((0:v_num-1)+0.5)/v_num*size(vrx_used, 1));
                    p_sam = vrx_used(win_idx, :);
                    H_est = pinv(vectors)*p_sam;% in body coordinate system
                    
                    if ~any(isnan(H_est), "all")
                        Ht_tmp = Ht_tmp + H_est;
                        est_num = est_num + 1;
                    end
                else
                    disp(['Skipping ', spfx_ges])
                end
            end % for ges_sel = 1:total_ges

            if exist([dpth_ges spfx_ges '-r1.dat'], 'file')
                Ht_tmp = Ht_tmp/est_num;
                Ht_all((pos_sel-1)*5 + ori_sel, :, :) = Ht_tmp;% save
                
                %% Check the extracted dynamic paths of preamble gesture
                figure('Name', 'Dynamic path');
                for rx = 1:6
                    subplot(3,2, rx);
                    plot(real(hds{rx}));
                    hold on;
                    plot(imag(hds{rx}));
                    title(['TR' num2str(rx)]);
                end
                
                %% Check the estimated transformation matrix
                figure('Name', 'Transformation matrix');hold on;
                for i = 1:6
                    quiver(0, 0 ,Ht_tmp(1, i), Ht_tmp(2, i), 'DisplayName', ['TR' num2str(i)]);
                end
                xlim([-2 2]);ylim([-2 2]);legend();
                
                %% Check some recovered trajectories
                for g = 1:10
                    rep = 1;%  change this parameter to check another repetition
                    spfx_ges = [dpth_people, '-', num2str(g), '-', num2str(pos_sel),...
                    '-', num2str(ori_sel), '-', num2str(rep)];
                    %% Trajectory Recovery
                    if ~strcmp(spfx_ges, 'user2-5-1-3-1')% abnormal data
                        vrx = get_dfs([dpth_ges, spfx_ges], rx_cnt, rx_acnt, Ts, win_len, stride, snap, vmax, resolution);    
                        v_rec = vrx*pinv(Ht_tmp);
                        s_rec = cumsum(v_rec, 1)*Ts*stride*2;
                        s_rec  = s_rec - mean(s_rec, 1);
                    end
                        
                    %% Recognition
                    if max(abs(s_rec), [], 'all')>0.5
                        s_rec = s_rec/max(abs(s_rec), [], 'all')*0.5;
                    end  
                    side_len = 100;% image size
                    trace_img = ones(side_len, side_len, 3);
                    pixel = round((s_rec+0.5)*side_len);
                    cmap = jet(size(pixel, 1)); % colors
                    for i = 1:size(pixel, 1)
                        for idx1 = pixel(i, 2) + (-1:1)
                            for idx2 = pixel(i, 1) + (-1:1)
                                if side_len - idx1 >0 && side_len - idx1 < 100 && idx2>0 && idx2 < 100
                                    trace_img(side_len - idx1, idx2, :) = cmap(i, :);
                                end
                            end
                        end
                    end
                    if ~exist(['./gestures/' num2str( mod(g, 10) )])
                        mkdir(['./gestures/' num2str( mod(g, 10) )])
                    end
                    imwrite(trace_img, ['./gestures/' num2str(mod(g, 10)) '/' spfx_ges '.jpg'], 'Quality', 100);
                    
                    X = imread(['./gestures/' num2str(mod(g, 10)) '/' spfx_ges '.jpg']);
                    Y(i) = classify(net, X);

                    figure(10);
                    z = linspace(0, 1, size(s_rec,1));
                    scatter(s_rec(:, 1), s_rec(:, 2), 70, z, 'filled');
                    colormap("jet");colorbar;
                    xlim([-0.5 0.5]);ylim([-0.5 0.5]);
                    xlabel('X/m');ylabel('Y/m');
                    title(['Predicted label: '  num2str(double(Y(i))-1)]);
                    drawnow;

                end

                close all;
            end

        end
    end
end

