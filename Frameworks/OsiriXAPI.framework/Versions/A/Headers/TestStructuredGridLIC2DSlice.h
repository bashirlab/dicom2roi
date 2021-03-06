/*=========================================================================

  Program:   Visualization Toolkit
  Module:    TestStructuredGridLIC2DSlice.h

  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/

#ifndef  __TestStructuredGridLIC2DSlice_h
#define  __TestStructuredGridLIC2DSlice_h

#include "vtkStructuredGridLIC2D.h"
#include "vtkPNGReader.h"
#include "vtkXMLStructuredGridReader.h"
#include "vtkExtractGrid.h"
#include "vtkRenderWindowInteractor.h"
#include "vtkRenderWindow.h"
#include "vtkRenderer.h"
#include "vtkActor.h"
#include "vtkTexture.h"
#include "vtkDataSetMapper.h"
#include "vtkTestUtilities.h"
#include "vtkRegressionTestImage.h"
#include "vtkPNGWriter.h"
#include "vtkImageShiftScale.h"
#include "vtkImageData.h"
#include "vtkPointData.h"
#include "vtkProperty.h"
#include "vtkPolyDataMapper.h"
#include "vtkDataSetSurfaceFilter.h"
#include "vtkImageExtractComponents.h"
#include "vtkTestUtilities.h"
#include "vtkCamera.h"
#include "vtkSmartPointer.h"
#include "vtkStreamingDemandDrivenPipeline.h"
#include "vtkTimerLog.h"
#include <vtksys/CommandLineArguments.hxx>
#include <string>

enum { STRUCTURED_GRID_LIC2D_SLICE_DEMO = 0, STRUCTURED_GRID_LIC2D_SLICE_TEST = 1 };
static int    RenderingMode = STRUCTURED_GRID_LIC2D_SLICE_TEST;
static double ZoomFactor    = 2.8;

#define CREATE_NEW(var, class) vtkSmartPointer<class> var = vtkSmartPointer<class>::New();
inline  int CLAMP(int a, int min, int max)
{
  a = (a < min)? min : a;
  a = (a > max)? max : a;
  return a;
}

static int StructuredGridLIC2DSlice(int argc, char* argv[])
{
  std::string filename;
  std::string noise_filename;
  int resolution = 10;
  int magnification = 1;
  std::string outputpath;
  int num_partitions = 1;
  int num_steps = 40;
  int slice_dir = 2; // 0 == X, 1 == Y, 2 == Z
  int slice = 0;

  vtksys::CommandLineArguments arg;
  arg.StoreUnusedArguments(1);
  arg.Initialize(argc, argv);

  typedef vtksys::CommandLineArguments argT;
  arg.AddArgument("--data", argT::EQUAL_ARGUMENT, &filename,
    "(required) Enter dataset to load (currently only *.vts files are supported");
  arg.AddArgument("--res", argT::EQUAL_ARGUMENT, &resolution,
    "(optional: default 10) Number of sample per unit distance");
  arg.AddArgument("--mag", argT::EQUAL_ARGUMENT, &magnification,
    "(optional: default 1) Magnification");
  arg.AddArgument("--output", argT::EQUAL_ARGUMENT, &outputpath,
    "(optional) Output png image");
  arg.AddArgument("--partitions", argT::EQUAL_ARGUMENT, &num_partitions,
    "(optional: default 1) Number of partitions");
  arg.AddArgument("--num-steps", argT::EQUAL_ARGUMENT, &num_steps,
    "(optional: default 40) Number of steps in each direction");
  arg.AddArgument("--noise", argT::EQUAL_ARGUMENT, &noise_filename,
    "(optional) Specify the filename to a png image file to use as the noise texture");
  arg.AddArgument("--slice", argT::EQUAL_ARGUMENT, &slice,
    "(optional: default 0) The slice number in the direction specified by slice-dir. "
    "This is ignored for 2D data.");
  arg.AddArgument("--slice-dir", argT::EQUAL_ARGUMENT, &slice_dir,
    "(optional: default 2 (Z slices)) The slice direction: 0 for X slices, 1 for Y slices and 2 for Z slices. "
    "This is ignored for 2D data.");

  if (!arg.Parse() || filename=="")
    {
    cerr << "Problem parsing arguments." << endl;
    cerr << arg.GetHelp() << endl;
    return 1;
    }

  if (magnification < 1)
    {
    cout << "WARNING: Magnification \'" << magnification  << "\' is invalid."
      " Forcing a magnification of 1.";
    magnification = 1;
    }

  if (num_steps < 1)
    {
    cout << "WARNING: Number of steps cannot be less than 1. Forcing 10.";
    num_steps = 10;
    }

  if (slice_dir < 0 || slice_dir > 2)
    {
    cout << "WARNING: Invalid slice-dir (" <<slice_dir<<"). Forcing Z slices";
    slice_dir = 2;
    }

  CREATE_NEW(reader, vtkXMLStructuredGridReader);
  reader->SetFileName(filename.c_str());
  reader->Update();

  int dataDesc = VTK_XY_PLANE;
  switch(slice_dir)
    {
  case 0:
    dataDesc = VTK_YZ_PLANE;
    break;
  case 1:
    dataDesc = VTK_XZ_PLANE;
    break;
  case 2:
  default:
    dataDesc = VTK_XY_PLANE;
    }

  int extent[6];
  int voi[6];
  reader->GetOutput()->GetExtent(extent);
  memcpy(voi, extent, 6*sizeof(int));

  // If data is 2D, then override the slice-dir
  if (extent[0] == extent[1])
    {
    dataDesc = VTK_YZ_PLANE;
    slice = 0;
    }
  else if (extent[2] == extent[3])
    {
    dataDesc = VTK_XZ_PLANE;
    slice = 0;
    }
  else if (extent[4] == extent[5])
    {
    dataDesc = VTK_XY_PLANE;
    slice = 0;
    }
  else
    {
    switch (dataDesc)
      {
    case VTK_XY_PLANE:
      voi[4] = voi[5] = CLAMP(extent[4]+slice, extent[4], extent[5]);
      break;

    case VTK_YZ_PLANE:
      voi[0] = voi[1] = CLAMP(extent[0]+slice, extent[0], extent[1]);
      break;

    case VTK_XZ_PLANE:
      voi[2] = voi[3] = CLAMP(extent[2]+slice, extent[2], extent[3]);
      break;
      }
    }

  CREATE_NEW(extractVOI, vtkExtractGrid);
  extractVOI->SetInputConnection(reader->GetOutputPort());
  extractVOI->SetVOI(voi);

  CREATE_NEW(renWin, vtkRenderWindow);
  CREATE_NEW(renderer, vtkRenderer);
  renWin->AddRenderer(renderer);
  CREATE_NEW(iren, vtkRenderWindowInteractor);
  iren->SetRenderWindow(renWin);

  renWin->Render();

  CREATE_NEW(filter, vtkStructuredGridLIC2D);
  if (  filter->SetContext( renWin ) == 0  )
    {
    cout << "Required OpenGL extensions / GPU not supported." << endl;
    return 0;
    }
    
  filter->SetInputConnection(extractVOI->GetOutputPort());

  if (noise_filename != "")
    {
    CREATE_NEW(pngReader, vtkPNGReader);
    pngReader->SetFileName(noise_filename.c_str());
    filter->SetInputConnection(1, pngReader->GetOutputPort(0));
    }

  filter->SetSteps(num_steps);
  filter->SetStepSize(0.01/magnification);
  filter->SetMagnification(magnification);
  
  for (int kk=0; kk < num_partitions; kk++)
    {
    vtkStreamingDemandDrivenPipeline * sddp = 
      vtkStreamingDemandDrivenPipeline::SafeDownCast(filter->GetExecutive());
    sddp->SetUpdateExtent(0, kk, num_partitions, 0);

    cout << "*****************" << endl;
    filter->Update();
    if (  filter->GetFBOSuccess() == 0 ||
          filter->GetLICSuccess() == 0  )
      {
      sddp = NULL;
      return 0;
      }

    CREATE_NEW(clone, vtkImageData);
    clone->ShallowCopy(filter->GetOutputDataObject(1));
    
    double range[2];
    clone->GetPointData()->GetScalars()->GetRange(range);
    CREATE_NEW(caster, vtkImageShiftScale);
    caster->SetInput(clone);
    caster->SetOutputScalarTypeToUnsignedChar();
    caster->SetShift(-range[0]);
    caster->SetScale(255.0/(range[1]-range[0]));
    caster->Update();
    

    //vtkPNGWriter* writer = vtkPNGWriter::New();
    //writer->SetFileName("/private/tmp/lic.png");
    //writer->SetInputConnection(caster->GetOutputPort());
    //writer->Write();
    //writer->Delete();

    CREATE_NEW(texture, vtkTexture);
    texture->SetInputConnection(caster->GetOutputPort());

    CREATE_NEW(clone2, vtkStructuredGrid);
    clone2->ShallowCopy(filter->GetOutput(0));

    CREATE_NEW(surfaceFilter, vtkDataSetSurfaceFilter);
    surfaceFilter->SetInput(clone2);

    CREATE_NEW(mapper, vtkPolyDataMapper);
    mapper->SetInputConnection(surfaceFilter->GetOutputPort());
    mapper->SetScalarVisibility(0);
    
    CREATE_NEW(actor, vtkActor);
    actor->SetMapper(mapper);
    actor->SetTexture(texture);

    renderer->AddActor(actor);
    }

  CREATE_NEW(tester, vtkTesting);
  for (int cc=0; cc < argc; cc++)
    {
    tester->AddArgument(argv[cc]);
    }
  tester->SetRenderWindow(renWin);

  renderer->SetBackground(0.2,0.1,0.2);
  renderer->ResetCamera();
  renderer->GetActiveCamera()->Zoom( ZoomFactor );
  
  if ( RenderingMode == STRUCTURED_GRID_LIC2D_SLICE_TEST )
    {
    switch (dataDesc)
      {
      case VTK_YZ_PLANE:
        renderer->GetActiveCamera()->Azimuth(90);
        break;
      case VTK_XZ_PLANE:
        renderer->GetActiveCamera()->Elevation(90);
        break;
      }
    }

 renWin->Render();
 int reply = (!tester->IsValidImageSpecified() || 
   (tester->RegressionTest(10) == vtkTesting::PASSED))? /*success*/ 0 : /*failure*/ 1;
   
 if (tester->IsInteractiveModeSpecified())
   {
   iren->Start();
   }
 
  if ( RenderingMode != STRUCTURED_GRID_LIC2D_SLICE_TEST )
    {
    iren->Start();
    }

 return reply;
}

#endif 
