function [annot_region,mask,ref_coord]=get_annotations(wsi_full_path,xml_full_path,Pref,sq_num)

openslide_load_library()

annot_xml=xml_read(xml_full_path,Pref);


x_list_sq=[];
y_list_sq=[];
vert_num=length(annot_xml.Annotation(1).Regions.Region(sq_num).Vertices.Vertex);
for j =1:vert_num
    x_list_sq=[x_list_sq,annot_xml.Annotation(1).Regions.Region(sq_num).Vertices.Vertex(j).ATTRIBUTE.X];
    y_list_sq=[y_list_sq,annot_xml.Annotation(1).Regions.Region(sq_num).Vertices.Vertex(j).ATTRIBUTE.Y];
end
xMin=int32(min(x_list_sq));
xMax=int32(max(x_list_sq));
yMin=int32(min(y_list_sq));
yMax=int32(max(y_list_sq));

%%%%

annotated_regions_num=length(annot_xml.Annotation(2).Regions.Region);

neg_coord_list=cell(annotated_regions_num-1,1);
for i =1:annotated_regions_num
    vert_num=length(annot_xml.Annotation(2).Regions.Region(i).Vertices.Vertex);
    x_list=[];
    y_list=[];
    for j =1:vert_num
        vert_x=annot_xml.Annotation(2).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.X;
        vert_y=annot_xml.Annotation(2).Regions.Region(i).Vertices.Vertex(j).ATTRIBUTE.Y;



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
    
    if length(unique(x_list))==1||length(unique(y_list))==1
        
        
    else
    
        neg_coord_list{i,1}=int32([x_list;y_list]);
    end
end


coords=double([x_list_sq;y_list_sq]);
xf_min=min(x_list_sq);
xf_max=max(x_list_sq);
yf_min=min(y_list_sq);
yf_max=max(y_list_sq);
xl=xf_max-xf_min;
yl=yf_max-yf_min;
ref_coord=[xf_min,yf_min];
annot_wsi=openslide_open(wsi_full_path);

annot_region=openslide_read_region(annot_wsi,int32(xf_min),int32(yf_min),int32(xl),int32(yl));

annot_region=annot_region(:,:,2:4);

mask=zeros(int32(yl),int32(xl));
if length(neg_coord_list)==1
    
else
ref_loc=int32([xf_min,yf_min]);


len_box=double(int32([xl,yl]));
for i=1:length(neg_coord_list)
    boundary_points=double(((neg_coord_list{i,1})-[ref_loc(1);ref_loc(2)])+1);
    bw=poly2mask(boundary_points(1,:),boundary_points(2,:),len_box(2),len_box(1));
    mask=mask|bw;
end
end
openslide_close(annot_wsi)