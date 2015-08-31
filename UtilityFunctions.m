//
//  UtilityFunctions.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRC.h"
#import "UtilityFunctions.h"
#import "SRCDigitalOut.h"


#define kC50Squared				0.0225
#define kDrivenRate				100.0
#define kSpontRate				15.0

void announceEvents(void) {

    long lValue;
    float floatValue;
	char *idString = "SRContrast Version 1.0";
	
 	[[task dataDoc] putEvent:@"text" withData:idString lengthBytes:strlen(idString)];
 	[[task dataDoc] putEvent:@"displayCalibration" withData:[stimuli displayParameters]];
	[[task dataDoc] putEvent:@"contrastParams" withData:(Ptr)getContrastParams()];
	[[task dataDoc] putEvent:@"temporalFreqParams" withData:(Ptr)getTemporalFreqParams()];
	[[task dataDoc] putEvent:@"gabor" withData:(Ptr)[[stimuli gabor0] gaborData]];
	[[task dataDoc] putEvent:@"gabor" withData:(Ptr)[[stimuli gabor1] gaborData]];
	
    floatValue = [[task defaults] floatForKey:SRCEccentricityDegKey];
	[[task dataDoc] putEvent:@"eccentricityDeg" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"eccentricity" withData:(long)(round(100*floatValue))];		// Put in the digital events
	
    floatValue = [[task defaults] floatForKey:SRCPolarAngleDegKey];
	[[task dataDoc] putEvent:@"polarAngleDeg" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"polarAngle" withData:(long)(floatValue)];						// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCGaborSigmaDegKey];
	[[task dataDoc] putEvent:@"sigmaDeg" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"sigma" withData:(long)(100*floatValue)];						// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCGaborRadiusDegKey];
	[[task dataDoc] putEvent:@"radiusDeg" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"radius" withData:(long)(100*floatValue)];						// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCStimulusOrientationDegKey];
	[[task dataDoc] putEvent:@"stimOrientationDeg" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"orientation" withData:(long)(floatValue)];					// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCGaborSpatialFreqCPDKey];
	[[task dataDoc] putEvent:@"spatialFreqCPD" withData:(Ptr)&floatValue];
	[digitalOut outputEventName:@"spatialFrequency" withData:(long)(100*floatValue)];			// Put in the digital events
	
	
    lValue = [[task defaults] integerForKey:SRCStimDurationMSKey];
	[[task dataDoc] putEvent:@"stimDurationMS" withData:(Ptr)&lValue];
	lValue = [[task defaults] integerForKey:SRCStimJitterPCKey];
	[[task dataDoc] putEvent:@"stimJitterPC" withData:(Ptr)&lValue];
    lValue = [[task defaults] integerForKey:SRCInterstimMSKey];
	[[task dataDoc] putEvent:@"interstimMS" withData:(Ptr)&lValue];
	lValue = [[task defaults] integerForKey:SRCInterstimJitterPCKey];
	[[task dataDoc] putEvent:@"interstimJitterPC" withData:(Ptr)&lValue];
    lValue = [[task defaults] integerForKey:SRCStimLeadMSKey];
	[[task dataDoc] putEvent:@"stimLeadMS" withData:(Ptr)&lValue];
	lValue = [[task defaults] integerForKey:SRCRespTimeMSKey];
	[[task dataDoc] putEvent:@"responseTimeMS" withData:(Ptr)&lValue];
    lValue = [[task defaults] integerForKey:SRCTooFastMSKey];
	[[task dataDoc] putEvent:@"tooFastTimeMS" withData:(Ptr)&lValue];
    lValue = [[task defaults] integerForKey:SRCTriesKey];
	[[task dataDoc] putEvent:@"tries" withData:(Ptr)&lValue];
	lValue = [[task defaults] integerForKey:SRCStimRepsPerBlockKey];
	[[task dataDoc] putEvent:@"stimRepsPerBlock" withData:(void *)&lValue];
	lValue = [[task defaults] integerForKey:SRCPreferredLocKey];
	[[task dataDoc] putEvent:@"preferredLoc" withData:(void *)&lValue];
	
}

 NSPoint azimuthAndElevationForStimIndex(long index) {
	float  polarAngleRad, eccentricityDeg, polarAngleDeg;
	NSPoint aziEle;

	eccentricityDeg = [[task defaults] floatForKey:SRCEccentricityDegKey];
	polarAngleDeg = [[task defaults] floatForKey:SRCPolarAngleDegKey];
	 
	if (index == 1){			//eccentricity and polar angles are defined for index 0
		 polarAngleDeg = ((polarAngleDeg - 180.0 < 0) ? polarAngleDeg + 180.0 : polarAngleDeg - 180.0 );
	 }
	 
	polarAngleRad = polarAngleDeg / kDegPerRadian;
	aziEle.x = eccentricityDeg * cos(polarAngleRad);
	aziEle.y = eccentricityDeg * sin(polarAngleRad);
	return aziEle;
}

extern float contrastFromIndex(long index) {
	return(valueFromIndex(index, getContrastParams()));
}

StimParams *getContrastParams(void) {
	static StimParams params;
	
	params.levels = [[task defaults] integerForKey:SRCContrastsKey];
	params.maxValue = [[task defaults] floatForKey:SRCMaxContrastKey];
	params.factor = [[task defaults] floatForKey:SRCContrastFactorKey];
	return &params;
}

StimParams *getTemporalFreqParams(void) {
	static StimParams params;
	
	params.levels = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	params.maxValue = [[task defaults] floatForKey:SRCMaxTemporalFreqHzKey];
	params.factor = [[task defaults] floatForKey:SRCTemporalFreqFactorKey];
	return &params;
}

