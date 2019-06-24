function [detections]=capillary_detection(I,thresh,f_size1,f_size2,area_thresh)




[a,~,~]=colour_deconvolution(I,'FastRed FastBlue DAB');

red=1-im2double(a);

red(red<thresh)=0;
red=medfilt2(red,f_size1);
red_mask=imbinarize(red,adaptthresh(red,'NeighborhoodSize',f_size2));
red_mask=bwareaopen(red_mask,area_thresh);

detections=imfill(red_mask,'holes');