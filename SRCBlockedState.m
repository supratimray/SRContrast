//
//  SRCBlockedState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCBlockedState.h"

@implementation SRCBlockedState

- (void)stateAction {

	[[task dataDoc] putEvent:@"blocked"];
//	schedule(&bNode, (PSCHED)&blockedTones, PRISYS - 1, 400, -1, NULL);
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCAcquireMSKey]];
}

- (NSString *)name {

    return @"SRCBlocked";
}

- (LLState *)nextState {

	if (![[task defaults] boolForKey:SRCFixateKey] || ![fixWindow inWindowDeg:[task currentEyeDeg]]) {
		return [[task stateSystem] stateNamed:@"SRCFixon"];
    }
	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([LLSystemUtil timeIsPast:expireTime]) {
		eotCode = kEOTIgnored;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
    return nil; 
}

@end
