/* TopologyController */

#import <Cocoa/Cocoa.h>
#import "TopologyView.h"
#import "Port.h"

@class UDPMain;

@interface TopologyController : NSObject
{
    UDPMain* udpSender;
    UDPMain* udpReceiver;
    
    
	IBOutlet TopologyView *topologyView;
	IBOutlet NSWindow *topologyWindow;
	IBOutlet NSPanel *inspectorPanel;
	IBOutlet NSArrayController *deviceArray;
	
	// array controllers for Core Data Model
	IBOutlet NSArrayController *deviceArrayStatic;  // for validation of toolbar button (isn't used for filtering)
	IBOutlet NSArrayController *routerArray;
	IBOutlet NSArrayController *switchArray;
	IBOutlet NSArrayController *hubArray;
	IBOutlet NSArrayController *pcArray;
	IBOutlet NSArrayController *linkArray;
	IBOutlet NSArrayController *linkTableArray; // used for removing links (has selected link in link table)
    IBOutlet NSArrayController *portArray;
    IBOutlet NSArrayController *portType;

	
	// Add device panel
	IBOutlet NSWindow *addDevicePanel;
	IBOutlet NSTextField *newDeviceName;
	IBOutlet NSTextField *newDeviceDesc;
	IBOutlet NSTextField *newDeviceXCoord;
	IBOutlet NSTextField *newDeviceYCoord;
	
	// Remove device panel
	IBOutlet NSPanel *removeDevicePanel;
	IBOutlet NSPopUpButton *removeDeviceSelection;
	
	// Inspectors
	IBOutlet NSView *inspectorView;
	IBOutlet NSView *hubInspector;
	IBOutlet NSView *switchInspector;
	IBOutlet NSView *routerInspector;
	IBOutlet NSView *pcInspector;
	
	@private
		NSPoint nextDevicePos;
	
}

- (IBAction)addDevice:(id)sender;
- (IBAction)sendUDP:(id)sender;
- (IBAction)updateGUI:(id)sender;
- (void)addHub;
- (void)addSwitch;
- (void)addRouter;
- (void)addPC;
- (void)displayRemoveDeviceWindow;
- (IBAction)removeDevice:(id)sender;
- (void)showInspector:(NSString *)deviceName;
- (void)moveDevice:(NSString *)deviceName toX:(short)xCoord  Y:(short)yCoord;
- (BOOL)isDeviceNameUsed:(NSString *)deviceName;
- (NSString *)generateDeviceName:(int)deviceType;
- (NSManagedObject *)addToCoreDataDeviceOfType:(int)deviceType 
                                      withName:(NSString *)deviceName
                                   description:(NSString *)deviceDescription
                                       atPoint:(NSPoint)point;
- (IBAction)removeLink:(id)sender;
- (void)populateTopologyDevices;
- (void)createPortWithName:(NSString *)name 
                    ofType:(NSString *)type 
                 withIndex:(int)index 
                 forDevice:(NSManagedObject *)device;
- (void)createPort:(NSManagedObject *)device;
- (NSArray *)links;
- (void) OnDocumnetClosed;

@end
