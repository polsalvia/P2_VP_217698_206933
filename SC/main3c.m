%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2022-2023
%%%              VIDEO SEGMENTATION - VIDEO SCENE SEGMENTATION BY 
%%%                                   SUBSPACE CLUSTERING 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% You should tune the variable "corruption" and "filter" to add or not
% noisy observations, and to consider a particular order in your temporal
% filtering.

%%%%% MAIN TO DO THE TASK 3C PART
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc


addpath common
addpath osc
addpath libs\ncut
addpath data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISSING CODE HERE, WHEN A VIDEO IS CONSIDERED AS INPUT. COMMENT THE NEXT
% LINES TO PRODUCE SYNTHETIC DATA IN THIS CASE

mex -O libs/ncut/spmtimesd.cpp 
mex -O libs/ncut/sparsifyc.cpp 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Random number generation
rng(1);

%--------------------------------------------------------------------------
% EXPERIMENT GENERATION
% We consider 50 frames (n_space=5*cluster_size=10), where every cluster 
% is a piece of 10 consecutive frames. 
dim_data = 321; %number of features, pixels, etc.
n_space = 5;
cluster_size = 10;
dim_space = 4;

% Generating input data
A = gen_depmultivar_data(dim_data, dim_space, cluster_size, n_space, 0.1, 0.001);
A = normalize(A);
noise=max(max(abs(A-mean(reshape(A,dim_data*n_space*cluster_size,1)))));


% Potentially, including noisy observations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% c)
% new code implement a cell to take 3 posible values of noise
n=3; % nº components corruption array
saveX = cell(n,1);
%
corruption = [0.0, 0.02, 0.18]; % <------  Consider values in the range [0, 0.18]
for i = 1:n 
    N = randn(size(A)) * corruption(i) * noise;
    X = A + N;
    X = normalize(X);
    saveX{i}= X;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%d)
