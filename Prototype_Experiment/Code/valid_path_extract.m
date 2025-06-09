function [h_used] = valid_path_extract(Nt, Nr, N_path_collect, N_path_used, start_shift, h)
%% Find the strongest path
start_path = zeros(Nr, Nt);
for rx = 1:Nr
    for tx = 1:Nt
        path = (1:N_path_collect)+(tx-1+(rx-1)*Nt)*N_path_collect;
        h_all = h(path,:);
        [~,idx]= max(sum(abs(h_all),2));
        start_path(rx, tx) = idx - start_shift;
    end
end

%% Extract main path
h_used = zeros(N_path_used * Nt * Nr, size(h, 2));    
for rx = 1:Nr
    for tx = 1:Nt
        path_used = (1:N_path_used) + ((rx-1)*Nt+(tx-1))*N_path_used;
        path = (start_path(rx, tx):N_path_used+start_path(rx, tx)-1) + ((rx-1)*Nt+(tx-1))*N_path_collect;
        h_used(path_used, :) = h(path,:);
    end
end

end