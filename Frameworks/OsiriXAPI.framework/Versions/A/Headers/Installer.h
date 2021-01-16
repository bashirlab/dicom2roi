/*=========================================================================
 Program:   OsiriX
 Copyright (c) 2010 - 2019 Pixmeo SARL
 266 rue de Bernex
 CH-1233 Bernex
 Switzerland
 All rights reserved.
 =========================================================================*/

#import <Cocoa/Cocoa.h>

#define REGPHPURL @"reg/reg.php"
//#define REGPHPOVHURL @"reg/min/index.php"
#define WSPHPURL @"ws/ws.php"

#define OsiriXMDSubscriptionProductID 244

@interface Installer : NSWindowController <NSApplicationDelegate>
{
	IBOutlet NSTextField *regKey;
    IBOutlet NSTextField *previousRegKey;
    IBOutlet NSWindow *license;
    NSAttributedString *licenseText;
    
    IBOutlet NSWindow *previousKeyWindow;
    IBOutlet NSPanel *installingPanel;
    IBOutlet NSProgressIndicator *spinning;
    
    NSString *previousKey, *windowTitle, *installText, *pleaseWaitText;
    
    IBOutlet NSPopUpButton *availableKeysMenu;
    IBOutlet NSPopUpButton *availablePreviousKeysMenu;
}

@property (readonly) NSAttributedString *licenseText;
@property (retain) NSString *previousKey;
@property (readonly) NSString *windowTitle, *installText, *pleaseWaitText;
@property( readonly) NSPopUpButton *availablePreviousKeysMenu;

+ (BOOL) isANVISAProductID: (int) pID;
+ (BOOL) isMDProductID: (int) pID;
+ (NSString*) productName: (int) pID;
+ (BOOL) isProductValid: (int) pID;
+ (void) dylibRegisterAPI;
+ (NSArray*) getAvailableKeys;
+ (void) buildKeysPopUpMenu:(NSArray*) keys menu:(NSMenu*) menu;

- (IBAction) install:(id) sender;
- (IBAction) cancelModal:(id)sender;
- (IBAction) okModal:(id)sender;
- (IBAction) saveModal:(id)sender;

+ (NSString*) installWithRegKey: (NSString*) reg previousKey: (NSString*) previousKey noGUI: (BOOL) noGUI windowController: (Installer*) windowController;
@end
