//
//  Copyright (c) 2015 CharleChang. All rights reserved.
// singleSliceMode controls whether map is generated for full or single slice

#import "dicom2roi.h"
#include <math.h>
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/DicomImage.h>
#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/DICOMExport.h>
#import <OsiriXAPI/browserController.h>
#import <OsiriXAPI/DicomDatabase.h>

#import <OsiriXAPI/DCMObject.h>
#import <OsiriXAPI/DCMAttribute.h>
#import <OsiriXAPI/DCMAttributeTag.h>


@implementation dicom2roi

- (void) initPlugin
{
    newviewid = 0;
    NSLog( @"Init dicom2roi");
}

- (long) filterImage:(NSString*) menuName
{

    NSArray     *displayedViewers = [ViewerController getDisplayed2DViewers];
    ViewerController    *viewerController = [displayedViewers objectAtIndex:1];
    ViewerController    *viewerControllerScan = [displayedViewers objectAtIndex:0];

    [[viewerController  imageView] scaleToFit];
    [viewerController    needsDisplayUpdate];

    NSArray *pixList = [viewerController pixList];

    int i;
    int sliceStart  = 0;
    int sliceCount  = [pixList count];

    for( i = sliceStart; i < sliceCount; i++)
    {
        DCMPix    *curPix = [[viewerController pixList] objectAtIndex:i];
        float    *fImage = [curPix fImage];
        BOOL    RoiEmpty = TRUE;
        NSString *ThresholdROIName = @"dicom2roi";
        float threshold = 0.5;
        
        // create array with the same size as the current image
        float            SumOfPixel = [curPix pwidth] * [curPix pheight];
        unsigned char    *textureBuffer = (unsigned char*)malloc(SumOfPixel*sizeof(unsigned char));
        
        for (int x = 0; x< SumOfPixel; x++)
        {
            
            if ((fImage[x] >= threshold))
            {
                textureBuffer[x] = 0xFF;
                RoiEmpty = FALSE;
            }
            else
            {
                textureBuffer[x] = 0x00;
            }
            
        }
        
        if (!RoiEmpty)
        {
            ROI        *thresholdROI = nil;
            
            thresholdROI = [[[ROI alloc] initWithTexture:textureBuffer
                                               textWidth:[curPix pwidth] textHeight:[curPix pheight]
                                                textName:ThresholdROIName positionX:0 positionY:0
                                                spacingX:[curPix pixelSpacingX]
                                                spacingY:[curPix pixelSpacingY]
                                             imageOrigin:NSMakePoint( [curPix originX],
                                                                     [curPix originY])] autorelease];
            
            NSMutableArray    *roiImageList = [[viewerController roiList] objectAtIndex: i];
//            NSMutableArray    *roiImageList2 = [[viewerControllerScan roiList] objectAtIndex: sliceCount - i - 1];
            NSMutableArray    *roiImageList2 = [[viewerControllerScan roiList] objectAtIndex: i];
            
            [roiImageList addObject: thresholdROI];
            [roiImageList2 addObject: thresholdROI];
            
            
        }
        
 
        free(textureBuffer);
  
    }
    
    [viewerController needsDisplayUpdate];
    [viewerControllerScan needsDisplayUpdate];
    
    // don't forget to free the memory !!!
    
    [viewerController close];
    
    return 0;
}



@end






