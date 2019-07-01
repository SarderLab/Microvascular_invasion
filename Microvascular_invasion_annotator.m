close all
clear all
addpath('C:\Users\bgginley\Desktop\Microvascular_invasion\xml_io_tools_2010_11_05\')

box_size=1000;
step_size=0.5;


ID='S15-70439.1.A.11 - 2016-12-05 18.34.15';
wsi_path=['C:\Users\bgginley\Desktop\Microvascular_invasion\Good Quality\',ID,'.ndpi'];
xml_path=['C:\Users\bgginley\Desktop\Microvascular_invasion\\Good Quality\',ID,'.xml'];
Pref.Str2Num='always';


[annot_region,neg_mask,ref_coord]=get_annotations(wsi_path,xml_path,Pref,2);


detected_objects=capillary_detection(annot_region,0.5,[10,10],[101,101],500);
figure(1),imshow(annot_region)
if sum(sum(neg_mask))>0
detected_objects(neg_mask)=0;


figure(2),imshow(neg_mask)
end

[d1,d2]=size(neg_mask);
subArray1=1:(step_size*box_size):d1;
subArray1(end)=d1;

subArray2=1:(step_size*box_size):d2;
subArray2(end)=d2;

saveMask1=false(d1,d2);
saveMask2=false(d1,d2);

for i=1:length(subArray1)
    
    xSt=subArray1(i);
       
    if xSt==d1
        continue
    end
         xEn=xSt+box_size;
         if xEn>d1
            xEn=d1;
            xSt=d1-box_size;
            i=length(subArray1);
         end
    for j=1:length(subArray2)
        ySt=subArray2(j);
        if ySt==d2
            continue
        end
        yEn=ySt+box_size;
        if yEn>d2
           yEn=d2;
           ySt=d2-box_size;
           j=length(subArray2);
        end
        subArray=annot_region(xSt:xEn,ySt:yEn,:);
        subMask=detected_objects(xSt:xEn,ySt:yEn);
        if sum(sum(subMask))==0
           continue     
        end
        
        if (xEn-xSt)<box_size
            subArray=padarray(subArray,[box_size-(xEn-xSt),0],'post');
            subMask=padarray(subMask,[box_size-(xEn-xSt),0],'post');
        end
        
        if (yEn-ySt)<box_size
            subArray=padarray(subArray,[0,box_size-(yEn-ySt)],'post');
            subMask=padarray(subMask,[0,box_size-(yEn-ySt)],'post');
        end
        subImMasked=subArray;
        subImMasked(~repmat(subMask,[1,1,3]))=0;
        
        save_breaks=zeros(size(subMask));
        while 1
            figure(3),subplot(121),imshow(subArray)
            subplot(122),imshow(subImMasked),title('Break connected objects')
            h=drawfreehand('closed',false,'InteractionsAllowed','all'),pause
            if ~isvalid(h)
               break 
            end
            
            bw=createMask(h);
            bw=bw(:,:,1);
            if sum(sum(bw))==0
               break 
            else
%                save_breaks=save_breaks|bw; 
               if sum(sum(bw))>0
                bw=imdilate(bw,strel('disk',2));
                subMask(bw)=0;
                subImMasked=subArray;
                subImMasked(~repmat(subMask,[1,1,3]))=0;
                detected_objects(xSt:xEn,ySt:yEn)=detected_objects(xSt:xEn,ySt:yEn)-(bw&detected_objects(xSt:xEn,ySt:yEn));
                end
            end
        end
%         if sum(sum(save_breaks))>0
%         save_breaks=imdilate(save_breaks,strel('disk',2));
%         subMask(save_breaks)=0;
%         subImMasked=subArray;
%         subImMasked(~repmat(subMask,[1,1,3]))=0;
%         end
        figure(3),subplot(121),imshow(subArray)
%         subplot(122),imshow(subImMasked),title('Select unclosed capillaries')
%         open_caps=bwselect();
%         open_caps=open_caps(:,:,1);
%         
%         detected_objects(xSt:xEn,ySt:yEn)=detected_objects(xSt:xEn,ySt:yEn)-open_caps;
%         open_caps=binary_alpha_shape(open_caps,20,box_size);
%         detected_objects(xSt:xEn,ySt:yEn)=detected_objects(xSt:xEn,ySt:yEn)+open_caps;
%         subMask=subMask|open_caps;
%         
        subImMasked=subArray;
        subImMasked(~repmat(subMask,[1,1,3]))=0;
        subplot(122),imshow(subImMasked),title('Select capillaries')
        
        caps=bwselect();
        caps=caps(:,:,1);
        subMask(caps)=0;
        saveMask1(xSt:xEn,ySt:yEn)=saveMask1(xSt:xEn,ySt:yEn)|caps;
        detected_objects(xSt:xEn,ySt:yEn)=detected_objects(xSt:xEn,ySt:yEn)-caps;
        
      
        subImMasked(~repmat(subMask,[1,1,3]))=0;
        
        subplot(122),imshow(subImMasked),title('Select invaded capillaries')
        inv_caps=bwselect();
        inv_caps=inv_caps(:,:,1);
        subMask(inv_caps)=0;
        saveMask2(xSt:xEn,ySt:yEn)=saveMask2(xSt:xEn,ySt:yEn)|inv_caps;
        detected_objects(xSt:xEn,ySt:yEn)=detected_objects(xSt:xEn,ySt:yEn)-inv_caps;
        
    
        figure(4),imagesc(double(saveMask1)+2*double(saveMask2))
%         figure(5),imshow(detected_objects),pause
    end
end



imwrite(uint8(saveMask1+2*saveMask2),['Good Quality\',ID,'_',num2str(int32(ref_coord(1))),'_',num2str(int32(ref_coord(2))),'.png'])


