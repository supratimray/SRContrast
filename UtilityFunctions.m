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
	
    floatValue = [[task defaults] floatForKey:SRCAzimuth0DegKey];
    [[task dataDoc] putEvent:@"azimuth0Deg" withData:(Ptr)&floatValue];
//  [digitalOut outputEventName:@"azimuth" withData:(long)(floatValue)];						// Put in the digital events
    
    floatValue = [[task defaults] floatForKey:SRCAzimuth1DegKey];
    [[task dataDoc] putEvent:@"azimuth1Deg" withData:(Ptr)&floatValue];
//  [digitalOut outputEventName:@"azimuth" withData:(long)(floatValue)];						// Put in the digital events
    
    floatValue = [[task defaults] floatForKey:SRCElevation0DegKey];
    [[task dataDoc] putEvent:@"elevation0Deg" withData:(Ptr)&floatValue];
//    [digitalOut outputEventName:@"elevation" withData:(long)(round(100*floatValue))];		// Put in the digital events
    
    floatValue = [[task defaults] floatForKey:SRCElevation1DegKey];
	[[task dataDoc] putEvent:@"elevation1Deg" withData:(Ptr)&floatValue];
//	[digitalOut outputEventName:@"elevation" withData:(long)(round(100*floatValue))];		// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCGaborSigmaDegKey];
	[[task dataDoc] putEvent:@"sigmaDeg" withData:(Ptr)&floatValue];
//	[digitalOut outputEventName:@"sigma" withData:(long)(100*floatValue)];						// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCGaborRadiusDegKey];
	[[task dataDoc] putEvent:@"radiusDeg" withData:(Ptr)&floatValue];
//	[digitalOut outputEventName:@"radius" withData:(long)(100*floatValue)];						// Put in the digital events
	
	floatValue = [[task defaults] floatForKey:SRCStimulusOrientation0DegKey];
	[[task dataDoc] putEvent:@"stimOrientation0Deg" withData:(Ptr)&floatValue];
//	[digitalOut outputEventName:@"orientation" withData:(long)(floatValue)];					// Put in the digital events
	
    floatValue = [[task defaults] floatForKey:SRCStimulusOrientation1DegKey];
    [[task dataDoc] putEvent:@"stimOrientation1Deg" withData:(Ptr)&floatValue];
//  [digitalOut outputEventName:@"orientation" withData:(long)(floatValue)];					// Put in the digital events
    
	floatValue = [[task defaults] floatForKey:SRCSpatialFreq0CPDKey];
	[[task dataDoc] putEvent:@"spatialFreq0CPD" withData:(Ptr)&floatValue];
//	[digitalOut outputEventName:@"spatialFrequency" withData:(long)(100*floatValue)];			// Put in the digital events
	
    floatValue = [[task defaults] floatForKey:SRCSpatialFreq1CPDKey];
    [[task dataDoc] putEvent:@"spatialFreq1CPD" withData:(Ptr)&floatValue];
//  [digitalOut outputEventName:@"spatialFrequency" withData:(long)(100*floatValue)];			// Put in the digital events
    
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

