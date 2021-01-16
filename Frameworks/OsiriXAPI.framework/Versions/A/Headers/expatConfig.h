#include "vtk_expat_mangle.h"
#if defined(_WIN32) || defined(WIN32)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#undef WIN32_LEAN_AND_MEAN
#include <memory.h>
#include <string.h>
#define XML_BYTE_ORDER 12

#else

/* All compilers that support Mac OS X define either __BIG_ENDIAN__ or
   __LITTLE_ENDIAN__ to match the endianness of the architecture being
   compiled for. This is not necessarily the same as the architecture of the
   machine doing the building. In order to support Universal Binaries on
   Mac OS X, we prefer those defines to decide the endianness.
   On other platforms we use the result of the TRY_RUN. */
#if !defined(__APPLE__)
/* #undef CMAKE_WORDS_BIGENDIAN */
#elif defined(__BIG_ENDIAN__)
#  define CMAKE_WORDS_BIGENDIAN
#endif

#ifdef CMAKE_WORDS_BIGENDIAN
#  define XML_BYTE_ORDER 21
#else
#  define XML_BYTE_ORDER 12
#endif

#endif

#define XML_NS
#define XML_DTD
#define XML_CONTEXT_BYTES 1024

#if defined ( _MSC_VER )
#pragma warning ( disable : 4100 )
#pragma warning ( disable : 4127 )
#pragma warning ( disable : 4244 )
#pragma warning ( disable : 4251 )
#pragma warning ( disable : 4305 )
#pragma warning ( disable : 4309 )
#pragma warning ( disable : 4702 )
#pragma warning ( disable : 4706 )
#pragma warning ( disable : 4786 )
#pragma warning ( disable : 4057 )
#pragma warning ( disable : 4189 )
#pragma warning ( disable : 4505 )
#endif

#define VERSION "1.95.2"

#define vtkExpatUnused(x) (void)x
