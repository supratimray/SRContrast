//
//  SRCCueState.m
//  SRContrast
//
//  Created by John Maunsell on 2/25/06.
//  Copyright 2006. All rights reserved.
//

#import "SRCCueState.h"

@implementation SRCCueState

- (void)stateAction;
{
	cueMS = [[task defaults] integerForKey:SRCCueMSKey];
	if (cueMS > 0) {
		
		[stimuli setCueSpot:YES location:trial.attendLoc];
		expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCCueMSKey]];
		[[task dataDoc] putEvent:@"cueOn"];
	}
}

- (NSString *)name {

    return @"SRCCue";
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
	if (cueMS <= 0 || [LLSystemUtil timeIsPast:expireTime]) {
		return [[task stateSystem] stateNamed:@"SRCPrestim"];
	}
	else {
		return nil;
    }
}

@end