// Cue Related Details
    lValue = [[task defaults] integerForKey:SRCPrecueMSKey];
    [[task dataDoc] putEvent:@"precueDurationMS" withData:(void *)&lValue];
    lValue = [[task defaults] integerForKey:SRCPrecueJitterPCKey];
    [[task dataDoc] putEvent:@"precueJitterPC" withData:(void *)&lValue];
    lValue = [[task defaults] integerForKey:SRCCueMSKey];
    [[task dataDoc] putEvent:@"cueDurationMS" withData:(void *)&lValue];
}

 NSPoint azimuthAndElevationForStimIndex(long index) {
	
	NSPoint aziEle;

     if (index == 0){
         aziEle.x = [[task defaults] floatForKey:SRCAzimuth0DegKey];
         aziEle.y = [[task defaults] floatForKey:SRCElevation0DegKey];
     }
     else if (index == 1){
             aziEle.x = [[task defaults] floatForKey:SRCAzimuth1DegKey];
             aziEle.y = [[task defaults] floatForKey:SRCElevation1DegKey];
     }
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

extern float temporalFreqFromIndex(long index, long stimIndex) {
    bool coupleTemporalFreqs;
    StimParams *params;
    float temporalFreqHz;
    
    coupleTemporalFreqs = [[task defaults] integerForKey:SRCCoupleTemporalFreqsKey];
    params = getTemporalFreqParams();
    
    if (stimIndex == 0) {
         temporalFreqHz = valueFromIndex(index,params);
    }
    else {
        if (coupleTemporalFreqs) {
            if (params->levels != 3) {
                NSLog(@"Need to have exactly 3 levels when temporal frequencies are coupled");
                temporalFreqHz = 0;
            }
            else {
                if (index == 0)
                    temporalFreqHz = 0;
                else if (index == 1)
                    temporalFreqHz = valueFromIndex(2,params);
                else
                    temporalFreqHz = valueFromIndex(1,params);
            }
        }
        else
            temporalFreqHz = valueFromIndex(index,params);
    }
    
    temporalFreqHz = MIN([[task stimWindow] frameRateHz]/2,temporalFreqHz);
    return temporalFreqHz;
}


void updateBlockStatus(void) {
	
	long contrasts, temporalFreqs, reps;
    bool useFeatureAttentionFlag;
    float featureAttentionOrientation0, featureAttentionOrientation1;
	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	reps = [[task defaults] integerForKey:SRCStimRepsPerBlockKey];
	temporalFreqs = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	
	blockStatus.presentationsPerLoc = reps * contrasts * temporalFreqs; 
	blockStatus.locsPerBlock = kLocations;
	blockStatus.blockLimit = [[task defaults] integerForKey:SRCBlockLimitKey];
	
	blockStatus.presentationsDoneThisLoc = stimDoneThisBlock(blockStatus.blocksDone, blockStatus.attendLoc);
    
    // If running the feature attentino block, set the stimulus orientations
    useFeatureAttentionFlag = [[task defaults] boolForKey:SRCUseFeatureAttentionKey];
    if (useFeatureAttentionFlag) {
        if (blockStatus.presentationsDoneThisLoc == 0 && blockStatus.locsDoneThisBlock == 0) { // only at the start of each block
            
            featureAttentionOrientation0 = [[task defaults] floatForKey:SRCFeatureAttentionOrientation0DegKey];
            featureAttentionOrientation1 = [[task defaults] floatForKey:SRCFeatureAttentionOrientation1DegKey];
//          NSLog(@"Blocks, Remainder: %ld, %ld",blockStatus.blocksDone,(blockStatus.blocksDone % 4));
            
            if ((blockStatus.blocksDone % 4) == 0) {      // (Ori0, Ori0)
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation0 forKey:SRCStimulusOrientation0DegKey];
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation0 forKey:SRCStimulusOrientation1DegKey];
            }
            else if ((blockStatus.blocksDone % 4) == 1) { // (Ori0, Ori1)
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation0 forKey:SRCStimulusOrientation0DegKey];
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation1 forKey:SRCStimulusOrientation1DegKey];
            }
            else if ((blockStatus.blocksDone % 4) == 2) { // (Ori1, Ori0)
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation1 forKey:SRCStimulusOrientation0DegKey];
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation0 forKey:SRCStimulusOrientation1DegKey];
            }
            else if ((blockStatus.blocksDone % 4) == 3) { // (Ori1, Ori1)
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation1 forKey:SRCStimulusOrientation0DegKey];
                [[NSUserDefaults standardUserDefaults] setFloat:featureAttentionOrientation1 forKey:SRCStimulusOrientation1DegKey];
            }
        }
    }
	
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