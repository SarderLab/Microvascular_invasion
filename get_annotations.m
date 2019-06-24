function [annot_region,mask]=get_annotations(wsi_full_path,xml_full_path,Pref)

openslide_load_library()

annot_xml=xml_read(xml_full_path,Pref);
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
annot_wsi=openslide_open(wsi_full_path);
c1=coords(:,1);

c3=coords(:,3);
c_diff=round(c3-c1);
annot_region=openslide_read_region(annot_wsi,int32(c1(1)),int32(c1(2)),int32(c_diff(1)),int32(c_diff(2)));
annot_region=annot_region(:,:,2:4);

mask=zeros(int32(c_diff(2)),int32(c_diff(1)));
ref_loc=int32(c1);
len_box=double(c_diff);
for i=1:length(neg_coord_list)
    boundary_points=double(((neg_coord_list{i,1})-[ref_loc(1);ref_loc(2)])+1);
    bw=poly2mask(boundary_points(1,:),boundary_points(2,:),len_box(2),len_box(1));
    mask=mask|bw;
end
openslide_close(annot_wsi)