%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              LABORATORY #2 
%%%              VIDEO PROCESSING 2022-2023
%%%              VIDEO SEGMENTATION - BACKGROUND SUBTRACTION 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% In this function the background subtraction is performed. The function 
% provides the center and radius of the largest blob in your deteccion.
% Input: input_image the image to be processed
%        image_template the image to encode the background
%        th the threshold to apply
% Output: foregroundrn the foreground detection
%         (cc,cr) the center of the largest blob
%         radius  the corresponding blob
%         flag a label; flag=0 if failure        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [foregroundrn, cc,cr,radius,flag]=extract_object(input_image,image_template,th)
  
  % Initialization
  cc = 0; cr = 0; radius=0; flag=0;
  [rows,columns] = size(image_template);

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Subtracting background.  
  % MISSING CODE HERE
  foreground = zeros(rows,columns);
  grayin=mat2gray(input_image);
  
  foreground = abs(grayin(:,:,1)-image_template)>th;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  

 
  % Erode to remove small noise. 
  foregroundrn = bwmorph(foreground,'erode',1);%antes 2
  
  
  figure(40)

  imshow(foreground)
  title("Foreground")
  figure(41)
  
  imshow(foregroundrn)
  title("Foreground w/o noise")
  hold on

  % -----------------------------------------------------------------------
  % Tracking Module. Selecting the largest object
  labeled = bwlabel(foregroundrn,4);
  stats = regionprops(labeled,['basic']);
  [N,W] = size(stats);
  if N < 1
    return   
  end

  % Doing bubble sort (large to small) on regions in case there are more
  % than one
  id = zeros(N);
  for i = 1 : N
    id(i) = i;
  end
  for i = 1 : N-1
    for j = i+1 : N
      if stats(i).Area < stats(j).Area
        tmp = stats(i);
        stats(i) = stats(j);
        stats(j) = tmp;
        tmp = id(i);
        id(i) = id(j);
        id(j) = tmp;
      end
    end
  end

  % Making sure that there is at least one big region
  if stats(1).Area < 30%antes 100 
    return
  end
  selected = (labeled==id(1));

  % Getting center of mass and radius of largest
  centroid = stats(1).Centroid;
  radius = sqrt(stats(1).Area/pi);
  cc = centroid(1);
  cr = centroid(2);
  flag = 1;
  
  plot(cc,cr,'*r')
  hold off
  
  return

