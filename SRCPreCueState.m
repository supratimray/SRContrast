//
//  SRCPreCueState.m
//  SRContrast
//
//  Created by John Maunsell on 2/25/06.
//  Copyright 2006. All rights reserved.
//

#import "SRCPreCueState.h"
#import "SRCDigitalOut.h"

@implementation SRCPreCueState

- (void)stateAction {

	long preCueMS = [[task defaults] integerForKey:SRCPrecueMSKey];
	long preCueJitterPC = [[task defaults] integerForKey:SRCPrecueJitterPCKey];
	
    if (preCueJitterPC > 0) {
		preCueMS *=  (1 + (((rand() % 201) - 100)/100.0) * (preCueJitterPC/100.0));
	}
	
	//NSLog(@"Precue: %ld",preCueMS);
	
	if ([[task defaults] boolForKey:SRCFixateKey]) {				// fixation required && fixated
		[[task dataDoc] putEvent:@"fixate"];
		//[digitalOut outputEventName:@"fixate" withData:0x0000];
		[digitalOut outputEvent:kFixateDigitOutCode sleepInMicrosec:kSleepInMicrosec];
        
		[scheduler schedule:@selector(updateCalibration) toTarget:self withObject:nil
				delayMS:preCueMS * 0.8];

		if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
			[[NSSound soundNamed:kFixateSound] play];
		}
	}
	expireTime = [LLSystemUtil timeFromNow:preCueMS];
}

- (NSString *)name {

    return @"SRCPrecue";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([[task defaults] boolForKey:SRCFixateKey] && ![fixWindow inWindowDeg:[task currentEyeDeg]]) {
		eotCode = kEOTBroke;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([LLSystemUtil timeIsPast:expireTime]) {
		return [[task stateSystem] stateNamed:@"SRCCue"];
	}
	return nil;
}

- (void)updateCalibration {

	if ([fixWindow inWindowDeg:[task currentEyeDeg]]) {
		NSLog(@"updateCalibratior");
		[[task eyeCalibrator] updateCalibration:[task currentEyeDeg]];
	}
}


@end
