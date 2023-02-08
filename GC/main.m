%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2021-2022
%%%              VIDEO SEGMENTATION - GRAPH CUT SEGMENTATION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For user interaction, you should select two pixels to define a bounding
% box with samples in foreground or background, respectively. Please,
% follow the order: 1) up-left corner, and bottom-right corner. You can use
% as many as boxes you consider (copy/paste the corresponding lines of code to 
% do that). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc


addpath data


% Loading and showing input data
input_image = imread('peppers.png');
%input_image = imread('baby.jpg');
figure(1);
imshow(input_image);

% Computing superpixels for graph (nodes and edges) initialization instead
% of pixel based approach.
L = superpixels(input_image,500);
%BW = boundarymask(L); imshow(imoverlay(input_image,BW,'cyan'),'InitialMagnification',67);

% Fixing samples within the foreground region by means of rectangular
% box/es. Creating the corresponding mask
disp('Selecting foreground area...');
[a]=ginput(2);

f1 = drawrectangle(gca,'Position',[a(1,1),a(1,2),a(2,1)-a(1,1),a(2,2)-a(1,2)],'Color','g');
% If several, mix them
foreground = createMask(f1,input_image);

% Fixing samples within the background region by means of rectangular
% box/es. Creating the corresponding mask
disp('Selecting background area...');
[a]=ginput(2);
b1 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');
[a]=ginput(2);
b2 = drawrectangle(gca,'Position',[a(1,1) a(1,2) a(2,1)-a(1,1) a(2,2)-a(1,2)],'Color','r');


% If several, mix them
background = createMask(b1,input_image) + createMask(b2,input_image);
 
disp('Observing input user interaction...');

% Applying lazysnapping algorithm, a graph cut based algorithm
BW = lazysnapping(input_image,L,foreground,background);

% Observing the foreground region
figure(2)
imshow(labeloverlay(input_image,BW,'Colormap',[0 1 0]))

% Extracting foreground region
maskedImage = input_image;
maskedImage(repmat(~BW,[1 1 3])) = 0;
figure(3)
imshow(maskedImage)
