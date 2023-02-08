%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2022-2023
%%%              VIDEO SEGMENTATION - BACKGROUND SUBTRACTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath data


% Loading input data
 video=VideoReader('input-video.avi');

 nframes=20;
% Extracting frames (a set of them or, all of them). 10 frames in the example
 frames=read(video,[1 nframes]);


% Obtaining the background image or the template
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISSING CODE HERE
% Loading frames
% image_template = double(imread('imagen0000.png'));
 
% Fixing a threshold
 th=0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Showing the image template




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Video Segmentation
[rows,columns,dim] = size(image_template);

%%CreaciÛn matriz de todos los frames en escala de grises
grey_frames=zeros(rows,columns,nframes);
for i=1:nframes
temp=mat2gray(frames(:,:,:,i));
grey_frames(:,:,i)=temp(:,:,1);
end
%%calculo de la media de fotogramas colindantes para cada fotograma.
backgrounds=movmean(grey_frames,3,3);

%%pequeño cambio en el codigo para no contabilizar como centroides las
%%interaciones con flag=0
cc=double.empty;
cr=double.empty;

for i = 1:nframes

figure(1)
imshow(backgrounds(:,:,i))
%imshow(background)
title("background")
  % Loading image
  input_image=frames(:,:,:,i);

  %Extracting foreground
  [foreground,tempcc,tempcr,radius,flag]=extract_object(input_image,backgrounds(:,:,i),th);
  if flag==0
    continue
  end

  %%pequeño cambio en el codigo para no contabilizar como centroides las
    %%interaciones con flag=0
  cc(end+1)=tempcc;
  cr(end+1)=tempcr;
  %Observing results
  figure(2)
  clf
  imshow(input_image)
  hold on
  for c = -0.97*radius: radius/20 : 0.97*radius
      r = sqrt(radius^2-c^2);
      plot(cc(end)+c,cr(end)+r,'g.')
      plot(cc(end)+c,cr(end)-r,'g.')
  end 
  hold off

 disp('Observing detection. Press any key');  
 pause;
   
   
end

% Recovering the full trajectory
cr=size(input_image,1)-cr;
figure(100)
plot(cc(1:end),cr(1:end),'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',10)
axis([0 size(input_image,2) 0 size(input_image,1)])