function [detections]=capillary_detection(I,thresh,f_size1,f_size2,area_thresh)

hsv=rgb2hsv(I);
m=imbinarize(hsv(:,:,2),adaptthresh(hsv(:,:,2),0.1));
m=imfill(m,'holes');
m=imopen(m,strel('disk',3));
detections=bwareaopen(m,area_thresh);


% [a,~,~]=colour_deconvolution(I,'FastRed FastBlue DAB');
% 
% red=1-im2double(a);
% red=medfilt2(red,f_size1);
% red(red<thresh)=0;
% 
% red_mask=imbinarize(red,adaptthresh(red,'NeighborhoodSize',f_size2));
% red_mask=bwareaopen(detections,area_thresh);
% 
% detections=imfill(detections,'holes');
% detections=bwareaopen(detections,area_thresh);