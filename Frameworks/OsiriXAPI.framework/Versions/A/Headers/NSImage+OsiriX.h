/*=========================================================================
 Program:   OsiriX
 Copyright (c) 2010 - 2019 Pixmeo SARL
 266 rue de Bernex
 CH-1233 Bernex
 Switzerland
 All rights reserved.
 =========================================================================*/

#import <Cocoa/Cocoa.h>

@interface NSImage (OsiriX)

-(NSData*)JPEGRepresentation;
-(NSData*)JPEGRepresentationWithQuality:(CGFloat)quality;

-(NSData*)PDFRepresentation;
@end

