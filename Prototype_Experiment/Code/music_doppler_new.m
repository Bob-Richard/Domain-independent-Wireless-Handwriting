function [P_all, S_all, P_max, vd_set, win_center] = music_doppler_new(Nr, input, win_len, stride, snap, vmax, resolution, lambda, Ts, sig_num)
sig_len = size(input,1);% signal length
hsnap = floor(snap/2);
win_center = (1+win_len/2 + hsnap):stride:(sig_len-win_len/2-hsnap);% time window center
vd_set = (-vmax: resolution: vmax);% Doppler velocity set
omega_set = vd_set*2*pi/lambda;% Doppler angular frequency set
time_set = (0:win_len-1)*Ts;
D = exp(1i*time_set.'*omega_set);
win_num = length(win_center);
omega_num = length(omega_set);
P_all = zeros(Nr, win_num, omega_num);% pseudo specturm
S_all = zeros(Nr, win_num);% eigenvalue
P_max = zeros(Nr, win_num);% DFS
H = zeros(win_len, snap);
for rx = 1:Nr
    for n = 1:win_num
        for sn = -hsnap:hsnap
            H(:, sn + hsnap + 1) = input(win_center(n) + sn + (-win_len/2:win_len/2-1), rx);
        end       
        [u,s,~] = svd(H*H');  
        s = diag(s);
        S_all(rx, n) = s(1);
        u_noi = u(:,sig_num+1:end); % noise subspace
        P_all(rx, n, :) = 1 ./ diag(abs(D' * (u_noi * u_noi') * D)) ;
    end
    [~,ind] = max(squeeze(P_all(rx, :, :)),[],2);
    P_max(rx,:) = vd_set(ind);
end
end