close all
clear all
addpath('C:\Users\bgginley\Desktop\Microvascular_invasion\xml_io_tools_2010_11_05\')
openslide_load_library()
box_size=1000;
step_size=0.25;
% Pref.ItemName - default 'item' - name of a special tag used to itemize
%                    cell arrays
%    Pref.ReadAttr - default true - allow reading attributes
%    Pref.ReadSpec - default true - allow reading special nodes
%    Pref.Str2Num  - default 'smart' - convert strings that look like numbers
%                   to numbers. Options: "always", "never", and "smart"
%    Pref.KeepNS   - default true - keep or strip namespace info
%    Pref.NoCells  - default true - force output to have no cell arrays
%    Pref.Debug    - default false - show mode specific error messages
%    Pref.NumLevels- default infinity - how many recursive levels are
%      allowed. Can be used to speed up the function by prunning the tree.
%    Pref.RootOnly - default true - output variable 'tree' corresponds to
%      xml file root element, otherwise it correspond to the whole file.
%    Pref.CellItem - default 'true' - leave 'item' nodes in cell notation.
Pref.Str2Num='always';
annot_xml=xml_read('test_ndpi_001.xml',Pref);
annotated_regions_num=length(annot_xml.Annotation(1).Regions.Region);
x_list_sq=[];
y_list_sq=[];

neg_coord_list=cell(annotated_regions_num-1,1);

for i =1:annotated_regions_num
    
    if i==1
        vert_num=length(annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex);
        for j =1:vert_num
            x_list_sq=[x_list_sq,annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.X];
            y_list_sq=[y_list_sq,annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.Y];
        end
        xMin=int32(min(x_list_sq));
        xMax=int32(max(x_list_sq));
        yMin=int32(min(y_list_sq));
        yMax=int32(max(y_list_sq));
    else
        vert_num=length(annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex);
        x_list=[];
        y_list=[];
        
        for j =1:vert_num
            vert_x=annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.X;
            vert_y=annot_xml.Annotation(1).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.Y;
            if vert_x>xMax
               vert_x=xMax; 
            end
            
            if vert_x<xMin
                vert_x=xMin; 
            end
            
            if vert_y>yMax
                vert_y=yMax; 
            end
            
            if vert_y<yMin
                 vert_y=yMin; 
            end
            x_list=[x_list,vert_x];
            y_list=[y_list,vert_y];
        end

        neg_coord_list{i-1,1}=int32([x_list;y_list]);
        
    end
end

coords=double([x_list_sq;y_list_sq]);
annot_wsi=openslide_open('C:\Users\bgginley\Desktop\Microvascular_invasion\test_ndpi.ndpi');
c1=coords(:,1);

c3=coords(:,3);
c_diff=round(c3-c1);
annot_region=openslide_read_region(annot_wsi,int32(c1(1)),int32(c1(2)),int32(c_diff(1)),int32(c_diff(2)));

figure,imshow(annot_region(:,:,2:4))

mask=zeros(int32(c_diff(2)),int32(c_diff(1)));
ref_loc=int32(c1);
len_box=double(c_diff);
for i=1:length(neg_coord_list)
    boundary_points=double(((neg_coord_list{i,1})-[ref_loc(1);ref_loc(2)])+1);

%     boundary_points(boundary_points(2,:)<0)=1;
%     boundary_points(boundary_points(1,:)<0)=1;
%     boundary_points(boundary_points(2,:)>c_diff(2))=c_diff(2);
%     boundary_points(boundary_points(1,:)>c_diff(1))=c_diff(1);
    
    bw=poly2mask(boundary_points(1,:),boundary_points(2,:),len_box(2),len_box(1));
    mask=mask|bw;


end

% figure,imshow(mask)

[d1,d2]=size(mask);
subArray1=1:(step_size*box_size):d1;
subArray2=1:(step_size*box_size):d2;
annot_region=annot_region(:,:,2:4).*uint8(repmat(~mask,[1,1,3]));
subArray1=[subArray1,d1];
subArray2=[subArray2,d2];

for i=1:length(subArray1)
    
        xSt=subArray1(i);
       
    if xSt==d1
        continue
    end
         xEn=xSt+box_size;
         if xEn>d1
            xEn=d1;
         end
    for j=1:length(subArray2)
        ySt=subArray2(j);
        
        if ySt==d2
            continue
        end
        
        yEn=ySt+box_size;
        if yEn>d2
           yEn=d2; 
        end
        subArray=annot_region(xSt:xEn,ySt:yEn,:);
        figure(4),imshow(subArray),pause
        
        
        
    end
    
    
end



openslide_close(annot_wsi)