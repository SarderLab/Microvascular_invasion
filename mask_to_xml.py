import cv2
import numpy as np
import argparse
import lxml.etree as ET
import warnings
from skimage.io import imread

def get_contour_points(mask,min_size,approx_downsample, downsample, offset={'X': 0,'Y': 0}):
    # returns a dict pointList with point 'X' and 'Y' values
    # input greyscale binary image
    maskPoints, contours = cv2.findContours(np.array(mask), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_TC89_KCOS)

    pointsList = []
    for j in range(np.shape(maskPoints)[0]):
        if cv2.contourArea(maskPoints[j]) > ((min_size)/(downsample*downsample*approx_downsample)):
            pointList = []
            for i in range(0,np.shape(maskPoints[j])[0]):
                point = {'X': (maskPoints[j][i][0][0] * downsample) + offset['X'], 'Y': (maskPoints[j][i][0][1] * downsample) + offset['Y']}
                pointList.append(point)
            pointsList.append(pointList)
    return pointsList

### functions for building an xml tree of annotations ###
def xml_create(): # create new xml tree
    # create new xml Tree - Annotations
    Annotations = ET.Element('Annotations', attrib={'MicronsPerPixel': '0.252000'})
    return Annotations

def xml_add_annotation(Annotations,xml_color, annotationID=None): # add new annotation
    # add new Annotation to Annotations
    # defualts to new annotationID
    if annotationID == None: # not specified
        annotationID = len(Annotations.findall('Annotation')) + 1
    Annotation = ET.SubElement(Annotations, 'Annotation', attrib={'Type': '4', 'Visible': '1', 'ReadOnly': '0', 'Incremental': '0', 'LineColorReadOnly': '0', 'LineColor': str(xml_color[annotationID-1]), 'Id': str(annotationID), 'NameReadOnly': '0'})
    Regions = ET.SubElement(Annotation, 'Regions')
    return Annotations

def xml_add_region(Annotations, pointList,label_offsets,approx_downsample, annotationID=-1, regionID=None): # add new region to annotation
    # add new Region to Annotation
    # defualts to last annotationID and new regionID
    Annotation = Annotations.find("Annotation[@Id='" + str(annotationID) + "']")
    Regions = Annotation.find('Regions')
    if regionID == None: # not specified
        regionID = len(Regions.findall('Region')) + 1
    Region = ET.SubElement(Regions, 'Region', attrib={'NegativeROA': '0', 'ImageFocus': '-1', 'DisplayId': '1', 'InputRegionId': '0', 'Analyze': '0', 'Type': '0', 'Id': str(regionID)})
    Vertices = ET.SubElement(Region, 'Vertices')
    for point in pointList: # add new Vertex
        ET.SubElement(Vertices, 'Vertex', attrib={'X': str(point['X']*approx_downsample), 'Y': str(point['Y']*approx_downsample), 'Z': '0'})
    # add connecting point
    ET.SubElement(Vertices, 'Vertex', attrib={'X': str(pointList[0]['X']*approx_downsample), 'Y': str(pointList[0]['Y']*approx_downsample), 'Z': '0'})
    return Annotations

def xml_save(Annotations, filename):
    xml_data = ET.tostring(Annotations, pretty_print=True)
    #xml_data = Annotations.toprettyxml()
    f = open(filename, 'wb')
    f.write(xml_data)
    f.close()

def read_xml(filename):
    # import xml file
    tree = ET.parse(filename)
    root = tree.getroot()



def mask_to_xml(xml_path,annot_path,label_offsets, xml_filename, approx_downsample,min_size,downsample):
    # make xml
    xml_color=[65280, 65535, 255, 16711680, 33023]
    wsiMask=imread(annot_path)
    #Annotations = read_xml(xml_path)
    tree = ET.parse(xml_path)
    Annotations = tree.getroot()

    # add annotation
    for i in [2,3]: # exclude background class
        Annotations = xml_add_annotation(Annotations=Annotations,xml_color=xml_color, annotationID=i)


    for classregion in [2,3]:
        binaryMask = np.zeros(np.shape(wsiMask)).astype('uint8')
        binaryMask[wsiMask == (classregion-1)] = 1
        pointsList = get_contour_points(binaryMask, min_size,approx_downsample, downsample,offset={'X': label_offsets[0],'Y': label_offsets[1]})

        for i in range(np.shape(pointsList)[0]):
            pointList = pointsList[i]

            Annotations = xml_add_region(Annotations=Annotations, pointList=pointList,label_offsets=label_offsets,approx_downsample=approx_downsample, annotationID=classregion)

    # save xml
    xml_save(Annotations=Annotations, filename=xml_filename)
