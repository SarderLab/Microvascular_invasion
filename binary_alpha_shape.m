function [closed_shapes]=binary_alpha_shape(binary_im,alpha,box_size)

[x,y]=find(binary_im);
shp=alphaShape(x,y,alpha);

closed_shapes=zeros(box_size+1,box_size+1);
for p=1:numRegions(shp)
    [~,points]=boundaryFacets(shp,p);
    
    closed_shapes=closed_shapes|poly2mask(points(:,2),points(:,1),box_size+1,box_size+1);
end
