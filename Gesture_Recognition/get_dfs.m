function  [vrx, hds, ss] = get_dfs(path, rx_cnt, rx_acnt, Ts, win_len, stride, snap, vmax, resolution)

psg = {};
hds = {};
sall = {};

for ii = 1:rx_cnt
    %% Load CSI of each antenna
    spth = [path, '-r', num2str(ii), '.dat'];
    [csi_data, ~] = csi_get_all(spth);

    %% PCA in frequency domain
    csi_data = csi_data.';
    H_ratio = [];
    for rx = 1:rx_acnt
        H_ratio(1:30, :) = csi_data(1:30, :)./(csi_data(31:60, :)+eps);
        H_ratio(31:60, :) = csi_data(1:30, :)./(csi_data(61:90, :)+eps);
        H_ratio(61:90, :) = csi_data(31:60, :)./(csi_data(61:90, :)+eps);
    end
    % Remove outliers
    invalid = sum(abs(H_ratio)>99, 2)>0;
    H_ratio(invalid, :) = [];    
    % PCA analysis
    pca_coef = pca(H_ratio.');
    h_ratio = H_ratio.' * pca_coef(:,1);
    h_ratio = h_ratio.';

    %% Dynamic path extraction
    h_ratio = h_ratio - mean(h_ratio, 2);
    h_ss = smooth(h_ratio, 21).';
    h_diff = diff(h_ss, 1, 2);
    Path_d = smooth(h_diff, 21).' - smooth(h_diff, 61).';
    Path_d(1:30) = 0; Path_d(end-30:end) = 0;
    hds{ii} = Path_d;

    %% DFS Estiamtion
    lambda = 299792458 / 5.825e9;
    input = Path_d.';
    sig_num = 1;
    [P_all, S_all, P_max, vd_set, win_center] = music_doppler_new(1, input, win_len, stride, snap, vmax, resolution, lambda, Ts, sig_num);

    %% Smooth
    pmax_sg = P_max;
    pmax_sg = sgolayfilt(pmax_sg,1,21); 
    psg{ii} = pmax_sg;
    sall{ii} = S_all;

end

%% Resample
lens = [];
for rx =1:rx_cnt
    ps = psg{rx};
    lens = [lens length(ps)];
end
len_max = max(lens);
vrx = zeros(len_max, rx_cnt);
ss = zeros(len_max, rx_cnt);
for rx =1:rx_cnt
    ps = psg{rx};
    s = sall{rx};
    vrx(:, rx) = interp1(1:length(ps), ps, 1:len_max, "makima");
    ss(:, rx) = interp1(1:length(s), s, 1:len_max, "makima");
end
vrx = vrx(30:end-30, :);
ss = ss(30:end-30, :);
end

