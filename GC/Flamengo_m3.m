%% flamingo
for i=0:9
    s1 = 'flamingo_0000';
    s2 = '.jpg';
    s = strcat(s1,string(i),s2); % obtenemos los diferents nombres de las imagenes
    
    input_image = imread(s); %recorremos los diferentes frames y cargamos las imagenes 
    
    
    maskedImage = input_image;
    maskedImage(repmat(~BW2,[1 1 3])) = 0; %utilizamos la BW obtenida en la app de image segmentation
    figure(i+1)
    imshow(maskedImage) %mostramos las diferentes maskedImage
       
    %calcular el error
    s_1 = 'flamingo_0000';
    s_2 = '.png';
    s_ = strcat(s_1,string(i),s_2); 
    input_image_ground_truth = imread(s_); % cargamos las diferentes imagenes que contien ground-truth las correspodientes imagenes
    
    
    
    err = immse(input_image_ground_truth, im2uint8(BW2)); %encontramos el error
    disp(err)
    %
end


