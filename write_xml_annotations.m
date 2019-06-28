close all
clear all

xml_path='C:\Users\bgginley\Desktop\Microvascular_invasion\\Good Quality\S15-70548.1.A.4 - 2016-12-05 18.40.22.xml';
xml_out='C:\Users\bgginley\Desktop\test.xml';
annot_path='C:\Users\bgginley\Desktop\Microvascular_invasion\Good Quality\S15-70548.1.A.4 - 2016-12-05 18.40.22_22251_44120.png';

mod = py.importlib.import_module('mask_to_xml');
xml_color = [65280, 65535, 255, 16711680, 33023];
label_offsets=[22251,44120];

py.mask_to_xml.mask_to_xml(xml_path,annot_path,label_offsets,xml_out, 1,1,1)