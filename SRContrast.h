//
//  SRContrast.h
//  SRContrast
//
//  Copyright 2006. All rights reserved.
//

#import "SRC.h"
#import "SRCEyeXYController.h"
#import "SRCDigitalOut.h"

@interface SRContrast:LLTaskPlugIn {

	NSMenuItem				*actionsMenuItem;
    NSWindowController 		*behaviorController;
//	NSTimer					*collectorTimer;
	LLControlPanel			*controlPanel;
	NSPoint					currentEyeUnits;
    SRCEyeXYController		*eyeXYController;				// Eye position display
	NSMenuItem				*settingsMenuItem;
    NSWindowController 		*spikeController;
//	SRCStateSystem			*stateSystem;
    NSWindowController 		*summaryController;
	LLTaskStatus			*taskStatus;
    NSArray                 *topLevelObjects;
    NSWindowController 		*xtController;
	
	// Add Eye filters
	LLFilterExp				*xFilter;
	LLFilterExp				*yFilter;

    IBOutlet NSMenu			*actionsMenu;
    IBOutlet NSMenu			*settingsMenu;
	IBOutlet NSMenuItem		*runStopMenuItem;
}

- (IBAction)doCueSettings:(id)sender;
//- (IBAction)doGaborSettings:(id)sender;
- (IBAction)doFixSettings:(id)sender;
- (IBAction)doJuice:(id)sender;
- (void)doJuiceOff;
- (IBAction)doReset:(id)sender;
- (IBAction)doRFMap:(id)sender;
- (IBAction)doRunStop:(id)sender;
- (SRCStimuli *)stimuli;
- (void)updateChangeTable;
@end
