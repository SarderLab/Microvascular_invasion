close all
clear all


ID='S15-77013 - 2016-12-12 17.11.00';

xml_path=['C:\Users\bgginley\Desktop\Microvascular_invasion\\Good Quality\',ID,'.xml'];
xml_out=xml_path;

label_offsets=[24105,33025];
annot_path_pre=['C:\Users\bgginley\Desktop\Microvascular_invasion\Good Quality\',ID,'_',num2str(label_offsets(1)),'_',num2str(label_offsets(2)),'.png'];
annot_image=imread(annot_path_pre);
id=strsplit(annot_path_pre,'\');
id_sp=strsplit(id{1,end},'.png');
annot_image_thin=thin_annotations(annot_image);
foldername=fullfile(id{1,1:end-1});
thin_add=[foldername,'\',id_sp{1,1},'_thin.png'];
imwrite(annot_image_thin,thin_add)

mod = py.importlib.import_module('mask_to_xml');
xml_color = [65280, 65535, 255, 16711680, 33023];


py.mask_to_xml.mask_to_xml(xml_path,thin_add,label_offsets,xml_out, 1,1,1)