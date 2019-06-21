%% Avi Microvascular Inflammation Project

%Creating training set for classification network 
%Class 1 = Peritubular capillary with Leukocyte enclosed
%Class 2 = Peritubular capillary without Leukocyte

%% Load in images
clc
close all
clear all

% load glom images
baseDir=fullfile('C:','Users','spborder','Desktop');
imgDir=fullfile(baseDir,'Avi Microvascular Inf','Test_Inf');

imgMat=dir(fullfile(imgDir));
imgMat={imgMat.name};

imgMat2={imgMat{1,3:6}};

nImg=length(imgMat2);

%FastRed FastBlue Dab
% FR=[0.21408768; 0.85171735; 0.4782719];
% FB=[0.748963; 0.6062903; 0.26733226];
% DAB=[0.26814753; 0.57031375; 0.77642715];
% 
% FR_FB_DtoRGB=[FR/norm(FR) FB/norm(FB) DAB/norm(DAB)];
% RGBtoFR_FB_D=inv(FR_FB_DtoRGB);


%Brandon's hand selection of ROI's
StainingMethod.MODx_0 =0.21474302;
StainingMethod.MODy_0 =0.7937261;
StainingMethod.MODz_0 =0.56910837;
StainingMethod.MODx_1 =0.4506932;
StainingMethod.MODy_1 =0.6000104;
StainingMethod.MODz_1 =0.66095626;
StainingMethod.MODx_2 =0.7281572;
StainingMethod.MODy_2 =0.56887734;
StainingMethod.MODz_2 =0.38231608;

%% Region selection & de-selection
train=cell(size(imgMat2));

for iImg=1:nImg
    
    %initial image
    img=imread(imgMat2{iImg});
%     figure, imshow(img),title('initial')
    
    %Color Deconvolution
    %img_dec=SeparateStains(img,RGBtoFR_FB_D);
    %figure, imshow(img_dec(:,:,1)),title('color deconv')
    
    %Color Deconvolution from Brandon
    [img_R,img_Br,img_Bl]=colour_deconvolution(img,StainingMethod);
    
    %Thresholding FastRed channel
    img_FRt=img_R<100;
%     figure, imshow(img_FRt),title('thresholded')
    
    %Filtering out small area components
    img_bwa=bwareaopen(double(img_FRt),50);
%     figure, imshow(img_bwa),title('area opened')
    
    %Dilating to increase connectivity
    img_di=imdilate(img_bwa,strel('disk',2));
%     figure, imshow(img_di),title('Dilating')
    
    %imfilling
    img_fill=imfill(img_di,'holes');
%     figure, imshow(img_fill),title('Filling')
    
    %Overlaying on initial image
    imgR=img(:,:,1).*uint8(img_fill);
    imgG=img(:,:,2).*uint8(img_fill);
    imgB=img(:,:,3).*uint8(img_fill);
    
    img_over=cat(3,imgR,imgG,imgB);
    figure, imshow(img_over),title('Select PTCs with Leukocytes, then press Enter')
    
    %BW select PTC w/ Leukocyte
    img_select=bwselect();
    img_over2=im2double(img_select(:,:,1));
    
    %Binary Reconstruction
    img_binR=imreconstruct(img(:,:,2),uint8(img_over2(:,:,1)));
    figure, imshow(img_binR>0.99),title('Binary Reconstruction')
    
    %BW select PTC w/o Leukocyte
    figure, imshow(imoverlay(img_over,img_binR,'black')),title('Select Regions that are Peritubular Capillaries w/o Leukocytes, then press Enter');
    img_select2=bwselect();
    img_over3=im2double(img_select2(:,:,1));
    figure, imshow(img_over3),title('PTCs w/o Leukocytes')
    
    %labeling selected regions with class labels
    total=im2double(img_fill);
    invaded=im2double(img_binR>0.99).*2;
    
    combined=total(invaded>0);
    
    %Storing labeled by category
    train{iImg}=combined;
    
end







