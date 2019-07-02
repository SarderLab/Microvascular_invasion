close all
clear all


ID='S16-5205 - 2016-12-12 16.53.30';

xml_path=['C:\Users\bgginley\Desktop\Microvascular_invasion\\Good Quality\',ID,'.xml'];
xml_out=xml_path;

label_offsets=[11190,12751];
annot_path=['C:\Users\bgginley\Desktop\Microvascular_invasion\Good Quality\',ID,'_',num2str(label_offsets(1)),'_',num2str(label_offsets(2)),'.png'];


mod = py.importlib.import_module('mask_to_xml');
xml_color = [65280, 65535, 255, 16711680, 33023];


py.mask_to_xml.mask_to_xml(xml_path,annot_path,label_offsets,xml_out, 1,1,1)