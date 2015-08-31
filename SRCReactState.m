//
//  SRCReactState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCReactState.h"
#import "UtilityFunctions.h"

#define kAlpha		10.0
#define kBeta		2.0

@implementation SRCReactState

- (void)stateAction {
	float prob100;
	
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCRespTimeMSKey]];
					
// Here we instruct the fake monkey to respond, using appropriate psychophysics.

	prob100 = 100.0 - 50.0 * exp(-exp(log(contrastFromIndex(trial.targetContrastIndex) / kAlpha) * kBeta));
	if ((rand() % 100) < prob100) {
		
		[[task synthDataDevice] setEyeTargetOn:azimuthAndElevationForStimIndex(trial.attendLoc)];
	}
}

- (NSString *)name {

    return @"SRCReact";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {							// switched to idle
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if (![[task defaults] boolForKey:SRCFixateKey]) {
		eotCode = kEOTCorrect;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	else {
		if (![fixWindow inWindowDeg:[task currentEyeDeg]]) {   // started a saccade
			return [[task stateSystem] stateNamed:@"SRCSaccade"];
		}
	}
	if ([LLSystemUtil timeIsPast:expireTime]) {
		eotCode = kEOTFailed;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
    return nil;
}

@end
