//
//  SRCPrestimState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCPrestimState.h"

@implementation SRCPrestimState

- (void)stateAction {
	
	[stimuli setCueSpot:NO location:trial.attendLoc];
	[[task dataDoc] putEvent:@"preStimuli"];
//	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCInterstimMSKey]];
	expireTime = [LLSystemUtil timeFromNow:50];
}

- (NSString *)name {

    return @"SRCPrestim";
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
		return [[task stateSystem] stateNamed:@"SRCStimulate"];
	}
	return nil;
}

@end
