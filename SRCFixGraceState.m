//
//  SRCFixGraceState.m
//  SRContrast
//
//  Copyright 2006. All rights reserved.
//

#import "SRCFixGraceState.h"


@implementation SRCFixGraceState

- (void)stateAction;
{
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCFixGraceMSKey]];
}

- (NSString *)name;
{
    return @"SRCFixGrace";
}

- (LLState *)nextState;
{
	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([LLSystemUtil timeIsPast:expireTime]) {
		if ([fixWindow inWindowDeg:[task currentEyeDeg]])  {
			return [[task stateSystem] stateNamed:@"SRCPrecue"];
		}
		else {
//			eotCode = kEOTIgnored;
//			return [[task stateSystem] stateNamed:@"Endtrial"];
			return [[task stateSystem] stateNamed:@"SRCFixon"];
		}
	}
	else {
		return nil;
    }
}

@end
