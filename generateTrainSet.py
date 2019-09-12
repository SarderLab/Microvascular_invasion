import glob
import numpy as np
import os
from cv2 import imread,imwrite

txt_loc='/hdd/BG_projects/Microvascular_inflammation/Deeplab-v2--ResNet-101--Tensorflow-master/dataset/train.txt'
#os.remove(txt_loc)

#os.remove('test.txt')
f=open(txt_loc,'w')
f.close()


imageDir='/hdd/BG_projects/Microvascular_inflammation/chopped_images/images/'
maskDir='/hdd/BG_projects/Microvascular_inflammation/chopped_images/masks/'

writeImDir='/images/'
writemaskDir='/masks/'

trainingNames=glob.glob(imageDir + '*.png')

totalImages=len(trainingNames)


for im in range(0,totalImages):
    fileID=trainingNames[im].split('/')
    fileID=fileID[len(fileID)-1]
    fileID=fileID.split('.png')
    fileID=fileID[0]
    if ' ' in fileID:

        print(fileID)
        fileparts=fileID.split(' ')
        fileID2 = fileparts[0]
        for filestr in fileparts[1:]:
            fileID2 = fileID2 + filestr
        print(fileID2)
        print(maskDir + fileID + '.png')
        print(maskDir + fileID2 + '.png')
        os.rename(imageDir + fileID + '.png',imageDir + fileID2 + '.png')
        os.rename(maskDir + fileID + '.png',maskDir + fileID2 + '.png')


trainingNames=glob.glob(imageDir + '*.png')

totalImages=len(trainingNames)



for im in range(0,totalImages):
    fileID=trainingNames[im].split('/')
    fileID=fileID[len(fileID)-1]
    fileID=fileID.split('.png')
    fileID=fileID[0]



    imagename=writeImDir + fileID + '.png'
    maskname=writemaskDir + fileID + '_mask.png'

    f=open(txt_loc,'a')
    f.write(imagename + ' ' + maskname + '\n')
    f.close()