% n=10; % nº components corruption array
% saveX = cell(n,1);
% for i = 1:n 
%     %Leemos cada frame y normalizamos para pasarle info a osc_relaxed
%     X=double(im2gray(imread(sprintf('data/n%02d.bmp',i))));
%     X = normalize(X);
%     saveX{i}= X;
% end
% X_seven_char = cell(5,1);
% X_one_char = cell(5,1);
% for i = 1:5
%     X_seven_char{i} = saveX{i};
%     X_one_char{i} = saveX{i+5};
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% c)
% Solving optimization problem
lambda_1 = 0.099; % Weight coefficient to impose sparsity in affinities
lambda_2 = 0.001; % Weight coefficient to enforce temporal consistency
%%%%%new code
filter = [1,2,4]; % <-------   Impose order for temporal filtering [1, 2, 4]
m = 3; %nº components array filter  
c =1; %counter
k= m*n; %nº components array Z (3 noise * 3 filters)
saveZ = cell(k,1);
save_error = [];
for i= 1:m
    c3 = 1; %counter
    for j= 1:n
        Z = osc_relaxed(saveX{j}, lambda_1, lambda_2, filter(i));
        saveZ{c} = Z;
        % Observing the affinity matrix
        figure(i)
        subplot(1, 3, j) ;
        imagesc(abs(saveZ{c}) + abs(saveZ{c}'))
        title(['This figure used noise = ', num2str(corruption(j)),' and filter = ', num2str(filter(i))]);
        xlabel('Frame number');
        ylabel('Frame number');
        
        % Split the video in clusters from affinity matrix Z
        clusters = ncutW(abs(saveZ{c}) + abs(saveZ{c}'), n_space);
        final_clusters = condense_clusters(clusters, 1);

        % Computing clustering error (every filter and noise)
        v = 1:n_space;
        P = perms(v)'; %5x120
        AA=kron(P,ones(cluster_size,1));
        int=0;
        for c2=1:size(AA,2)
            [a,b]=find(final_clusters==AA(:,c2));
            if (size(a,1)>int)
                nlabels=size(a,1);
                int=nlabels;
                ground_clusters=AA(:,c2);
            end
            %disp('The error in % is')
            error=(1-(nlabels/(n_space*cluster_size)))*100;
            save_error(c2) = error;
        end
        disp(['This figure used noise = ', num2str(corruption(j)),' and filter = ', num2str(filter(i)), ' and The total error in % is'])
        total_error = sum(save_error(:))/size(save_error,2) %SCE
        
        % % Observing the results
        figure(i+3)
        subplot(1, 6, c3) ;
        imagesc(final_clusters);
        ylabel('Label for every frame');
        title('Your estimation')
        subplot(1, 6, c3+1) ;
        imagesc(ground_clusters);
        ylabel('Label for every frame');
        title('Ground truth')
        text(0,1,['This figure used noise = ', num2str(corruption(j)),' and filter = ', num2str(filter(i))]);
        c3= c3+2;
        c = c+1;

    end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %d)
% % Solving optimization problem
% lambda_1 = 0.099; % Weight coefficient to impose sparsity in affinities
% lambda_2 = 0.001; % Weight coefficient to enforce temporal consistency
% %%%%%new code
% filter = [1,2,4]; % <-------   Impose order for temporal filtering [1, 2, 4]
% m = 3; %nº components array filter  
% c =1; %counter
% k= m*n; %nº components array Z (3 noise * 3 filters)
% saveZ = cell(k,1);
% save_error = [];
% for i= 1:m
%     c3 = 1; %counter
%     for j= 1:5
%         Z_one = osc_relaxed(X_one_char{j}, lambda_1, lambda_2, filter(i));
%         %Z_seven = osc_relaxed(X_seven_char{j}, lambda_1, lambda_2, filter(i));
%         saveZ{c} = Z_one;
%         %saveZ{c} = Z_seven;
%         % Observing the affinity matrix
%         figure(i)
%         subplot(1, 5, j) ;
%         imagesc(abs(saveZ{c}) + abs(saveZ{c}'))
%         title(['This image shape ONE ', num2str(j),' and filter = ', num2str(filter(i))]);
%         %title(['This image shape SEVEN ', num2str(j),' and filter = ', num2str(filter(i))]);
%         xlabel('Frame number');
%         ylabel('Frame number');
%         
%         % Split the video in clusters from affinity matrix Z
%         clusters = ncutW(abs(saveZ{c}) + abs(saveZ{c}'), n_space);
%         final_clusters = condense_clusters(clusters, 1);
% 
%         % Computing clustering error (every filter and noise)
%         v = 1:n_space;
%         P = perms(v)'; %5x120
%         saveAA = cell(2,1);
%         saveAA{1}= double(im2gray(imread(sprintf('data/n%02d.bmp',11)))); %one
%         PAA = normalize(saveAA{1});
%         %saveAA{2}= double(im2gray(imread(sprintf('data/n%02d.bmp',12)))); %seven
%         %PAA = normalize(saveAA{2});
%         clusters2 = ncutW(abs(PAA) + abs(PAA'), n_space);
%         AA = condense_clusters(clusters2, 1);
%         int=0;
%         for c2=1:size(AA,2)
%             [a,b]=find(final_clusters==AA(:,c2));
%             if (size(a,1)>int)
%                 nlabels=size(a,1);
%                 int=nlabels;
%                 ground_clusters=AA(:,c2);
%             end
%             %disp('The error in % is')
%             error=((nlabels/(n_space*cluster_size)))*100;
%             save_error(c2) = error;
%         end
%         disp(['This image shape ONE ', num2str(j),' and filter = ', num2str(filter(i)), ' and The total error in % is'])
%         %disp(['This image shape SEVEN ', num2str(j),' and filter = ', num2str(filter(i)), ' and The total error in % is'])
%         total_error = sum(save_error(:))/size(save_error,2) %SCE
%         
%         % % Observing the results
%         figure(i+3)
%         subplot(1, 10, c3) ;
%         imagesc(final_clusters);
%         ylabel('Label for every frame');
%         title('Your estimation')
%         subplot(1, 10, c3+1) ;
%         imagesc(ground_clusters);
%         ylabel('Label for every frame');
%         title('Ground truth')
%         text(0,1,['This image shape ONE ', num2str(j),' and filter = ', num2str(filter(i))]); %one
%         %text(0,1,['This image shape SEVEN ', num2str(j),' and filter = ', num2str(filter(i))]); %seven
%         c3= c3+2;
%         c = c+1;
% 
%     end
% end

