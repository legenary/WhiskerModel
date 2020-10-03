
% This function generates the angular velocity needed to simulate a whisk
% of [whisk_freq] Hz for [time_stop] seconds by protracting the whiskers by
% [prot_degree] degrees and retracting the whiskers by [retr_degree]
% degrees in reference of the mean angle of the total whisk amplitude. The
% generated trajectory is written to a CSV file which serves as input to
% the model WHISKiT Physics. The generated data is consistent with the
% average array from Belli et al, 2018. Note that the average array does
% not include a B5 whisker and therefore only consists of 60 whiskers
% total.
% Authors: Yifu Luo, Nadina Zweifel
% ========================================================================
% Inputs
    % retr_degree:  retr_degree angle in degrees
    % prot_degree:  prot_degree angle in degrees 
    % whisk_freq:   whisking frequency in Hz
    % time_stop:    duration of simulation in seconds
% Outputs:
    % CSV file with whisker trajectories for simulation
    
function generate_whisk_average_rat(retr_degree,prot_degree,whisk_freq,time_stop)

    max_whiskers = 60;
    fps = 1000;
    dt = 1/fps;
    
    %% Collecting information
    data = load('RAT_cubic_all.mat');    
    
    whisker_num = length(data.AnimalNum);
    minimap = containers.Map();
    % for every whisker, put info into the container
    for wh = 1:whisker_num
        this_name = data.Names(wh,3:end);
        % if the whisker never appeared in the container
        if data.quality(wh) == 1
            if ~isKey(minimap, this_name)
                % add a new struct to the container
                first_struct.num = 1;
                first_struct.S2D = data.S2D(wh);
                first_struct.S3D = data.S3D(wh);
                first_struct.A3D = data.A3D(wh);
                first_struct.K2D = data.K2D(wh);
                first_struct.BPTheta = data.BPTheta(wh);
                first_struct.BPPhi = data.BPPhi(wh);
                first_struct.BPR = data.BPR(wh);
                first_struct.EulerTheta = data.EulerTheta(wh);
                first_struct.EulerPhi = data.EulerPhi(wh);
                first_struct.EulerZeta = data.EulerZeta(wh);
                minimap(this_name) = first_struct;
            else % if the container has the whisker
                this_struct = minimap(this_name);
                % add new information to that struct
                this_struct.num = this_struct.num + 1;
                this_struct.S2D = [this_struct.S2D; data.S2D(wh)];
                this_struct.S3D = [this_struct.S3D; data.S3D(wh)];
                this_struct.S3D = [this_struct.A3D; data.A3D(wh)];
                this_struct.K2D = [this_struct.K2D; data.K2D(wh)];
                this_struct.BPTheta = [this_struct.BPTheta; data.BPTheta(wh)];
                this_struct.BPPhi = [this_struct.BPPhi; data.BPPhi(wh)];
                this_struct.BPR = [this_struct.BPR; data.BPR(wh)];
                this_struct.EulerTheta = [this_struct.EulerTheta; data.EulerTheta(wh)];
                this_struct.EulerPhi = [this_struct.EulerPhi; data.EulerPhi(wh)];
                this_struct.EulerZeta = [this_struct.EulerZeta; data.EulerZeta(wh)];
                % add information to the struct
                minimap(this_name) = this_struct;
            end
        end
    end

    % The whisker start at rest.
    % Azimuth span: -retr_degree~prot_degree
    
    timepoints = floor(fps / whisk_freq);
    k = keys(minimap)';
    EulerThetas = zeros((max_whiskers/2), timepoints);
    EulerPhis = zeros((max_whiskers/2), timepoints);
    EulerZetas = zeros((max_whiskers/2), timepoints);
    
    % Elevation with azimuth
    dPhi = [0.12*ones(5,1);     %   A row:  0.12 +/- 0.17
            0.3*ones(6,1);      %   B row:  0.(max_whiskers/2) +/- 0.17
            0.3*ones(7,1);      %   C row:  0.(max_whiskers/2) +/- 0.13
            0.14*ones(7,1);     %   D row:  0.14 +/- 0.14
            -0.02*ones(6,1)];   %   E row:  -0.02 +/- 0.13
    
    % Torsion with azimuth
    dZeta = [-0.75*ones(5,1);   %   A row:  -0.75
            -0.25*ones(6,1);    %   B row:  -0.25
            0.20*ones(7,1);     %   C row:  0.20
            0.40*ones(7,1);     %   D row:  0.40
            0.73*ones(6,1)];    %   E row:  0.73
    
    % for (max_whiskers/2) whiskers
    for i = 1:(max_whiskers/2)
        EulerThetaRest = nanmean(minimap(k{i}).EulerTheta);
        EulerPhiRest = nanmean(minimap(k{i}).EulerPhi);
        EulerZetaRest = nanmean(minimap(k{i}).EulerZeta);

        EulerThetas(i, :) = linspace(EulerThetaRest-retr_degree, EulerThetaRest+prot_degree, timepoints);
        EulerPhis(i, :) = linspace(EulerPhiRest+retr_degree*dPhi(i), EulerPhiRest+prot_degree*dPhi(i), timepoints);
        EulerZetas(i, :) = linspace(EulerZetaRest-retr_degree*dZeta(i), EulerZetaRest+prot_degree*dZeta(i), timepoints);
    end
      
    % Load look-up data ranging from ~70+[-retr_degree,prot_degree]
    EulerThetaPhase = mean(EulerThetas);
    EulerThetaMin = min(EulerThetaPhase);
    EulerThetaMax = max(EulerThetaPhase);
    
    % generating sinusoidal whisking trajectory
    t = 0:dt:time_stop;
    phase = cos(2*pi*whisk_freq*t + pi)*(EulerThetaMax-EulerThetaMin)/2 ...
            + (EulerThetaMax+EulerThetaMin)/2;

    %% Step 1: get orienation angles/matrix from each time step
    EulerThetasList = interp1(EulerThetaPhase, EulerThetas', phase,'spline')';
    EulerPhisList = interp1(EulerThetaPhase, EulerPhis', phase,'spline')';
    EulerZetasList = interp1(EulerThetaPhase, EulerZetas', phase,'spline')';
    
   % create orientation matrix (both right and left)
    nStep = length(phase);
    orientMat = cell(max_whiskers,nStep);
    for s = 1:nStep
        for i = 1:(max_whiskers/2)
            theta = EulerThetasList(i, s);
            phi = EulerPhisList(i, s);
            zeta = EulerZetasList(i, s);
            % Right
            orientMat{i, s} = rotz(theta, 'deg')*rotx(-phi, 'deg')*...
                              roty(-zeta, 'deg');
            % Left
            orientMat{i+(max_whiskers/2), s} = rotz(-theta, 'deg')*rotx(-phi, 'deg')*...
                              roty(zeta, 'deg');
        end
    end


    %% Step 2: Get angular velocity tensor by 
    % d(Rsb)/dt = [w]*Rsb
    % [w] = dA/dt*A';
    % Differentiation is done by "symmetric difference quotrient", so that the
    % first order error is canceled.
    W = cell(max_whiskers, nStep-1);
    for tt = 2:nStep-1
        for i = 1:max_whiskers
            W{i, tt} = (orientMat{i, tt+1}-orientMat{i, tt-1})/2/dt*orientMat{i, tt}';
        end
    end
    % add first
    for i = 1:max_whiskers
        W{i, 1} = (orientMat{i, 2}-orientMat{i, 1})/dt*orientMat{i, 1}';
    end

    %% Step 3: convert tensor to vector
    % a_vel is a 62x(nStep*3) matrix with 31 whiskers on each side.
    % 1-5    6-11    12-18    19-25    26-31
    % A12345 B12345 C1234567 D1234567 E234567

    a_vel = cell2mat(cellfun(@tensor2vector, W, 'UniformOutput', false));
    writematrix(a_vel, '../../data/whisking_trajectory_sample.csv', 'Delimiter', ',');

    %% Step 4: 
    a_loc = [EulerThetasList(:,1), EulerPhisList(:,1), EulerZetasList(:,1);...
             -EulerThetasList(:,1), EulerPhisList(:,1), -EulerZetasList(:,1)]*pi/180;
    writematrix(a_loc, '../../data/whisking_init_angle_sample.csv', 'Delimiter', ',');
 
 end

function w = tensor2vector(W)
    w = zeros(1,3);
    w(1) = W(3,2);
    w(2) = W(1,3);
    w(3) = W(2,1);
end