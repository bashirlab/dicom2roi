/*=========================================================================
 Program:   OsiriX
 Copyright (c) 2010 - 2019 Pixmeo SARL
 266 rue de Bernex
 CH-1233 Bernex
 Switzerland
 All rights reserved.
 =========================================================================*/

#import <Cocoa/Cocoa.h>
//#include <boost/numeric/ublas/matrix.hpp>

@interface NSHost (N2)

+(NSHost*)hostWithAddressOrName:(NSString*)str;

@end

