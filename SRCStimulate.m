//
//  SRCStimulate.m
//  SRContrast
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCStimulate.h" 

@implementation SRCStimulate

- (void)stateAction {
	[stimuli startStimList];
	brokeDuringStim = YES;			// ???? why?
}

- (NSString *)name {

    return @"SRCStimulate";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		eotCode = kEOTForceQuit;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([[task defaults] boolForKey:SRCFixateKey] &&  ![fixWindow inWindowDeg:[task currentEyeDeg]]) {
		eotCode = kEOTBroke;
		return [[task stateSystem] stateNamed:@"SRCBreak"];
	}
	if (![stimuli stimulusOn]) {
		eotCode = kEOTCorrect;
		return [[task stateSystem] stateNamed:@"Endtrial"];
	}
	if ([stimuli targetPresented]) {
		tooFastExpire = [LLSystemUtil timeFromNow: [[task defaults] integerForKey:SRCTooFastMSKey]];
		return [[task stateSystem] stateNamed:@"SRCReact"];
	}
	if ([stimuli distracterPresented]) {
		tooFastExpireDist = [LLSystemUtil timeFromNow: [[task defaults] integerForKey:SRCTooFastMSKey]];
		respTimeWinDist = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCRespTimeMSKey]];		
	}	
    return nil;
}


@end
