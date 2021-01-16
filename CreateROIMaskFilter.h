//
//  CreateROIMaskFilter.h
//  CreateROIMask
//
//  Copyright (c) 2009 Aurelie Canale - INRIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginFilter.h"

/** \brief CreateROIMask plugin
 
 In the "plugin" menu, in "database" : CreateROIMask.
 This plugin convert segmented volumes or rois_series files into binary volume saved in an Analyze file.
 */

@interface CreateROIMaskFilter : PluginFilter {

}

- (long) filterImage:(NSString*) menuName;

- (long) createMaskFromDB;
- (long) createMaskFromFolders;

// Auxiliary functions

/** writeAnalyze: to write the data in an analyze file 
 * @param basename base of the complete path where to save the data. The files basename.hdr and basename.img will be created
 * @param dim[3] 3 dimensions of the data
 * @param pixdim[3] voxel dimensions (width, height and thickness)
 * @param dcmPixList Array of 2D slices containing the data (float)
 * @param orientation int that contains the value 1 if the slices are ordered following increasing z, 0 in the other case. In the case of orientation == 0
 (decreasing z) the slices of the mask will be written from the last slice to the first one
 * return 0 if no errors, else 1
 */
- (long) writeAnalyze: (NSString *) basename dim: (int *) dim pixdim: (float *) pixdim data: (NSMutableArray *) dcmPixList orientation: (int) orientation ;

/** createVolume: using a dicom directory, it read the dimensions of the dicom series and create a black volume (list of 2D slices) with the same dimensions
 * @param dcmDir path for the directory containing the dicom files
 * @param dim[3] will contain the dimensions of the dicom series at the end of the method
 * @param pixdim[3]  will contain at the end of the process the voxel dimensions (width, height and thickness)
 * @param origin[2] that will contain the origin coordinates of the slices at the end of the method
 * @param dcmPixList will contain the created volume at the end of the method
 * @param orientation pointer on an int that will contain the value 1 if the slices are ordered following increasing z, 0 in the other case. In the case of orientation == 0
   (decreasing z) the slices of the mask will be written from the last slice to the first one
 * return 0 if no errors, else 1
 */
- (long) createVolume: (NSString *) dcmDir dim: (int *) dim pixdim: (float *) pixdim origin: (float *) origin data: (NSMutableArray *) dcmPixList orientation: (int *) orientation ;


@end
