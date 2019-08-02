import openslide
from xml_to_mask import xml_to_mask
from matplotlib import pyplot as plt
import numpy as np
from scipy.ndimage.measurements import label
from scipy.spatial import ConvexHull
import lxml.etree as ET
import glob
import os
from scipy.misc import imsave
import multiprocessing
from joblib import Parallel, delayed

def subArrayChopper(boxSize,xSt,ySt):
    xEn=xSt+boxSize
    if xEn>(yL):
        xEn=yL
        xSt=yL-boxSize
    yEn=ySt+boxSize
    if yEn>xL:
        yEn=xL
        ySt=xL-boxSize
    subArray=rgb_im[xSt:xEn,ySt:yEn,:]
    subMask=test_im[xSt:xEn,ySt:yEn]
    print(xSt,xEn,ySt,yEn)
    imsave(outDir+'images/'+file_ID+'_'+str(xSt)+'_'+str(ySt)+'.png',subArray)
    imsave(outDir+'masks/'+file_ID+'_'+str(xSt)+'_'+str(ySt)+'_mask.png',np.uint8(subMask))

dir_add='/hdd/BG_projects/Microvascular_inflammation/Labeled_images/'
labeled_slides=glob.glob(dir_add+'*.xml')
outDir='/hdd/BG_projects/Microvascular_inflammation/chopped_images/'
box_size=900
overlap=0.75
step_size=int(box_size*(1-overlap))



for xml_path in labeled_slides:
    file_ID=xml_path.split('/')[-1].split('.xml')[0]
    if os.path.exists(dir_add+file_ID+'.ndpi'):
        wsi_path=dir_add+file_ID+'.ndpi'
    else:
        wsi_path=dir_add+file_ID+'.svs'
    slide=openslide.OpenSlide(wsi_path)
    dim_x,dim_y=slide.dimensions

    region_coords=[]
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for Annotation in root.findall("./Annotation"): # for all annotations
        annotationID = Annotation.attrib['Id']

        if annotationID=='1':
            for Region in Annotation.findall("./*/Region"): # iterate on all region
                IDs=[]
                xMin=[1000000000]
                xMax=[0]
                yMin=[1000000000]
                yMax=[0]
                for Vertex in Region.findall("./*/Vertex"): # iterate on all vertex in region
                    # get points
                    x_point = np.int32(np.float64(Vertex.attrib['X']))
                    y_point = np.int32(np.float64(Vertex.attrib['Y']))
                    if x_point<xMin:
                        xMin=x_point
                    if x_point>xMax:
                        xMax=x_point
                    if y_point<yMin:
                        yMin=y_point
                    if y_point>yMax:
                        yMax=y_point
                    # test if points are in bounds


                region_coords.append([xMin,xMax,yMin,yMax])
    for region in region_coords:
        xMin=region[0]
        yMin=region[2]
        xL=region[1]-xMin
        yL=region[3]-yMin

        test_im=np.int8(xml_to_mask(xml_path,[xMin,yMin],[xL,yL],1,0))
        test_im=test_im-2
        test_im = test_im.clip(min=0)

        rgb_im=np.array(slide.read_region([xMin,yMin],0,[xL,yL]))[:,:,0:3]
        subIter1=range(0,yL-int(box_size*overlap),step_size)
        subIter2=range(0,xL-int(box_size*overlap),step_size)


        num_cores = multiprocessing.cpu_count()

        Parallel(n_jobs=num_cores, backend='threading')(delayed(subArrayChopper)(boxSize=box_size,xSt=i,ySt=j) for i in subIter1 for j in subIter2)
