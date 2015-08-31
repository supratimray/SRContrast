//
//  SRCStarttrialState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCStarttrialState.h"
#import "UtilityFunctions.h"
#import "SRCDigitalOut.h"


@implementation SRCStarttrialState

- (void)stateAction {

	long lValue, index;
	NSPoint aziEle;
	FixWindowData fixWindowData, respWindowData[kRespLocations];

	// Prepare structures describing the fixation and response windows;
	fixWindowData.index = [[task eyeCalibrator] nextCalibrationPosition];
	[[task synthDataDevice] setOffsetDeg:[[task eyeCalibrator] calibrationOffsetPointDeg]];			// keep synth data on offset fixation
    fixWindowData.windowDeg = [fixWindow rectDeg];
    fixWindowData.windowUnits = [[task eyeCalibrator] unitRectFromDegRect:fixWindowData.windowDeg];
    [fixWindow setWidthAndHeightDeg:[[task defaults] floatForKey:SRCFixWindowWidthDegKey]];
	for (index = 0; index < kRespLocations; index++) {
		aziEle = azimuthAndElevationForStimIndex(index);
		[respWindows[index] setAzimuthDeg:aziEle.x elevationDeg:aziEle.y];
		[respWindows[index] setWidthAndHeightDeg:[[task defaults] floatForKey:SRCRespWindowWidthDegKey]];
		respWindowData[index].index = index;
		respWindowData[index].windowDeg = [respWindows[index] rectDeg];
		respWindowData[index].windowUnits = [[task eyeCalibrator] 
				unitRectFromDegRect:respWindowData[index].windowDeg];
	}

	// Stop data collection before this block of events
    [[task dataController] setDataEnabled:[NSNumber numberWithBool:NO]];
	[[task dataController] readDataFromDevices];
    [[task collectorTimer] fire];
	
	[[task dataDoc] putEvent:@"trialStart" withData:&trial.targetIndex];
	[digitalOut outputEventName:@"trialStart" withData:trial.targetIndex];
	
	[[task dataDoc] putEvent:@"trial" withData:&trial];
	[digitalOut outputEventName:@"attendLoc" withData:(long)trial.attendLoc];
	[digitalOut outputEventName:@"instructTrial" withData:(long)trial.instructTrial];
	[digitalOut outputEventName:@"catchTrial" withData:(long)trial.catchTrial];
	
	lValue = 0;
	[[task dataDoc] putEvent:@"sampleZero" withData:&lValue];
	[[task dataDoc] putEvent:@"spikeZero" withData:&lValue];

	// Restart data collection immediately after declaring the zerotimes
    [[task dataController] setDataEnabled:[NSNumber numberWithBool:YES]];
	[[task dataDoc] putEvent:@"eyeCalibration" withData:[[task eyeCalibrator] calibrationData]];
	[[task dataDoc] putEvent:@"eyeWindow" withData:&fixWindowData];
	
	for (index = 0; index < kRespLocations; index++) {
		[[task dataDoc] putEvent:@"responseWindow" withData:&respWindowData[index]];
	}
}

- (NSString *)name {

    return @"SRCStarttrial";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return  [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([[task defaults] boolForKey:SRCFixateKey] && [fixWindow inWindowDeg:[task currentEyeDeg]]) {
		return [[task stateSystem] stateNamed:@"SRCBlocked"];
	}
	else {
		return [[task stateSystem] stateNamed:@"SRCFixon"];
	} 
}

@end
