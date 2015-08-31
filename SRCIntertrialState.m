//
//  SRCIntertrialState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCIntertrialState.h"
#import "UtilityFunctions.h"

@implementation SRCIntertrialState

- (void)dumpTrial {

	NSLog(@"\n catch instruct, attendLoc numStim targetIndex distIndex stimOrientation targetOrientation");
	NSLog(@"%d %d %d   %d %d %d   %.1f %.1f\n", trial.catchTrial, trial.instructTrial, trial.attendLoc,
		trial.numStim, trial.targetIndex, trial.distIndex, trial.stimulusOrientation, trial.targetOrientation);
}

- (void)stateAction {
	expireTime = [LLSystemUtil timeFromNow:[[task defaults] integerForKey:SRCIntertrialMSKey]];
	eotCode = kEOTCorrect;							// default eot code is correct
	brokeDuringStim = NO;				// flag for fixation break during stimulus presentation	

	if (![self selectTrial]) {
		[task setMode:kTaskIdle];					// all blocks have been done
		return;
	}
	[[task dataDoc] putEvent:@"blockStatus" withData:(void *)&blockStatus];
//	[self dumpTrial];
	[stimuli makeStimList:&trial];
//	[stimuli dumpStimList];
}

- (NSString *)name {

    return @"SRCIntertrial";
}

- (LLState *)nextState {

    if ([task mode] == kTaskIdle) {
        eotCode = kEOTForceQuit;
        return [[task stateSystem] stateNamed:@"Endtrial"];
    }
    else if ([LLSystemUtil timeIsPast:expireTime]) {
        return [[task stateSystem] stateNamed:@"SRCStarttrial"];
    }
    return nil;
}

- (BOOL)selectTrial {
	long index, maxTargetIndex, maxStimIndex, stimProbTimes10000;
	long stimulusMS, interstimMS, reactMS; //rewardMS;
	float maxTargetS, meanTargetS, meanRateHz, lambda;
	
	updateBlockStatus();

	if (blockStatus.blocksDone >= blockStatus.blockLimit) {
		return NO;
	}
	
	trial.attendLoc = blockStatus.attendLoc;
	trial.instructTrial = blockStatus.instructsDone < [[task defaults] floatForKey:SRCNumInstructTrialsKey];
	trial.stimulusOrientation = [[task defaults] floatForKey:SRCStimulusOrientationDegKey];
	trial.targetOrientation = [[task defaults] floatForKey:SRCTargetOrientationDegKey];
	
	// Pick a stimulus count for the target, using an exponential distribution

	stimulusMS = [[task defaults] integerForKey:SRCStimDurationMSKey]; 
	interstimMS = [[task defaults] integerForKey:SRCInterstimMSKey];
	maxTargetS = [[task defaults] integerForKey:SRCMaxTargetMSKey] / 1000.0;
	meanTargetS = [[task defaults] integerForKey:SRCMeanTargetMSKey] / 1000.0;
	reactMS = [[task defaults] integerForKey:SRCRespTimeMSKey]; 

	lambda = log(2.0) / meanTargetS;	// lambda of exponential distribution
	stimProbTimes10000 = 10000.0 * (1.0 - exp(-lambda * (stimulusMS + interstimMS) / 1000.0)); 
	meanRateHz = 1000.0 / (stimulusMS + interstimMS);
	maxTargetIndex = maxTargetS * meanRateHz; 		// last position for target
	maxStimIndex = (maxTargetS + reactMS / 1000.0) * meanRateHz + 1;
	
	[[task dataDoc] putEvent:@"maxTargetIndex" withData:(void *)&maxTargetIndex];

	// Pick a count for the target stimulus, earliest possible position is 1 

	for (index = 1; index < maxTargetIndex; index++) {
		if ((rand() % 10000) < stimProbTimes10000) {
			break;
		}
	}
	if (index >= maxTargetIndex && trial.instructTrial) {	// no catch trial on instruct trial
		index = maxTargetIndex - 1;
	}
	trial.catchTrial = (index >= maxTargetIndex);			// is this a catch trial?
	if (trial.catchTrial) {	
		trial.numStim = maxStimIndex;
		trial.targetIndex = maxStimIndex + 1;
	}
	else {
		trial.targetIndex = index;
		trial.numStim = index + reactMS / 1000.0 * meanRateHz + 1;
	}
	
	//NSLog(@"maxTargetIndex: %ld, maxStimIndex: %ld, targetIndex: %ld",maxTargetIndex, maxStimIndex, trial.targetIndex);

	// Pick a count for the distractor stimulus, earliest possible position is 1
	lambda = log(2.0) / (meanTargetS / [[task defaults] floatForKey:SRCRelDistractorProbKey]);	// lambda of exponential distribution
	stimProbTimes10000 = 10000.0 * (1.0 - exp(-lambda * (stimulusMS + interstimMS) / 1000.0)); 
	for (index = 1; index < maxTargetIndex; index++) {
		if ((rand() % 10000) < stimProbTimes10000) {
			break;
		}
	}
	trial.distIndex = index;
	return YES;
}

@end
