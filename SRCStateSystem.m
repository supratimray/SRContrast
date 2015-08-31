//
//  SRCStateSystem.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCStateSystem.h"
#import "UtilityFunctions.h"

#import "SRCBlockedState.h"
#import "SRCCueState.h"
#import "SRCEndtrialState.h"
#import "SRCFixGraceState.h"
#import "SRCFixonState.h"
#import "SRCIdleState.h"
#import "SRCIntertrialState.h"
#import "SRCPreCueState.h"
#import "SRCPrestimState.h"
#import "SRCBreakState.h"
#import "SRCReactState.h"
#import "SRCSaccadeState.h"
#import "SRCStarttrialState.h"
#import "SRCStimulate.h"
#import "SRCStopState.h"

short				attendLoc;
long 				eotCode;			// End Of Trial code
BOOL 				fixated;
LLEyeWindow			*fixWindow;
LLEyeWindow			*respWindows[kRespLocations];
//SRCStateSystem		*stateSystem;
TrialDesc			trial;

@implementation SRCStateSystem

- (void)dealloc {

	long index;
	
    [fixWindow release];
	
	for (index = 0; index < kRespLocations; index++) {
		[respWindows[index] release];
	}
    [super dealloc];
}


- (id)init {

	long index;
	
    if ((self = [super init]) != nil) {

		// create & initialize the state system's states

		[self addState:[[[SRCBlockedState alloc] init] autorelease]];
		[self addState:[[[SRCCueState alloc] init] autorelease]];
		[self addState:[[[SRCEndtrialState alloc] init] autorelease]];
		[self addState:[[[SRCFixonState alloc] init] autorelease]];
		[self addState:[[[SRCFixGraceState alloc] init] autorelease]];
		[self addState:[[[SRCIdleState alloc] init] autorelease]];
		[self addState:[[[SRCIntertrialState alloc] init] autorelease]];
		[self addState:[[[SRCStimulate alloc] init] autorelease]];
		[self addState:[[[SRCPreCueState alloc] init] autorelease]];
		[self addState:[[[SRCPrestimState alloc] init] autorelease]];
		[self addState:[[[SRCBreakState alloc] init] autorelease]];		
		[self addState:[[[SRCReactState alloc] init] autorelease]];
		[self addState:[[[SRCSaccadeState alloc] init] autorelease]];
		[self addState:[[[SRCStarttrialState alloc] init] autorelease]];
		[self addState:[[[SRCStopState alloc] init] autorelease]];
		[self setStartState:[self stateNamed:@"SRCIdle"] andStopState:[self stateNamed:@"SRCStop"]];
		[self->controller setLogging:YES];
		
		fixWindow = [[LLEyeWindow alloc] init];
		[fixWindow setWidthAndHeightDeg:[[task defaults] floatForKey:SRCFixWindowWidthDegKey]];
		for (index = 0; index < kRespLocations; index++) {
			respWindows[index] = [[LLEyeWindow alloc] init];
			[respWindows[index] setWidthAndHeightDeg:[[task defaults] 
						floatForKey:SRCRespWindowWidthDegKey]];
		}

// Initialize the trialBlock that keeps track of trials and blocks

		stimType = -1;
    }
    return self;
}

/*
- (BOOL) running {

    return [self running];
}

- (BOOL) startWithCheckIntervalMS:(double)checkMS {			// start the system running

    return [self startWithCheckIntervalMS:checkMS];
}

- (void) stop {										// stop the system

    [self stop];
}
*/
// Methods related to data events follow:

- (void)contrastParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	StimParams stimParams;
	
	if (stimType >= 0) {
		[eventData getBytes:&stimParams];
	}
}

- (void)temporalFreqParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	StimParams stimParams;
	
	if (stimType >= 0) {
		[eventData getBytes:&stimParams];
	}
}

- (void) reset:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	long loc, contrast, tempFreq;
	
	for (loc = 0; loc < kLocations; loc++) {
		for (contrast = 0; contrast < kMaxContrasts; contrast++) {
			for (tempFreq = 0; tempFreq < kMaxTemporalFreqs; tempFreq++) {
				stimDone[loc][contrast][tempFreq] = 0;
			}
		}
	}
	blockStatus.attendLoc = [[task defaults] integerForKey:SRCPreferredLocKey]; 
	blockStatus.instructsDone = 0;
	blockStatus.locsDoneThisBlock = 0;
	blockStatus.blocksDone = 0;
	updateBlockStatus();
}

- (void) stimulus:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	float normalizedValue;
	StimDesc *pSD = (StimDesc *)[eventData bytes];
	
	normalizedValue = contrastFromIndex(pSD->contrastIndex) / [[task defaults] floatForKey:SRCMaxContrastKey];
    [[task synthDataDevice] setSpikeRateHz:spikeRateFromStimValue(normalizedValue) atTime:[LLSystemUtil getTimeS]];
}

- (void) stimulusOff:(NSData *)eventData eventTime:(NSNumber *)eventTime {
    [[task synthDataDevice] setSpikeRateHz:spikeRateFromStimValue(0.0) atTime:[LLSystemUtil getTimeS]];
}

- (void) tries:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	long tries;
	[eventData getBytes:&tries];
}

@end
