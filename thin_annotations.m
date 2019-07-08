function b=thin_annotations(a)
b=zeros(size(a),'uint8');

classes=unique(a(a>0));

for i=1:length(classes)
    class_objects=a==classes(i);

    fixed_objects=imopen(class_objects,strel('disk',5));
%     fixed_objects=imclose(fixed_objects,strel('disk',5));
    fixed_objects=bwareaopen(fixed_objects,300);
    final_objects=imerode(fixed_objects,strel('disk',1));


    b=b+(classes(i)*uint8(final_objects));

end