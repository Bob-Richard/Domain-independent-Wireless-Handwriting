function [h_ratio, hd] = dynamic_component_extract(Nr, Nt, h)
%% CSI Ratio
len = size(h, 2);
h_ratio = zeros(Nr, len);
for rx = 1:Nr 
    h1 = h(( (rx-1)*Nt) + 1 ,:);
    h2 = h(( (rx-1)*Nt) + 2 ,:);
    h_ratio(rx, :) = h2./h1;
end

%% Extract dynamic path
Path_ss = sgolayfilt(h_ratio,13, 51, [], 2);  
Path_d_diff1 = gradient(Path_ss, 1);
Path_d_diff1_ss = sgolayfilt(Path_d_diff1, 13, 51, [], 2);
Path_d_diff1_ls = sgolayfilt(Path_d_diff1, 2, 81, [], 2);
hd = Path_d_diff1_ss - Path_d_diff1_ls;

end