float	maxAllowableTempFreq(void) {
	// Modify later to get this value from display parameters
	float value;
	value = 50.0;
	return value;
}

void putBlockDataEvents(long blocksDone, long location) {
	long value;

	value = stimDoneThisBlock(blocksDone,location);
	[[task dataDoc] putEvent:@"blockStimDone" withData:(void *)&value];
	[[task dataDoc] putEvent:@"blocksDone" withData:(void *)&blocksDone];
}

long repsDoneAtLoc(long loc) {

	long c, t, done;
	
	for (c = 0, done = LONG_MAX; c < [[task defaults] integerForKey:SRCContrastsKey]; c++) {
		for (t = 0; t < [[task defaults] integerForKey:SRCTemporalFreqsKey]; t++) {
			done = MIN(done, stimDone[loc][c][t]);
		}
	}
	return done;
}

void requestReset(void) {

    if ([task mode] == kTaskIdle) {
        reset();
    }
    else {
        resetFlag = YES;
    }
}

void reset(void) {
    long resetType = 0;
	[[task dataDoc] putEvent:@"reset" withData:&resetType];
}

float spikeRateFromStimValue(float normalizedValue) {
	double vSquared;
	vSquared = normalizedValue * normalizedValue;
	return kDrivenRate *  vSquared / (vSquared + kC50Squared) + kSpontRate;
}

// Return the number of stimulus repetitions in a block (kLocations * repsPerBlock * contrasts * temporalFreqs)  
long stimPerBlock(void) {
	return kLocations * [[task defaults] integerForKey:SRCStimRepsPerBlockKey] * 
									[[task defaults] integerForKey:SRCContrastsKey] * [[task defaults] integerForKey:SRCTemporalFreqsKey];
}


// Return the number of stimuli completed in the current block  
long stimDoneThisBlock(long blocksDone, long location) {

	long c, contrasts, t, temporalFreqs, reps, done;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	reps = [[task defaults] integerForKey:SRCStimRepsPerBlockKey];
	temporalFreqs = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	
	done=0;
	for (c = 0; c < contrasts; c++) {
		for (t = 0; t < temporalFreqs; t++) {
		done += stimDone[location][c][t];
		}
	}
	done = done - blocksDone*reps*contrasts*temporalFreqs;
	return (done);
}

// Return the number of stimuli completed in the current block  
long stimDoneThisBlockGivenTemporalFreq(long blocksDone, long location, long tindex) {
	
	long c, contrasts, reps, done;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	reps = [[task defaults] integerForKey:SRCStimRepsPerBlockKey];
	
	done=0;
	for (c = 0; c < contrasts; c++) {
		done += stimDone[location][c][tindex];
	}
	done = done - blocksDone*reps*contrasts;
	return (done);
}

long stimDoneAllBlocks(long location) {
	long c, contrasts, t, temporalFreqs, done;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	temporalFreqs = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	
	done=0;
	for (c = 0; c < contrasts; c++) {
		for (t = 0; t < temporalFreqs; t++) {
			done += stimDone[location][c][t];
		}
	}
	return (done);
}

long stimDoneAllBlocksGivenTemporalFreq(long location, long tindex) {
	long c, contrasts, done;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	
	done=0;
	for (c = 0; c < contrasts; c++) {
		done += stimDone[location][c][tindex];
	}
	return (done);
}

extern float temporalFreqFromIndex(long index) {
	return(MIN(maxAllowableTempFreq(),valueFromIndex(index, getTemporalFreqParams())));
}


void updateBlockStatus(void) {
	
	long contrasts, temporalFreqs, reps;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	reps = [[task defaults] integerForKey:SRCStimRepsPerBlockKey];
	temporalFreqs = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	
	blockStatus.presentationsPerLoc = reps * contrasts * temporalFreqs; 
	blockStatus.locsPerBlock = kLocations;
	blockStatus.blockLimit = [[task defaults] integerForKey:SRCBlockLimitKey];
	
	blockStatus.presentationsDoneThisLoc = stimDoneThisBlock(blockStatus.blocksDone, blockStatus.attendLoc);
	
	if (blockStatus.presentationsDoneThisLoc >= blockStatus.presentationsPerLoc) {
		blockStatus.attendLoc = ((blockStatus.attendLoc + 1) % blockStatus.locsPerBlock); 
		blockStatus.instructsDone = 0;
		blockStatus.presentationsDoneThisLoc = stimDoneThisBlock(blockStatus.blocksDone, blockStatus.attendLoc);
		
		if (++blockStatus.locsDoneThisBlock >= blockStatus.locsPerBlock) {
			blockStatus.blocksDone++;
			blockStatus.locsDoneThisBlock = 0;
		}
		
		//NSLog(@"blocks done: %ld, locsdonethisblock: %ld, attendLoc: %ld",blockStatus.blocksDone,blockStatus.locsDoneThisBlock, blockStatus.attendLoc);
	}
}
	
float valueFromIndex(long index, StimParams *pStimParams)
{
	short c, stimLevels;
	float stimValue, level, stimFactor;
	
	stimLevels = pStimParams->levels;
	stimFactor = pStimParams->factor;
	switch (stimLevels) {
	case 1:								// Just the 100% stimulus
		stimValue = pStimParams->maxValue;
		break;
	case 2:								// Just 100% and 0% stimuli
		stimValue = (index == 0) ? 0 : pStimParams->maxValue;
		break;
	default:							// Other values as well
		if (index == 0) {
			stimValue = 0;
		}
		else {
			level = pStimParams->maxValue;
			for (c = stimLevels - 1; c > index; c--) {
				level *= stimFactor;
			}
			stimValue = level;
		}
	}
	return(stimValue);
}