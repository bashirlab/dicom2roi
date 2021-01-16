//
//  Copyright (c) 2015 CharleChang. All rights reserved.
// singleSliceMode controls whether map is generated for full or single slice

#import "roi2dicom.h"
#include <math.h>
#import <OsiriXAPI/DicomStudy.h>
#import <OsiriXAPI/DicomSeries.h>
#import <OsiriXAPI/DicomImage.h>
#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/ROI.h>
#import <OsiriXAPI/Notifications.h>
#import <OsiriXAPI/DICOMExport.h>
#import "OsiriXAPI/browserController.h"
#import <OsiriXAPI/DicomDatabase.h>


#import "LiverSegWindowController.h"
#import "LiverSegPluginFilter.h"
#import "LiverSegInfoWindowController.h"


@implementation roi2dicom

- (void) initPlugin
{
    newviewid = 0;
}


- (long) filterImage:(NSString*) menuName
{
    LiverSegWindowController* windowController = [[LiverSegWindowController alloc] loadLiverSegPlugin];
    windowController.generatePDFF = self;
    
    return 0;
}

- (void) generatePDFF//: (float) maxVolume
{
    //int maxVolumeTest = (int)maxVolume;
    //int maxVolumeTest = maxVolume;
    NSLog(@"maxVolume pdff test: %d",maxVolume);
    NSWindowController *window = [[NSWindowController alloc] init];//initWithWindowNibName:@"MainTools" owner:self];
        [window showWindow:self];
        /*
        return 0;
    }


    - (long) doCalculation//:(NSString*) menuName
    //- (IBAction) doCalculation:(id)sender
    {
        //NSWindowController *window = [[NSWindowController alloc] initWithWindowNibName:@"MainTools" owner:self];
        //[window showWindow:self];
        */
        
        NSArray     *displayedViewers = [ViewerController getDisplayed2DViewers];
        
        
        // Check the data is enough or not
        if ([displayedViewers count] < 6){
            NSRunInformationalAlertPanel(@"Warning !", @"Six Echoes Data Must be Selected in Asending Order of TE!", @"Stop Calculating", nil, nil);
            //return 0;
        }
        
        ViewerController    *Viewer1 = [displayedViewers objectAtIndex:0];
        ViewerController    *Viewer2 = [displayedViewers objectAtIndex:1];
        ViewerController    *Viewer3 = [displayedViewers objectAtIndex:2];
        ViewerController    *Viewer4 = [displayedViewers objectAtIndex:3];
        ViewerController    *Viewer5 = [displayedViewers objectAtIndex:4];
        ViewerController    *Viewer6 = [displayedViewers objectAtIndex:5];
        ViewerController    *new2DViewer;
        ViewerController    *new2DViewer2;
        if ([displayedViewers count] != 8){
            newviewid = 0; // if switch to another Exam
        }
        // [Viewer1 sortSeriesByValue:@"Slice Location" ascending:1];
        
        NSArray *pixList1 = [Viewer1 pixList];
        NSArray *pixList2 = [Viewer2 pixList];
        NSArray *pixList3 = [Viewer3 pixList];
        NSArray *pixList4 = [Viewer4 pixList];
        NSArray *pixList5 = [Viewer5 pixList];
        NSArray *pixList6 = [Viewer6 pixList];
        
        //NewStuff
        
        
        
        
        


        
        NSMutableArray *TEvalues = [[NSMutableArray alloc] initWithCapacity:0];
        
        DCMPix* curPix1 = [ [ Viewer1 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj1 = [DCMObject objectWithContentsOfFile:[curPix1 sourceFile] decodingPixelData:NO];
        
        DCMAttributeTag *MagneticFieldStrengthTag = [DCMAttributeTag tagWithName:@"MagneticFieldStrength"];
        float EchoFix;
        float MagneticFieldStrength   = [[[[dcmObj1 attributeForTag:MagneticFieldStrengthTag] value] description] doubleValue];
        if (MagneticFieldStrength<2)
            EchoFix = 2;
        else
            EchoFix = 1;
        
        
        DCMAttributeTag *sliceLoc = [DCMAttributeTag tagWithName:@"SliceLocation"];
        float sliceFlow1 = [[[[dcmObj1 attributeForTag:sliceLoc] value] description] doubleValue];
        DCMPix* curPix1b = [ [ Viewer1 pixList ] objectAtIndex : 1 ];
        DCMObject *dcmObj1b = [DCMObject objectWithContentsOfFile:[curPix1b sourceFile] decodingPixelData:NO];
        float sliceFlow2 = [[[[dcmObj1b attributeForTag:sliceLoc] value] description] doubleValue];
        //NSLog(@"slice1: %f",sliceFlow1);
        //NSLog(@"slice2: %f",sliceFlow2);
        if (sliceFlow2>sliceFlow1){
            int sliceFlow = 0;
            NSLog(@"sliceFlow forward: %d",sliceFlow);
        }else{
            int sliceFlow = 1;
            NSLog(@"sliceFlow backward: %d",sliceFlow);
        }
        
        
        
        DCMAttributeTag *EchoTimeTag1 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime1 = [[[[dcmObj1 attributeForTag:EchoTimeTag1] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime1/EchoFix]];
        
        DCMPix* curPix2 = [ [ Viewer2 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj2 = [DCMObject objectWithContentsOfFile:[curPix2 sourceFile] decodingPixelData:NO];
        DCMAttributeTag *EchoTimeTag2 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime2 = [[[[dcmObj2 attributeForTag:EchoTimeTag2] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime2/EchoFix]];
        
        DCMPix* curPix3 = [ [ Viewer3 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj3 = [DCMObject objectWithContentsOfFile:[curPix3 sourceFile] decodingPixelData:NO];
        DCMAttributeTag *EchoTimeTag3 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime3 = [[[[dcmObj3 attributeForTag:EchoTimeTag3] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime3/EchoFix]];
        
        DCMPix* curPix4 = [ [ Viewer4 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj4 = [DCMObject objectWithContentsOfFile:[curPix4 sourceFile] decodingPixelData:NO];
        DCMAttributeTag *EchoTimeTag4 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime4 = [[[[dcmObj4 attributeForTag:EchoTimeTag4] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime4/EchoFix]];
        
        DCMPix* curPix5 = [ [ Viewer5 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj5 = [DCMObject objectWithContentsOfFile:[curPix5 sourceFile] decodingPixelData:NO];
        DCMAttributeTag *EchoTimeTag5 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime5 = [[[[dcmObj5 attributeForTag:EchoTimeTag5] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime5/EchoFix]];
        
        DCMPix* curPix6 = [ [ Viewer6 pixList ] objectAtIndex : 0 ];
        DCMObject *dcmObj6 = [DCMObject objectWithContentsOfFile:[curPix6 sourceFile] decodingPixelData:NO];
        DCMAttributeTag *EchoTimeTag6 = [DCMAttributeTag tagWithName:@"EchoTime"];
        float EchoTime6 = [[[[dcmObj6 attributeForTag:EchoTimeTag6] value] description] doubleValue];
        [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime6/EchoFix]];
        
        
        
        int i;
        int NumOfEchoes = 6;
        int SingleSliceMode = 1; // calculate only one slice
        int ChooseThisSlice = 0;
        int sliceCount;
        int sliceStart;
        int pixWidth    = [[pixList1 objectAtIndex:0] pwidth];
        int pixHeight   = [[pixList1 objectAtIndex:0] pheight];
        int TotalSlice  = [pixList1 count];
        
        if( SingleSliceMode == 1){
            sliceStart = maxVolume;
            NSLog(@"sliceStart: %d",sliceStart);
            sliceCount  = sliceStart + 1;

            NSLog(@"sliceCount: %d",sliceCount);
        } else {
            sliceStart = 0;
            sliceCount  = TotalSlice;
        }
        
        //ChooseThisSlice = [[Viewer1 imageView] curImage];
        
        // Find the slice ordering
       
        
        //[textField2 setStringValue:@"After new2DViewer"];
        
        // new2DViewer = [self duplicateCurrent2DViewerWindow];
        if ( newviewid == 0 ){
            // create parameters from open viewer
            NSArray     *displayedViewers = [ViewerController getDisplayed2DViewers];
            ViewerController    *Viewer1 = [displayedViewers objectAtIndex:0];
            
            
            NSArray *pixList1 = [Viewer1 pixList];
            
            
            // Make a new viwer with empty contents first
            NSMutableData   *volumeDatatmp     = [[NSMutableData alloc] initWithLength:0];
            NSMutableArray  *pixListtmp        = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableData   *volumeDatatmp2     = [[NSMutableData alloc] initWithLength:0];
            NSMutableArray  *pixListtmp2        = [[NSMutableArray alloc] initWithCapacity:0];
            
            
            float pixelSpacingX = [[pixList1 objectAtIndex:0] pixelSpacingX];
            float pixelSpacingY = [[pixList1 objectAtIndex:0] pixelSpacingY];
            float originX = [[pixList1 objectAtIndex:0] originX];
            float originY = [[pixList1 objectAtIndex:0] originY];
            float originZ = [[pixList1 objectAtIndex:0] originZ];
            int   colorDepth = 32;
            
            long mem = pixWidth * pixHeight * sliceCount * 4;
            // 4 Byte = 32 Bit Farbwert
            float *fVolumePtr  = malloc(mem);
            float *fVolumePtr2  = malloc(mem);
            
        
            for( i = sliceStart; i < sliceCount; i++)
            {
                long size = sizeof( float) * pixWidth * pixHeight;
                float *imagePtr = malloc( size);
                float *imagePtr2 = malloc( size);
                DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
                DCMPix *emptyPix2 = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
                free( imagePtr);
                free( imagePtr2);
                [pixListtmp addObject: emptyPix];
                [pixListtmp2 addObject: emptyPix2];
            }
            
            if( fVolumePtr)
            {
                volumeDatatmp  = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
                volumeDatatmp2 = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr2 length:mem freeWhenDone:YES];
            }
            
            //[textField setStringValue:@"before newfileArray"];
            NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
            NSMutableArray *newFileArray2 = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
            //[textField setStringValue:@"before new2DViewer"];
            new2DViewer  = [viewerController newWindow:pixListtmp  :newFileArray :volumeDatatmp ];
            new2DViewer2 =[viewerController newWindow:pixListtmp2  :newFileArray2 :volumeDatatmp2];
            
            newviewid = 1;
        } else {
            new2DViewer  = [displayedViewers objectAtIndex:6];
            new2DViewer2 = [displayedViewers objectAtIndex:7];
        }
        
        int     x, zSize, icounter;
        float   *fImage, *fImageNew, *fImageNew2;
        NSArray *pixList1New, *pixList2New;
        DCMPix  *currPix;
        DCMPix  *currPixNew, *currPixNew2;
        float   tmpPix[NumOfEchoes];
        int     threshold;
        double y_dat[6];
        double p[3];
        int SmartGuess = 1;
        
        tmpPix[0] = [[TEvalues objectAtIndex:0] floatValue];
        tmpPix[1] = [[TEvalues objectAtIndex:1] floatValue];
        tmpPix[2] = [[TEvalues objectAtIndex:2] floatValue];
        tmpPix[3] = [[TEvalues objectAtIndex:3] floatValue];
        tmpPix[4] = [[TEvalues objectAtIndex:4] floatValue];
        tmpPix[5] = [[TEvalues objectAtIndex:5] floatValue];
        //threshold = [textThreshold integerValue];
        //[textThreshold setIntValue:10];
        threshold = 5;//[textThreshold integerValue];
        
        
        pixList1New = [new2DViewer pixList]; // For fat-fraction
        pixList2New = [new2DViewer2 pixList]; // For R2-star
        
        zSize       = [pixList1 count];
        if (SingleSliceMode == 1)
        {
            icounter    = ChooseThisSlice;
        } else {
            icounter    = 0;
        }
        
        id waitWindow = [viewerController startWaitProgressWindow:@"Calculating ..." :pixWidth*pixHeight*sliceCount];

        
        
        for(i = sliceStart; i < sliceCount; i++)
        {
            if (sliceFlow==1){
                //NSLog(@"slice forward");
                currPixNew  =[pixList1New   objectAtIndex:i];
                currPixNew2 =[pixList2New   objectAtIndex:i];
            }else{
                NSLog(@"slice backward: %d",i);
                NSLog(@"print sliceStart: %d",sliceStart);
                NSLog(@"slice sliceCount: %d",sliceCount);
                currPixNew  =[pixList1New   objectAtIndex:sliceCount-1-i];
                currPixNew2 =[pixList2New   objectAtIndex:sliceCount-1-i];
            }
            
            
            //fImage      =[currPix1   fImage];
            fImageNew   =[currPixNew fImage];
            fImageNew2  =[currPixNew2 fImage];
            x           =[currPixNew pheight]*[currPixNew pwidth];
            
            while (x-- > 0) { // pixel by pixel fitting
                
                currPix =   [pixList2  objectAtIndex:i];
                fImage = [currPix   fImage];
                
                if( (int)fImage[x] > threshold){
                    
                    currPix =   [pixList1  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[0] = fImage[x];
                    currPix =   [pixList2  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[1] = fImage[x];
                    currPix =   [pixList3  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[2] = fImage[x];
                    currPix =   [pixList4  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[3] = fImage[x];
                    currPix =   [pixList5  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[4] = fImage[x];
                    currPix =   [pixList6  objectAtIndex:i];
                    fImage = [currPix   fImage]; y_dat[5] = fImage[x];
                    
                    // Initialize the guessing parameters
                    if ( SmartGuess == 1){
                        double p0[2] = {0.0, 0.0};
                        double y_dat0[3] = {y_dat[1], y_dat[3], y_dat[5]};
                        float t0[3] = {tmpPix[1], tmpPix[3], tmpPix[5]};
                        
                        linefit( p0, y_dat0, t0, NumOfEchoes/2);
                        
                        // check the fitting
                        if ( (p0[0]==0) && (p0[1]==0) ){ // fail
                            p[0] = y_dat[0]*1.2;
                            p[1] = y_dat[0]*0.2;
                            p[2] = 1/80.0;
                        } else {
                            float Sw = (y_dat[1] + y_dat[0])/2.0;
                            float Sf = (y_dat[1] - y_dat[0])/2.0;
                            float ff = Sf/(Sf + Sw);
                            float wf = Sw/(Sf + Sw);
                            p[0] = p0[1]*wf;
                            p[1] = p0[1]*ff;
                            p[2] = p0[0];
                        }
                        
                    } else {
                        p[0] = y_dat[0]*1.2;
                        p[1] = y_dat[0]*0.2;
                        p[2] = 1/80.0;
                    }
                    
                    
                    // ========== start fitting ===========
                    
                    lm_fw( y_dat, tmpPix, p, NumOfEchoes);
                    
                    
                    
                    
                    fImageNew[x] = (int)(1000.0*p[1]/(p[0]+p[1])); // fat fraction
                    fImageNew2[x] = (int)(10000.0*p[2]); // R2 star

                    
                } // within threshold
                else
                {
                    fImageNew[x] = 0; // fat fraction
                    fImageNew2[x] = 0; // R2 star
                }
                
                // increase the wait bar
                [viewerController waitIncrementBy:waitWindow :1];
                
            } // pixel loop
            
        } // slice loop
        
        
        [new2DViewer    needsDisplayUpdate ];
        [new2DViewer2    needsDisplayUpdate ];
        [viewerController endWaitWindow:waitWindow];
        //[self doCalculation: nil];
        //startfix
        
        //[[LiverSegWindowController alloc] loadLiverSegPlugin];
}

/*
- (id) loadPDFFPlugin
{
    
    NSWindowController *window = [[NSWindowController alloc] init];//initWithWindowNibName:@"MainTools" owner:self];
    [window showWindow:self];
    
    return 0;
}


- (long) doCalculation:(NSString*) menuName
- (IBAction) doCalculation:(id)sender
{
    NSWindowController *window = [[NSWindowController alloc] initWithWindowNibName:@"MainTools" owner:self];
    [window showWindow:self];
    
    
    NSArray     *displayedViewers = [ViewerController getDisplayed2DViewers];
    
    
    // Check the data is enough or not
    if ([displayedViewers count] < 6){
        NSRunInformationalAlertPanel(@"Warning !", @"Six Echoes Data Must be Selected in Asending Order of TE!", @"Stop Calculating", nil, nil);
        //return 0;
    }
    
    ViewerController    *Viewer1 = [displayedViewers objectAtIndex:0];
    ViewerController    *Viewer2 = [displayedViewers objectAtIndex:1];
    ViewerController    *Viewer3 = [displayedViewers objectAtIndex:2];
    ViewerController    *Viewer4 = [displayedViewers objectAtIndex:3];
    ViewerController    *Viewer5 = [displayedViewers objectAtIndex:4];
    ViewerController    *Viewer6 = [displayedViewers objectAtIndex:5];
    ViewerController    *new2DViewer;
    ViewerController    *new2DViewer2;
    if ([displayedViewers count] != 8){
        newviewid = 0; // if switch to another Exam
    }
    // [Viewer1 sortSeriesByValue:@"Slice Location" ascending:1];
    
    NSArray *pixList1 = [Viewer1 pixList];
    NSArray *pixList2 = [Viewer2 pixList];
    NSArray *pixList3 = [Viewer3 pixList];
    NSArray *pixList4 = [Viewer4 pixList];
    NSArray *pixList5 = [Viewer5 pixList];
    NSArray *pixList6 = [Viewer6 pixList];
    
    //NewStuff
    
    
    
    
    


    
    NSMutableArray *TEvalues = [[NSMutableArray alloc] initWithCapacity:0];
    
    DCMPix* curPix1 = [ [ Viewer1 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj1 = [DCMObject objectWithContentsOfFile:[curPix1 sourceFile] decodingPixelData:NO];
    
    DCMAttributeTag *MagneticFieldStrengthTag = [DCMAttributeTag tagWithName:@"MagneticFieldStrength"];
    float EchoFix;
    float MagneticFieldStrength   = [[[[dcmObj1 attributeForTag:MagneticFieldStrengthTag] value] description] doubleValue];
    if (MagneticFieldStrength<2)
        EchoFix = 2;
    else
        EchoFix = 1;
    
    
    DCMAttributeTag *sliceLoc = [DCMAttributeTag tagWithName:@"SliceLocation"];
    float sliceFlow1 = [[[[dcmObj1 attributeForTag:sliceLoc] value] description] doubleValue];
    DCMPix* curPix1b = [ [ Viewer1 pixList ] objectAtIndex : 1 ];
    DCMObject *dcmObj1b = [DCMObject objectWithContentsOfFile:[curPix1b sourceFile] decodingPixelData:NO];
    float sliceFlow2 = [[[[dcmObj1b attributeForTag:sliceLoc] value] description] doubleValue];
    //NSLog(@"slice1: %f",sliceFlow1);
    //NSLog(@"slice2: %f",sliceFlow2);
    if (sliceFlow2>sliceFlow1){
        int sliceFlow = 0;
        //NSLog(@"sliceFlow forward: %d",sliceFlow);
    }else{
        int sliceFlow = 1;
        //NSLog(@"sliceFlow backward: %d",sliceFlow);
    }
    
    
    
    DCMAttributeTag *EchoTimeTag1 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime1 = [[[[dcmObj1 attributeForTag:EchoTimeTag1] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime1/EchoFix]];
    
    DCMPix* curPix2 = [ [ Viewer2 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj2 = [DCMObject objectWithContentsOfFile:[curPix2 sourceFile] decodingPixelData:NO];
    DCMAttributeTag *EchoTimeTag2 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime2 = [[[[dcmObj2 attributeForTag:EchoTimeTag2] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime2/EchoFix]];
    
    DCMPix* curPix3 = [ [ Viewer3 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj3 = [DCMObject objectWithContentsOfFile:[curPix3 sourceFile] decodingPixelData:NO];
    DCMAttributeTag *EchoTimeTag3 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime3 = [[[[dcmObj3 attributeForTag:EchoTimeTag3] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime3/EchoFix]];
    
    DCMPix* curPix4 = [ [ Viewer4 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj4 = [DCMObject objectWithContentsOfFile:[curPix4 sourceFile] decodingPixelData:NO];
    DCMAttributeTag *EchoTimeTag4 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime4 = [[[[dcmObj4 attributeForTag:EchoTimeTag4] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime4/EchoFix]];
    
    DCMPix* curPix5 = [ [ Viewer5 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj5 = [DCMObject objectWithContentsOfFile:[curPix5 sourceFile] decodingPixelData:NO];
    DCMAttributeTag *EchoTimeTag5 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime5 = [[[[dcmObj5 attributeForTag:EchoTimeTag5] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime5/EchoFix]];
    
    DCMPix* curPix6 = [ [ Viewer6 pixList ] objectAtIndex : 0 ];
    DCMObject *dcmObj6 = [DCMObject objectWithContentsOfFile:[curPix6 sourceFile] decodingPixelData:NO];
    DCMAttributeTag *EchoTimeTag6 = [DCMAttributeTag tagWithName:@"EchoTime"];
    float EchoTime6 = [[[[dcmObj6 attributeForTag:EchoTimeTag6] value] description] doubleValue];
    [TEvalues addObject:[NSDecimalNumber numberWithFloat:EchoTime6/EchoFix]];
    
    
    
    int i;
    int NumOfEchoes = 6;
    int SingleSliceMode = 0; // calculate only one slice
    int ChooseThisSlice = 0;
    int sliceCount;
    int pixWidth    = [[pixList1 objectAtIndex:0] pwidth];
    int pixHeight   = [[pixList1 objectAtIndex:0] pheight];
    int TotalSlice  = [pixList1 count];
    
    if( SingleSliceMode == 1){
        sliceCount  = 1;
    } else {
        sliceCount  = TotalSlice;
    }
    
    //ChooseThisSlice = [[Viewer1 imageView] curImage];
    
    // Find the slice ordering
   
    
    //[textField2 setStringValue:@"After new2DViewer"];
    
    // new2DViewer = [self duplicateCurrent2DViewerWindow];
    if ( newviewid == 0 ){
        // create parameters from open viewer
        NSArray     *displayedViewers = [ViewerController getDisplayed2DViewers];
        ViewerController    *Viewer1 = [displayedViewers objectAtIndex:0];
        
        
        NSArray *pixList1 = [Viewer1 pixList];
        
        
        // Make a new viwer with empty contents first
        NSMutableData   *volumeDatatmp     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pixListtmp        = [[NSMutableArray alloc] initWithCapacity:0];
        NSMutableData   *volumeDatatmp2     = [[NSMutableData alloc] initWithLength:0];
        NSMutableArray  *pixListtmp2        = [[NSMutableArray alloc] initWithCapacity:0];
        
        
        float pixelSpacingX = [[pixList1 objectAtIndex:0] pixelSpacingX];
        float pixelSpacingY = [[pixList1 objectAtIndex:0] pixelSpacingY];
        float originX = [[pixList1 objectAtIndex:0] originX];
        float originY = [[pixList1 objectAtIndex:0] originY];
        float originZ = [[pixList1 objectAtIndex:0] originZ];
        int   colorDepth = 32;
        
        long mem = pixWidth * pixHeight * sliceCount * 4;
        // 4 Byte = 32 Bit Farbwert
        float *fVolumePtr  = malloc(mem);
        float *fVolumePtr2  = malloc(mem);
        
    
        for( i = 0; i < sliceCount; i++)
        {
            long size = sizeof( float) * pixWidth * pixHeight;
            float *imagePtr = malloc( size);
            float *imagePtr2 = malloc( size);
            DCMPix *emptyPix = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            DCMPix *emptyPix2 = [[DCMPix alloc] initWithData: imagePtr :colorDepth :pixWidth :pixHeight :pixelSpacingX :pixelSpacingY :originX :originY :originZ];
            free( imagePtr);
            free( imagePtr2);
            [pixListtmp addObject: emptyPix];
            [pixListtmp2 addObject: emptyPix2];
        }
        
        if( fVolumePtr)
        {
            volumeDatatmp  = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr length:mem freeWhenDone:YES];
            volumeDatatmp2 = [[NSMutableData alloc] initWithBytesNoCopy:fVolumePtr2 length:mem freeWhenDone:YES];
        }
        
        //[textField setStringValue:@"before newfileArray"];
        NSMutableArray *newFileArray = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        NSMutableArray *newFileArray2 = [NSMutableArray arrayWithArray:[[viewerController fileList] subarrayWithRange:NSMakeRange(0,sliceCount)]];
        //[textField setStringValue:@"before new2DViewer"];
        new2DViewer  = [viewerController newWindow:pixListtmp  :newFileArray :volumeDatatmp ];
        new2DViewer2 =[viewerController newWindow:pixListtmp2  :newFileArray2 :volumeDatatmp2];
        
        newviewid = 1;
    } else {
        new2DViewer  = [displayedViewers objectAtIndex:6];
        new2DViewer2 = [displayedViewers objectAtIndex:7];
    }
    
    int     x, zSize, icounter;
    float   *fImage, *fImageNew, *fImageNew2;
    NSArray *pixList1New, *pixList2New;
    DCMPix  *currPix;
    DCMPix  *currPixNew, *currPixNew2;
    float   tmpPix[NumOfEchoes];
    int     threshold;
    double y_dat[6];
    double p[3];
    int SmartGuess = 1;
    
    tmpPix[0] = [[TEvalues objectAtIndex:0] floatValue];
    tmpPix[1] = [[TEvalues objectAtIndex:1] floatValue];
    tmpPix[2] = [[TEvalues objectAtIndex:2] floatValue];
    tmpPix[3] = [[TEvalues objectAtIndex:3] floatValue];
    tmpPix[4] = [[TEvalues objectAtIndex:4] floatValue];
    tmpPix[5] = [[TEvalues objectAtIndex:5] floatValue];
    //threshold = [textThreshold integerValue];
    //[textThreshold setIntValue:10];
    threshold = 5;//[textThreshold integerValue];
    
    
    pixList1New = [new2DViewer pixList]; // For fat-fraction
    pixList2New = [new2DViewer2 pixList]; // For R2-star
    
    zSize       = [pixList1 count];
    if (SingleSliceMode == 1)
    {
        icounter    = ChooseThisSlice;
    } else {
        icounter    = 0;
    }
    
    id waitWindow = [viewerController startWaitProgressWindow:@"Calculating ..." :pixWidth*pixHeight*sliceCount];

    
    
    for(i = 0; i < sliceCount; i++)
    {
        if (sliceFlow==1){
            //NSLog(@"slice forward");
            currPixNew  =[pixList1New   objectAtIndex:i];
            currPixNew2 =[pixList2New   objectAtIndex:i];
        }else{
            //NSLog(@"slice backward");
            currPixNew  =[pixList1New   objectAtIndex:sliceCount-1-i];
            currPixNew2 =[pixList2New   objectAtIndex:sliceCount-1-i];
        }
        
        
        //fImage      =[currPix1   fImage];
        fImageNew   =[currPixNew fImage];
        fImageNew2  =[currPixNew2 fImage];
        x           =[currPixNew pheight]*[currPixNew pwidth];
        
        while (x-- > 0) { // pixel by pixel fitting
            
            currPix =   [pixList2  objectAtIndex:i];
            fImage = [currPix   fImage];
            
            if( (int)fImage[x] > threshold){
                
                currPix =   [pixList1  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[0] = fImage[x];
                currPix =   [pixList2  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[1] = fImage[x];
                currPix =   [pixList3  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[2] = fImage[x];
                currPix =   [pixList4  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[3] = fImage[x];
                currPix =   [pixList5  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[4] = fImage[x];
                currPix =   [pixList6  objectAtIndex:i];
                fImage = [currPix   fImage]; y_dat[5] = fImage[x];
                
                // Initialize the guessing parameters
                if ( SmartGuess == 1){
                    double p0[2] = {0.0, 0.0};
                    double y_dat0[3] = {y_dat[1], y_dat[3], y_dat[5]};
                    float t0[3] = {tmpPix[1], tmpPix[3], tmpPix[5]};
                    
                    linefit( p0, y_dat0, t0, NumOfEchoes/2);
                    
                    // check the fitting
                    if ( (p0[0]==0) && (p0[1]==0) ){ // fail
                        p[0] = y_dat[0]*1.2;
                        p[1] = y_dat[0]*0.2;
                        p[2] = 1/80.0;
                    } else {
                        float Sw = (y_dat[1] + y_dat[0])/2.0;
                        float Sf = (y_dat[1] - y_dat[0])/2.0;
                        float ff = Sf/(Sf + Sw);
                        float wf = Sw/(Sf + Sw);
                        p[0] = p0[1]*wf;
                        p[1] = p0[1]*ff;
                        p[2] = p0[0];
                    }
                    
                } else {
                    p[0] = y_dat[0]*1.2;
                    p[1] = y_dat[0]*0.2;
                    p[2] = 1/80.0;
                }
                
                
                // ========== start fitting ===========
                
                lm_fw( y_dat, tmpPix, p, NumOfEchoes);
                
                
                
                
                fImageNew[x] = (int)(1000.0*p[1]/(p[0]+p[1])); // fat fraction
                fImageNew2[x] = (int)(10000.0*p[2]); // R2 star

                
            } // within threshold
            else
            {
                fImageNew[x] = 0; // fat fraction
                fImageNew2[x] = 0; // R2 star
            }
            
            // increase the wait bar
            [viewerController waitIncrementBy:waitWindow :1];
            
        } // pixel loop
        
    } // slice loop
    
    
    [new2DViewer    needsDisplayUpdate ];
    [new2DViewer2    needsDisplayUpdate ];
    [viewerController endWaitWindow:waitWindow];
    //[self doCalculation: nil];
    //startfix
    
    //[[LiverSegWindowController alloc] loadLiverSegPlugin];
    
    return self;
}
*/


@end





