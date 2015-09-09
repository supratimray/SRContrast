//
//  SRCBreakState.m
//  SRContrast
//
//  Created by Joonyeol Lee on 9/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SRCBreakState.h"
#import "SRCDigitalOut.h"

@implementation SRCBreakState

- (void)stateAction {
	[[task dataDoc] putEvent:@"break"];
	//[digitalOut outputEventName:@"break" withData:0x0000];
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCSaccadeTimeMSKey]];
}

- (NSString *)name {

    return @"SRCBreak";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}

	if ([respWindows[trial.attendLoc] inWindowDeg:[task currentEyeDeg]])  {
		if ([stimuli distracterPresented]){			
			if ([LLSystemUtil timeIsPast:tooFastExpireDist] && ![LLSystemUtil timeIsPast:respTimeWinDist]) {
				eotCode = kEOTDistracted;
				return [[task stateSystem] stateNamed:@"Endtrial"];
			}
			else{
				eotCode = kEOTFAlarm;
				return [[task stateSystem] stateNamed:@"Endtrial"];
			}
		}
		else {
				eotCode = kEOTFAlarm;
				return [[task stateSystem] stateNamed:@"Endtrial"];
		}
	}
	else {
		if ([stimuli distracterPresented]){
			if ([LLSystemUtil timeIsPast:tooFastExpireDist] && ![LLSystemUtil timeIsPast:respTimeWinDist]) {
				eotCode = kEOTDistracted;
				return [[task stateSystem] stateNamed:@"Endtrial"];
			}
			else{
				if ([LLSystemUtil timeIsPast:expireTime]) {
					eotCode = kEOTBroke;
					return [[task stateSystem] stateNamed:@"Endtrial"];
				}
			}
		}
		else{
			if ([LLSystemUtil timeIsPast:expireTime]) {
				eotCode = kEOTBroke;
				return [[task stateSystem] stateNamed:@"Endtrial"];
			}
		}
	}

    return nil;
}

@end
