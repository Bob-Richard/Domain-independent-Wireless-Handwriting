function [s_rec, s_truth, idxs] = trace_scaling_match(s_rec, s_truth, phi, scale, dim)
%% Rotate and scale the trajectory to minimize RMSE
% Input
% s_rec:          recovered trajectory
% s_truth:       ground truth
% phi:              rotation angle
% scale:           scaling factor
% dim:             observation dimension
% Output
% s_rec, s_truth

idxs = [];
%% Y
y_rots_delta = zeros(size(s_rec, 1), 3, length(phi));
for i = 1:size(s_rec, 1)
    for j = 1:length(phi)
        roty = [ [ cos(phi(j)),0,  -sin(phi(j))];
                     [ 0,               1,                0 ];    
                    [ sin(phi(j)),0,   cos(phi(j))]];
        y_rots_delta(i, :, j) = s_rec(i, :) * roty - s_truth(i, :);
    end
end
y_rots_delta = sqrt( mean(     squeeze(sum(y_rots_delta(:, dim, :).^2, 2)), 1 ));
[~, idx] = min(y_rots_delta);
roty = [ [ cos(phi(idx)),0,  -sin(phi(idx))];
             [ 0,               1,                0 ];    
            [ sin(phi(idx)),0,   cos(phi(idx))]];
s_rec = s_rec*roty;
idxs = [idxs; idx];
    
%% Z
z_rots_delta = zeros(size(s_rec, 1), 3, length(phi));
for i = 1:size(s_rec, 1)
    for j = 1:length(phi)
    rotz = [ [cos(phi(j)), -sin(phi(j)) ,0 ];
                 [ sin(phi(j)),  cos(phi(j)), 0 ];
                 [          0,             0,           1]];
        z_rots_delta(i, :, j) = s_rec(i, :) * rotz - s_truth(i, :);
    end
end
z_rots_delta = sqrt( mean(     squeeze(sum(z_rots_delta(:, dim, :).^2, 2)), 1 ));
[~, idx] = min(z_rots_delta);
rotz = [ [cos(phi(idx)), -sin(phi(idx)) , 0 ];
              [ sin(phi(idx)),  cos(phi(idx)), 0 ];
              [          0,             0,                   1]];
s_rec = s_rec*rotz;
idxs = [idxs; idx];

%% X
x_rots_delta = zeros(size(s_rec, 1), 3, length(phi));
for i = 1:size(s_rec, 1)
    for j = 1:length(phi)
        rotx = [ [1,                0,                 0 ];
                    [ 0, cos(phi(j)), -sin(phi(j))];
                    [ 0, sin(phi(j)),  cos(phi(j))]];
        x_rots_delta(i, :, j) = s_rec(i, :) * rotx - s_truth(i, :);
    end
end
x_rots_delta = sqrt( mean(     squeeze(sum(x_rots_delta(:, dim, :).^2, 2)), 1 ));
[~, idx] = min(x_rots_delta);
rotx = [ [1,                    0,                    0 ];
            [ 0, cos(phi(idx)), -sin(phi(idx))];
            [ 0, sin(phi(idx)),  cos(phi(idx))]];
s_rec = s_rec*rotx;
idxs = [idxs; idx];

%% scaling
for d = dim
    d_scale = s_rec(:, d)*scale;
    d_scale_delta = mean((d_scale - s_truth(:, d)).^2, 1);
    [~, idx] = min(d_scale_delta);
    s_rec(:, d) = s_rec(:, d)*scale(idx);
    idxs = [idxs; idx];
end

end