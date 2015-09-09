//
//  SRCFixonState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCFixonState.h"
#import "SRCDigitalOut.h"

@implementation SRCFixonState

- (void)stateAction {

    [stimuli setFixSpot:YES];
	[[task dataDoc] putEvent:@"fixOn"];
//	[digitalOut outputEventName:@"fixOn" withData:0x0000];
	
//    [[task synthDataDevice] doLeverDown];
    [[task synthDataDevice] setEyeTargetOn:NSMakePoint(0, 0)];
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCAcquireMSKey]];
	if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
		[[NSSound soundNamed:kFixOnSound] play];
	}
}

- (NSString *)name {

    return @"SRCFixon";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if (![[task defaults] boolForKey:SRCFixateKey]) { 
		return [[task stateSystem] stateNamed:@"SRCPrecue"];
    }
	else if ([fixWindow inWindowDeg:[task currentEyeDeg]])  {
		return [[task stateSystem] stateNamed:@"SRCFixGrace"];
    }
	if ([LLSystemUtil timeIsPast:expireTime]) {
		eotCode = kEOTIgnored;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	else {
		return nil;
    }
}

@end
