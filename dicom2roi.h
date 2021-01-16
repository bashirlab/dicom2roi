//

//
//  Copyright (c) 2015 CharleChang. All rights reserved.
//

#ifndef dicom2roi_h
#define dicom2roi_h

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
#import <OsiriXAPI/browserController.h>
#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/DicomImage.h>

#import <OsiriXAPI/AppController.h>
#import <OsiriXAPI/BrowserController.h>
#import <OsiriXAPI/PluginFilter.h>

#import <OsiriXAPI/DCMObject.h>
#import <OsiriXAPI/DCMAttribute.h>
#import <OsiriXAPI/DCMAttributeTag.h>

int newviewid;
float threshold;

@interface dicom2roi : PluginFilter{
    
}

//- (void) fillROI:(ROI*) roi :(float) newVal :(float) minValue :(float) maxValue :(BOOL) outside;

@end

#endif

