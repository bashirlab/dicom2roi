/*
 *  maskAnalyze.c
 *  CreateROIMask plugin
 *
 * This code has been written using a copyright code
 *
 * (c) Copyright, 1986-1995
 * Biomedical Imaging Resource
 * Mayo Foundation
 *
 */

//#include "maskAnalyze.h"
#include <stdio.h>
#include <string.h>
#include "Analyze.h"


/** writeAnalyzeHeader: to write the header file of an Analyze image
 * @param filename: name of the header file
 * @param dim[3] 3 dimensions of the data
 * @param pixdim[3] voxel dimensions (width, height and thickness)
 */
int writeAnalyzeHeader(const char* filename, int dim[3], float pixdim[3])
{
	int i;
	struct dsr hdr;
	
	
	//char filehdr[100];
	/*strcpy(filehdr, basename);
	strcpy(fileimg, basename);
	
	strcpy(filehdr, ".hdr");
	strcpy(fileimg, ".img");*/
	
	FILE *fp;
	
	memset(&hdr, 0, sizeof(struct dsr));

	for(i=0;i<8;i++) {
		hdr.dime.pixdim[i] = 0.0;
	}
	hdr.dime.vox_offset  = 0.0;
	hdr.dime.funused1    = 0.0;
	hdr.dime.funused2    = 0.0;
	hdr.dime.funused3    = 0.0;
	hdr.dime.cal_max     = 0.0;
	hdr.dime.cal_min     = 0.0;
	
	// unsigned char, 1 octet, 8 bits. value between 0 and 255
	hdr.dime.datatype = DT_UNSIGNED_CHAR ;
	hdr.dime.bitpix = 8;
	
	if((fp = fopen(filename, "w"))==0)
	{
		return 1; // unable to create the header file
	}
	
	// dimensions
	hdr.dime.dim[0] = 4;
	hdr.dime.dim[1] = dim[0];
	hdr.dime.dim[2] = dim[1];
	hdr.dime.dim[3] = dim[2];
	hdr.dime.dim[4] = 1 ;
	
	hdr.hk.regular = 'r';
	hdr.hk.sizeof_hdr = sizeof(struct dsr);
	
	// max end min values
	hdr.dime.glmax = 255;
	hdr.dime.glmin = 0;
	
	/*     Set the voxel dimension fields: 
	 A value of 0.0 for these fields implies that the value is unknown.
	 Change these values to what is appropriate for your data
	 or pass additional command line arguments     */   
	hdr.dime.pixdim[1] = pixdim[0];
    hdr.dime.pixdim[2] = pixdim[1];
    hdr.dime.pixdim[3] = pixdim[2];

	/*   Assume zero offset in .img file, byte at which pixel
	 data starts in the image file */
	hdr.dime.vox_offset = 0.0;
	
	/*   Planar Orientation;    */
	/*   Movie flag OFF: 0 = transverse, 1 = coronal, 2 = sagittal
     Movie flag ON:  3 = transverse, 4 = coronal, 5 = sagittal  */  
	
    hdr.hist.orient     = 0;  
	
	/*   up to 3 characters for the voxels units label; i.e. mm., um., cm. */
	
   // strcpy(hdr.dime.vox_units,"mm."); // ? or nothing?
	
	/*   up to 7 characters for the calibration units label; i.e. HU */
	
    //strcpy(hdr.dime.cal_units," "); 
	
	/*     Calibration maximum and minimum values;  
	 values of 0.0 for both fields imply that no 
	 calibration max and min values are used    */
	
    hdr.dime.cal_max = 0.0; 
    hdr.dime.cal_min = 0.0;
	
	fwrite(&hdr, sizeof(struct dsr), 1, fp);
	fclose(fp);
	
	
 return 0;
}


