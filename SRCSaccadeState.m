//
//  SRCSaccadeState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCSaccadeState.h"
#import "SRCDigitalOut.h"

@implementation SRCSaccadeState

- (void)stateAction {

	[[task dataDoc] putEvent:@"saccade"];
	[digitalOut outputEventName:@"saccade" withData:0x0000];
	
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCSaccadeTimeMSKey]];
}

- (NSString *)name {

    return @"SRCSaccade";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	
	if ([respWindows[trial.attendLoc] inWindowDeg:[task currentEyeDeg]])  {
		if ([LLSystemUtil timeIsPast:tooFastExpire]) {
			eotCode = kEOTCorrect;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
		else{
			eotCode = kEOTBroke;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
	}
	if ([respWindows[1 - trial.attendLoc] inWindowDeg:[task currentEyeDeg]])  {
		if ([LLSystemUtil timeIsPast:tooFastExpire]) {
			eotCode = kEOTWrong;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
		else{
			eotCode = kEOTBroke;
			return [[task stateSystem] stateNamed:@"Endtrial"];
		}
	}
	
	if ([LLSystemUtil timeIsPast:expireTime]) {
		eotCode = kEOTFailed;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
    return nil;
}

@end
