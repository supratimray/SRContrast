/*
SRCStimuli.m
Stimulus generation for SRContrast
March 29, 2003 JHRM
*/

#import "SRC.h"
#import "SRCStimuli.h"
#import "SRCDigitalOut.h"
#import "UtilityFunctions.h"

#define kDefaultDisplayIndex	1		// Index of stim display when more than one display
#define kMainDisplayIndex		0		// Index of main stimulus display
#define kPixelDepthBits			32		// Depth of pixels in stimulus window
#define	stimWindowSizePix		250		// Height and width of stim window on main display

#define kTargetBlue				0.0
#define kTargetGreen			1.0
#define kMidGray				0.5
#define kTargetRed				1.0
#define kDegPerRad				57.295779513

#define kAdjusted(color, contrast)  (kMidGray + (color - kMidGray) / 100.0 * contrast)

NSString *stimulusMonitorID = @"SRContrast Stimulus";

@implementation SRCStimuli

- (void) dealloc {
	[[task monitorController] removeMonitorWithID:stimulusMonitorID];
	[stimList release];
	[cueSpot release];
	[fixSpot release];	
	[gabor0 release];		
	[gabor1 release];		    
	[super dealloc];
}

// Run the cue settings dialog
- (void)doCueSettings {
	[cueSpot runSettingsDialog];
}

// Run the fixation settings dialog
- (void)doFixSettings {
	[fixSpot runSettingsDialog];
}

- (DisplayParam *)displayParameters {
	return &display;
}

- (void)dumpStimList {
	StimDesc stimDesc;
	long index;
	
	NSLog(@"\ncIndex contrast type0 type0 Orientation type1 type1 Orientation stimOnFrame stimOffFrame");
	for (index = 0; index < [stimList count]; index++) {
		[[stimList objectAtIndex:index] getValue:&stimDesc];
		NSLog(@"%4ld: %4ld \t%4ld %.1f\t %ld %.1f\t %ld %ld", index, stimDesc.contrastIndex,
			  stimDesc.type0, stimDesc.orientation0Deg, stimDesc.type1, stimDesc.orientation1Deg, stimDesc.stimOnFrame, stimDesc.stimOffFrame);
	}
	NSLog(@"\n");
}

- (void)erase {
	[[task stimWindow] lock];
    glClearColor(kMidGray, kMidGray, kMidGray, 0);
    glClear(GL_COLOR_BUFFER_BIT);
	[[NSOpenGLContext currentContext] flushBuffer];
	[[task stimWindow] unlock];
}


- (LLGabor *)gabor0 {
	return gabor0;		
}

- (LLGabor *)gabor1 {
	return gabor1;		
}

- (id)init {
	if (!(self = [super init])) {
		return nil;
	}

	display = [[[task stimWindow] displays] displayParameters:[[task stimWindow] displayIndex]];
	monitor = [[[LLIntervalMonitor alloc] initWithID:stimulusMonitorID 
					description:@"Stimulus frame intervals"] autorelease];
	[[task monitorController] addMonitor:monitor];
	[monitor setTargetIntervalMS:1000.0 / display.frameRateHz];
	stimList = [[NSMutableArray alloc] init];
	
	// Create and initialize the gabor stimuli at locations 0 and 1
	gabor0 = [self initGabor];
	gabor1 = [self initGabor];
	
	
	cueSpot = [[LLFixTarget alloc] init];
	[cueSpot bindValuesToKeysWithPrefix:@"SRCCue"];
	fixSpot = [[LLFixTarget alloc] init];
	[fixSpot bindValuesToKeysWithPrefix:@"SRCFix"];

	// Register for notifications about changes to the gabor settings
	return self;
}

- (LLGabor *)initGabor {
	LLGabor *gabor;
	
	gabor = [[LLGabor alloc] init];				// Create a gabor stimulus
	[gabor setDisplays:[[task stimWindow] displays] displayIndex:[[task stimWindow] displayIndex]];
	[gabor removeKeysFromBinding:[NSArray arrayWithObjects:LLGaborAzimuthDegKey, LLGaborElevationDegKey, 
								 LLGaborContrastKey, nil]];
	[gabor bindValuesToKeysWithPrefix:@"SRC"];
	return gabor;
}


- (void)insertStimSettingsAtIndex:(long)index trial:(TrialDesc *)pTrial type0:(long)type0 type1:(long)type1 contrastIndex:(long)cIndex temporalFreqIndex:(long)tIndex {
	StimDesc stimDesc;
	float	distractorContrastRatio;
    bool    useSingleStimulusPerTrialFlag;
    float changeInOrientation;
    
    useSingleStimulusPerTrialFlag = [[task defaults] boolForKey:SRCUseSingleStimulusPerTrialKey];
    changeInOrientation = pTrial->changeInOrientation; // by default, for TF=0
    
    if (useSingleStimulusPerTrialFlag) {
        cIndex = cSingleStimulusPerTrial;
        tIndex = tSingleStimulusPerTrial;
        
        // Use different orientations only in this case
        if (tIndex==1) {
            changeInOrientation = pTrial->changeInOrientationTF1;
        }
        else if (tIndex==2) {
            changeInOrientation = pTrial->changeInOrientationTF2;
        }
    }
    
    distractorContrastRatio = [[task defaults] floatForKey:SRCDistractorContrastRatioKey];
    
	stimDesc.attendLoc = attendLoc;
	stimDesc.type0 = type0;
	
    stimDesc.orientation0Deg = (type0 == kTargetStim) ? (pTrial->stimulusOrientation0 + changeInOrientation) : pTrial->stimulusOrientation0;
	stimDesc.type1 = type1;
	stimDesc.orientation1Deg = (type1 == kTargetStim) ? (pTrial->stimulusOrientation1 + changeInOrientation) : pTrial->stimulusOrientation1;
	
    stimDesc.contrastIndex = cIndex;
	stimDesc.temporalFreqIndex = tIndex;
	
    stimDesc.spatialFreq0CPD = [[task defaults] floatForKey:SRCSpatialFreq0CPDKey];
    stimDesc.spatialFreq1CPD = [[task defaults] floatForKey:SRCSpatialFreq1CPDKey];
    stimDesc.temporalFreq0Hz = temporalFreqFromIndex(tIndex,0);
    stimDesc.temporalFreq1Hz = temporalFreqFromIndex(tIndex,1);
    
    if (attendLoc==0) {
        stimDesc.contrast0PC      = contrastFromIndex(cIndex);
        stimDesc.contrast1PC      = distractorContrastRatio*contrastFromIndex(cIndex);
    }
    else {
        stimDesc.contrast0PC      = distractorContrastRatio*contrastFromIndex(cIndex);
        stimDesc.contrast1PC      = contrastFromIndex(cIndex);
    }
    
	if (index < 0 || index > [stimList count]) {
		index = [stimList count];
	}
	[stimList insertObject:[NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]
		atIndex:index];
}



- (void)loadGaborsWithStimDesc:(StimDesc *)pSD {
	long	index;
	NSPoint aziEle;
	LLGabor *gabors[] = {gabor0, gabor1, nil};
	
	for (index = 0; gabors[index] != nil; index++) {
		aziEle = azimuthAndElevationForStimIndex(index);
		[gabors[index] directSetAzimuthDeg:aziEle.x elevationDeg:aziEle.y];
		
		[gabors[index] directSetContrast:((index == 0) ? (pSD->contrast0PC / 100.0) : (pSD->contrast1PC / 100.0))];
		[gabors[index] directSetDirectionDeg:((index == 0) ? pSD->orientation0Deg : pSD->orientation1Deg)];
        [gabors[index] directSetSpatialFreqCPD:((index == 0) ? pSD->spatialFreq0CPD : pSD->spatialFreq1CPD)];
        [gabors[index] directSetTemporalFreqHz:((index == 0) ? pSD->temporalFreq0Hz : pSD->temporalFreq1Hz)];
		[gabors[index] setTemporalModulation:0.0];		// Counterphasing
		
		if (temporalFreqFromIndex(pSD->temporalFreqIndex,index) == [[task stimWindow] frameRateHz]/2) {
			//NSLog(@"Changing phase to 90 degrees... ");
			[gabors[index] directSetTemporalPhaseDeg:90.0];
		}
		else {
			[gabors[index] directSetTemporalPhaseDeg:0.0];
		}
		[gabors[index] setAchromatic:YES];
	}
	
	// We must store the setting away so they are available to LLGabor if we do a counterphasing stimulus.
	// No need to restore, because the gabors are loaded fresh for every presentation.
	for (index = 0; gabors[index] != nil; index++) {
		[gabors[index] store];
	}
}



/*
makeStimList()

Make a stimulus list for one trial, with the target in the specified targetIndex position (0 based counting).  
The list is constructed so that each stimulus contrast and temporal frequency combination appears n times before any appears n+1 times.  
In the simplest case, we just draw n unused entries from the done table. If there are fewer than n entries remaining, 
we take them all, clear the table, and then proceed.  We also make a provision for the case where several full table 
worth's will be needed to make the list.  Whenever we take all the entries remaining in the table, we simply draw them
in order and then use shuffleStimList() to randomize their order.  Shuffling does not span the borders between successive
doneTables, to ensure that each stimulus pairing will be presented n times before any appears n + 1 times, even if each appears
several times within one trial.

Two types of padding stimuli are used.  Padding stimuli are inserted in the list after the target, so that the stream of stimuli
continues through the reaction time.  Padding stimuli are also optionally put at the start of the trial.  This is so the first few
stimulus presentations, which might have response transients, are not counted.  The number of padding stimuli at the end of the trial
is determined by stimRateHz and reactTimeMS.  The number of padding stimuli at the start of the trial is determined by rate of presentation
and stimLeadMS.  Note that it is possible to set parameters so that there will never be anything except targets and padding stimuli 
(e.g., with a short maxTargetS and a long stimLeadMS).

*/

- (void)makeStimList:(TrialDesc *)pTrial {
	long targetIndex, distIndex, instructTrial;
	long c, contrasts, cInStart, cIndex, t, temporalFreqs, tInStart, tIndex;
	long stim, sectionStart, frontPadStim, nextStimOnFrame;
	long stimDurFrames, interDurFrames, stimJitterPC, interJitterPC, stimJitterFrames, interJitterFrames;
	long stimDurBase, interDurBase, remaining, stimListLength, minStimDone;
	float stimRateHz, stimOrientation0, stimOrientation1, changeInOrientation;
	long i;
	StimDesc stimDesc;
	BOOL insertDist;
    bool useSingleStimulusPerTrialFlag;
	
	attendLoc = pTrial->attendLoc;
	targetIndex = pTrial->targetIndex;
	distIndex = pTrial->distIndex;
	stimOrientation0 = pTrial->stimulusOrientation0;
    stimOrientation1 = pTrial->stimulusOrientation1;
	changeInOrientation = pTrial->changeInOrientation;
	stimListLength = pTrial->numStim;
	instructTrial = pTrial->instructTrial;
	
	stimRateHz = 1000.0 / ([[task defaults] integerForKey:SRCStimDurationMSKey] + [[task defaults] integerForKey:SRCInterstimMSKey]);
	

	/* To make our list, we will first build it up to targetIndex, and then add back padding characters.  However, targetIndex may be beyond
	 stimListLength.  If that happens, set targetIndex to stimListLength so we can use it as a limit in either case. */
	
	targetIndex = MIN(targetIndex, stimListLength);
	distIndex = MIN(distIndex, stimListLength);
	
	/* frontPadStim are stimuli at the beginning of the sequence that are not counted. This serves to eliminate response transients at the start
	 of the sequence. There is always at least one pad stimulus, so that a non-zero contrast starting stimulus can be a reference if the target 
	 is to come in the second position */
	
	frontPadStim = MAX(1, MIN(targetIndex, ceil([[task defaults] integerForKey:SRCStimLeadMSKey] / 1000.0 * stimRateHz)));

	/* If distractors are going to appear after the front padding stimuli and before the target stimulus, then they will appear among valid stimuli.
	 We have to make sure that the presentation of the distractor is not counted as a valid stimulus.  The easiest way to do that is to shorten the
	 stimListLength by the number of distractors, and then inserting the (extra) distractor stimuli after the list has been made.  In this way we make
	 sure that we don't invalidate one of the stimulus presentation that should be valid. */
	
	insertDist = (distIndex >= frontPadStim && distIndex < targetIndex);
	if (insertDist) {
		stimListLength -= 1;
		targetIndex -= 1;
	}

	// Count the number of undone conditions in the done table	
	contrasts = [[task defaults] integerForKey:SRCContrastsKey];
	temporalFreqs = [[task defaults] integerForKey:SRCTemporalFreqsKey];
	
	for (c = 0, minStimDone = LONG_MAX; c < contrasts; c++) {	// copy doneTable, get minimum
		for (t = 0; t < temporalFreqs; t++) {
			selectTable[c][t] = stimDone[pTrial->attendLoc][c][t];
			minStimDone = MIN(minStimDone, selectTable[c][t]);
		}
	}
	for (c = remaining = 0; c < contrasts; c++) {				// count number remaining in table
		for (t = 0; t < temporalFreqs; t++) {
			selectTable[c][t] -= minStimDone;
			remaining += (selectTable[c][t] == 0) ? 1 : 0;
		}
	}
	[stimList removeAllObjects];

    useSingleStimulusPerTrialFlag = [[task defaults] boolForKey:SRCUseSingleStimulusPerTrialKey];
    
    if (useSingleStimulusPerTrialFlag) {     // Find a single stimulus that has not been done yet
        if (remaining > 0) {
            c = cInStart = (rand() % contrasts);
            t = tInStart = (rand() % temporalFreqs);
        
            while (selectTable[c][t] != 0) {
                c = (c + 1) % contrasts;
                if (c == cInStart) {
                    t = (t + 1) % temporalFreqs;
                
                    if (t == tInStart) {
                        break;
                    }
                }
            }
            cSingleStimulusPerTrial = c;
            tSingleStimulusPerTrial = t;
            
            // Only when a single stimulus needs to be presented, use potentially different orientations
            if (t==1) {
                changeInOrientation = pTrial->changeInOrientationTF1;
            }
            else if (t==2) {
                changeInOrientation = pTrial->changeInOrientationTF2;
            }
        }
        NSLog(@"%ld %ld %f", cSingleStimulusPerTrial,tSingleStimulusPerTrial,changeInOrientation);
    }
    
	/* The start of the list must begin with the number of requested padding stimuli.  These are simply taken at random from all stimuli.  We don't scramble
	 this section, because it is random. The very first stimulus in the sequence is always a padding stimulus, and we make this highly visible. */

	for (stim = 0; stim < frontPadStim; stim++) {
		cIndex = (stim == 0) ? [self randomHighContrastIndex:contrasts] : [self randomVisibleContrastIndex:contrasts];
		tIndex = rand() % temporalFreqs;
		[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kFrontPadding type1:kFrontPadding contrastIndex:cIndex temporalFreqIndex:tIndex];
	}
	
	/* If there are fewer than the number of stim we need remaining in the current doneTable, pick up all that are there, clearing the table as we go. */
	
	sectionStart = [stimList count];				// start of the current section (for scrambling)
	if (remaining < (targetIndex - sectionStart)) {	// need all remaining in block?
		for (c = 0; c < contrasts; c++) {
			for (t = 0; t < temporalFreqs; t++) {
				if (selectTable[c][t] == 0) {
					[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kValidStim type1:kValidStim contrastIndex:c temporalFreqIndex:t];
				}
				else {
					selectTable[c][t] = 0;
				}
			}
		}
		[self shuffleStimListFrom:sectionStart count:remaining];
		
		// For long trials, we might need more than a complete doneTable's worth of stimuli. If that is the case, keep grabbing full image set until 
		// we need less than a full table

		sectionStart = [stimList count];
		while ((targetIndex - sectionStart) > contrasts*temporalFreqs) {
			for (c = 0; c < contrasts; c++) {
				for (t = 0; t < temporalFreqs; t++) {
					[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kValidStim type1:kValidStim contrastIndex:c temporalFreqIndex:t];
				}
			}
			[self shuffleStimListFrom:sectionStart count:(long)(contrasts*temporalFreqs)];
			sectionStart = [stimList count];
		}
	}

	// At this point there are enough available entries in selectTable to fill the rest of the stimList.	
	while ([stimList count] < targetIndex) {
		c = cInStart = (rand() % contrasts);
		t = tInStart = (rand() % temporalFreqs);
		
		while (selectTable[c][t] != 0) {
			c = (c + 1) % contrasts;
			if (c == cInStart) {
				t = (t + 1) % temporalFreqs;
				
				if (t == tInStart) {
					break;
				}
			}
		}
		if (selectTable[c][t] > 0) {
			NSLog(@"makeStimList: scanned table without finding empty entry");
		}
		selectTable[c][t]++;
		[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kValidStim type1:kValidStim contrastIndex:c temporalFreqIndex:t];
	}
	
	// If this is not a catch trial, load the target stimulus, chosen at random from all non-zero contrasts
	if (targetIndex < stimListLength) {	

        if (useSingleStimulusPerTrialFlag) {
            pTrial->targetContrastIndex = cSingleStimulusPerTrial;
            pTrial->targetTemporalFreqIndex = tSingleStimulusPerTrial;
        }
        else {
            if ([[task defaults] boolForKey:SRCUseSmallestContrastTargetKey])
                pTrial->targetContrastIndex = [self randomVisibleContrastIndex:contrasts];
            else
                pTrial->targetContrastIndex = [self randomVisibleAndNotSmallestContrastIndex:contrasts];
		
            pTrial->targetTemporalFreqIndex = (rand() % temporalFreqs);
        }

		if (attendLoc == kAttend0) {
			[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kTargetStim
									  type1:kValidStim contrastIndex:pTrial->targetContrastIndex temporalFreqIndex:pTrial->targetTemporalFreqIndex];
		}
		else {
			[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kValidStim
						type1:kTargetStim contrastIndex:pTrial->targetContrastIndex temporalFreqIndex:pTrial->targetTemporalFreqIndex];
		}
	}
	else {
		pTrial->targetContrastIndex = -1;
		pTrial->targetTemporalFreqIndex = -1;
	}
	
	// Load the trailing stimuli.  These are just pulled at random and not tallied or shuffled.
	while ([stimList count] < stimListLength) {
		[self insertStimSettingsAtIndex:-1 trial:pTrial type0:kBackPadding type1:kBackPadding contrastIndex:(rand() % contrasts) temporalFreqIndex:(rand() % temporalFreqs)];
	}

   /* If distractor stimuli are going to appear after the front padding stimuli and before the target stimulus, then they will appear
   among valid stimuli.  We have to make sure that the presentation of the distractor is not counted as a valid stimulus.  To do this, 
   we shortened the stimListLength by the number of distrators.  Now that the list has been made, we need to insert any (extra) distractors.
   In this way we make sure that we don't invalidate one of the stimulus presentation that should be valid.
   
   If a distractor is off the end of the list, we do nothing.  If it is among the front padding stimuli, or at or beyond the target, we simply
   set the unattended location stimulus type to a target.  Things are more complicated if a distractor appears after the front padding stimuli, 
   but before the target.  In that case, we will have artificially dropped one stimulus from the list before it was created (above, at the start
   of the function).  We now insert a distractor stimulus in the correct place, and shove all the remaining stimuli back one position, restoring
   the list to its proper length. 
   
   021118 Changed the load so that the distractor always has the highest contrast. 
   
	Do a distractor that is among valid stimuli */

	if (insertDist) {
			[self insertStimSettingsAtIndex:distIndex trial:pTrial type0:((attendLoc == kAttend0) ? kValidStim : kTargetStim)
					type1:((attendLoc == kAttend0) ? kTargetStim : kValidStim) contrastIndex:[self randomVisibleContrastIndex:contrasts] temporalFreqIndex:(rand() % temporalFreqs)];
	}
		
	// Place distractor in front or back padding stimuli, or with target
	else { 
		if (distIndex < [stimList count]) {		// distractor within the stim list
			[[stimList objectAtIndex:distIndex] getValue:&stimDesc];
			
			if (attendLoc == kAttend0) {
				stimDesc.type1 = kTargetStim;
				stimDesc.orientation1Deg = (pTrial->stimulusOrientation1 + changeInOrientation);
			}
			else {
				stimDesc.type0 = kTargetStim;
				stimDesc.orientation0Deg = (pTrial->stimulusOrientation0 + changeInOrientation);
			}
			[stimList replaceObjectAtIndex:distIndex 
								withObject:[NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]];
		}
	}
	
	
	if ([[task defaults] boolForKey:SRCHoldTargetOrientationKey]) {
	
		// If the holdTargetOrientationKey is true, we replace the orientation of all stimuli after the target stimuli to be equal to the target orientation
		if (targetIndex < stimListLength) {
			for (i=targetIndex; i<[stimList count]; i++) {
				[[stimList objectAtIndex:i] getValue:&stimDesc];
			
				if (stimDesc.attendLoc == kAttend0) {
					stimDesc.orientation0Deg = (pTrial->stimulusOrientation0 + changeInOrientation);
				}
				else {
					stimDesc.orientation1Deg = (pTrial->stimulusOrientation1 + changeInOrientation);
				}
				[stimList replaceObjectAtIndex:i 
									withObject:[NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]];
			}
		}
	}
			

	/* Now the list is complete.  We make a pass through the list loading the stimulus presention frames.  At the same time, for instruction trials
	 we set all the distractor stimulus types to kNull, so nothing will appear there */

	stimJitterPC = [[task defaults] integerForKey:SRCStimJitterPCKey];
	interJitterPC = [[task defaults] integerForKey:SRCInterstimJitterPCKey];
	stimDurFrames = [[task defaults] integerForKey:SRCStimDurationMSKey] / 1000.0 * display.frameRateHz;
	interDurFrames = [[task defaults] integerForKey:SRCInterstimMSKey] / 1000.0 * display.frameRateHz;
	stimJitterFrames = stimDurFrames / 100.0 * stimJitterPC;
	interJitterFrames = interDurFrames / 100.0 * interJitterPC;
	stimDurBase = stimDurFrames - stimJitterFrames;
	interDurBase = interDurFrames - interJitterFrames;
	
 	for (stim = nextStimOnFrame = 0; stim < [stimList count]; stim++) {
		[[stimList objectAtIndex:stim] getValue:&stimDesc];
		stimDesc.stimOnFrame = nextStimOnFrame;
		if (stimJitterFrames > 0) {
			stimDesc.stimOffFrame = stimDesc.stimOnFrame + MAX(1, stimDurBase + (rand() % (2 * stimJitterFrames + 1)));
		}
		else {
			stimDesc.stimOffFrame = stimDesc.stimOnFrame +  MAX(1, stimDurFrames);
		}
		if (interJitterFrames > 0) {
			nextStimOnFrame = stimDesc.stimOffFrame + 
				MAX(1, interDurBase + (rand() % (2 * interJitterFrames + 1)));
		}
		else {
			nextStimOnFrame = stimDesc.stimOffFrame + MAX(1, interDurFrames);
		}

		// Fix instruction trials
		if (instructTrial) {			
			if (attendLoc == kAttend0) {
				stimDesc.type1 = kNullStim;
				stimDesc.orientation1Deg = stimOrientation1;
			}
			else {
				stimDesc.type0 = kNullStim;
				stimDesc.orientation0Deg = stimOrientation0;
			}
		}
		[stimList replaceObjectAtIndex:stim withObject: [NSValue valueWithBytes:&stimDesc objCType:@encode(StimDesc)]];
	}
	
/*	for (i=0;i<[stimList count];i++) {
		[[stimList objectAtIndex:i] getValue:&stimDesc];
		
		NSLog(@"%ld contrast: %ld, TF: %ld",i, stimDesc.contrastIndex, stimDesc.temporalFreqIndex);
		
	} */
}


- (LLIntervalMonitor *)monitor {

	return monitor;
}


- (void)presentStimList {
    long trialFrame, gaborFrame, stimIndex;
	StimDesc stimDesc;
    NSAutoreleasePool *threadPool;

    threadPool = [[NSAutoreleasePool alloc] init];		// create a threadPool for this thread
	[LLSystemUtil setThreadPriorityPeriodMS:1.0 computationFraction:0.250 constraintFraction:1.0];
	[monitor reset]; 
	
	// Set up the stimulus calibration, including the offset then present the stimulus sequence
	[[task stimWindow] lock];
	[[task stimWindow] setScaleOffsetDeg:[[task eyeCalibrator] offsetDeg]];
	[[task stimWindow] scaleDisplay];

	// Set up the gabors
	stimIndex = 0;
	[[stimList objectAtIndex:stimIndex] getValue:&stimDesc];
	[self loadGaborsWithStimDesc:&stimDesc];

    for (trialFrame = gaborFrame = 0; !abortStimuli; trialFrame++) {
		glClear(GL_COLOR_BUFFER_BIT);
//		if (trialFrame >= stimDesc.stimOnFrame && trialFrame < stimDesc.stimOffFrame) {  // This is the "correct" one
		if (trialFrame >= stimDesc.stimOnFrame && trialFrame <= stimDesc.stimOffFrame) { // Use this one to remove the "flicker" when the interstim interval is zero
			
			[gabor0 directSetFrame:[NSNumber numberWithLong:gaborFrame]];	// advance for temporal modulation
			if (stimDesc.type0) [gabor0 draw];
			
			[gabor1 directSetFrame:[NSNumber numberWithLong:gaborFrame]];	// advance for temporal modulation
			if (stimDesc.type1) [gabor1 draw];
			gaborFrame++;
		}
		[cueSpot draw];
		[fixSpot draw];
		[[NSOpenGLContext currentContext] flushBuffer];
		glFinish();
		[monitor recordEvent];
		if (trialFrame == stimDesc.stimOnFrame) {
			if (trialFrame == 0){
				[[task dataDoc] putEvent:@"visualStimsOn"];
			}
			[[task dataDoc] putEvent:@"stimulus" withData:&stimDesc];
			[[task dataDoc] putEvent:@"stimulusOn" withData:&trialFrame];
            [digitalOut outputEvent:kStimulusOnDigitOutCode sleepInMicrosec:kSleepInMicrosec];
            
//			[digitalOut outputEventName:@"stimulusOn" withData:0x0000];
//			[digitalOut outputEventName:@"temporalFrequencyIndex" withData:(stimDesc.temporalFreqIndex)];
//			[digitalOut outputEventName:@"contrastIndex" withData:(stimDesc.contrastIndex)];
//			[digitalOut outputEventName:@"type0" withData:(stimDesc.type0)];
//			[digitalOut outputEventName:@"type1" withData:(stimDesc.type1)];
			
			if ((attendLoc == 0 && stimDesc.type0 == kTargetStim) ||
					(attendLoc == 1 && stimDesc.type1 == kTargetStim)) {
					targetPresented = YES;
			}
			else if ((attendLoc == 1 && stimDesc.type0 == kTargetStim) ||
					(attendLoc == 0 && stimDesc.type1 == kTargetStim)) {
				distracterPresented = YES;
			}
		}
		else if (trialFrame == stimDesc.stimOffFrame) {
			[[task dataDoc] putEvent:@"stimulusOff" withData:&trialFrame];
//			[digitalOut outputEventName:@"stimulusOff" withData:0x0000];
            [digitalOut outputEvent:kStimulusOffDigitOutCode sleepInMicrosec:kSleepInMicrosec];
			
			if (++stimIndex >= [stimList count]) {
				break;
			}
			[[stimList objectAtIndex:stimIndex] getValue:&stimDesc];
			[self loadGaborsWithStimDesc:&stimDesc];
			gaborFrame = 0;
		}
    }

	// Clear the display and leave the back buffer cleared
    glClear(GL_COLOR_BUFFER_BIT);
    [[NSOpenGLContext currentContext] flushBuffer];
	glFinish();

	[[task stimWindow] unlock];
	
	// The temporal counterphase might have changed some settings.  We restore these here.
	stimulusOn = abortStimuli = NO;
    [threadPool release];
}


- (long)randomHighContrastIndex:(long)contrasts {
	switch (contrasts) {
		case 1:
			return(0);
			break;
		case 2:
			return(1);
			break;
		default:
			return((contrasts + 1) / 2 + (rand() % (contrasts / 2)));
			break;
	}
}

// Return a random contrast index that will not correspond to 0% contrast
- (long)randomVisibleContrastIndex:(long)contrasts {
	if (contrasts <= 1) {
		return(0);
	}
	else {
		return((rand() % (contrasts - 1)) + 1);
	}
}

- (long)randomVisibleAndNotSmallestContrastIndex:(long)contrasts {
	if (contrasts <= 2) {
		return(0);
	}
	else {
		return((rand() % (contrasts - 2)) + 2);
	}
}

- (void)setCueSpot:(BOOL)state location:(long)loc {
	NSPoint aziEle;
	
	[cueSpot setState:state];
	aziEle = azimuthAndElevationForStimIndex(loc);
	[cueSpot setAzimuthDeg:aziEle.x];					// must use key-value compliant calls
	[cueSpot setElevationDeg:aziEle.y];					// must use key-value compliant calls	
	if (!stimulusOn) {
		[[task stimWindow] lock];
		[[task stimWindow] setScaleOffsetDeg:[[task eyeCalibrator] offsetDeg]];
		[[task stimWindow] scaleDisplay];
		glClear(GL_COLOR_BUFFER_BIT);
		[cueSpot draw];
		[fixSpot draw];
		[[NSOpenGLContext currentContext] flushBuffer];
		[[task stimWindow] unlock];
	}
}

- (void)setFixSpot:(BOOL)state {
	[fixSpot setState:state];
	if (state) {
		if (!stimulusOn) {
			[[task stimWindow] lock];
			[[task stimWindow] setScaleOffsetDeg:[[task eyeCalibrator] offsetDeg]];
			[[task stimWindow] scaleDisplay];
			glClear(GL_COLOR_BUFFER_BIT);
			[fixSpot draw];
			[[NSOpenGLContext currentContext] flushBuffer];
			[[task stimWindow] unlock];
		}
	}
}

// Shuffle the stimulus sequence by repeated passed along the list and paired substitution
- (void)shuffleStimListFrom:(long)start count:(long)count {
	long rep, reps, stim, index, temp, indices[kMaxContrasts*kMaxTemporalFreqs];
	NSArray *block;
	
	reps = 5;	
	for (stim = 0; stim < count; stim++) {			// load the array of indices
		indices[stim] = stim;
	}
	for (rep = 0; rep < reps; rep++) {				// shuffle the array of indices
		for (stim = 0; stim < count; stim++) {
			index = rand() % count;
			temp = indices[index];
			indices[index] = indices[stim];
			indices[stim] = temp;
		}
	}
	
	block = [stimList subarrayWithRange:NSMakeRange(start, count)];
	
	for (index = 0; index < count; index++) {
		[stimList replaceObjectAtIndex:(start + index) withObject:[block objectAtIndex:indices[index]]];
	}
}


- (void)startStimList {
	if (stimulusOn) {
		return;
	}
	stimulusOn = YES;
	targetPresented = NO;
	distracterPresented = NO;
   [NSThread detachNewThreadSelector:@selector(presentStimList) toTarget:self withObject:nil];
}

- (BOOL)stimulusOn {
	return stimulusOn;
}

// Stop on-going stimulation and clear the display
- (void)stopAllStimuli {
	if (stimulusOn) {
		abortStimuli = YES;
		while (stimulusOn) {};
	}
	else {
		[stimuli setFixSpot:NO];
		[self erase];
	}
}


- (long)stimuliAddedThisTrial {
	StimDesc stimDesc;
	long index;
	long addedStim=0;
    bool useSingleStimulusPerTrialFlag;
    long atLeastOneValidStim = 0;
    useSingleStimulusPerTrialFlag = [[task defaults] boolForKey:SRCUseSingleStimulusPerTrialKey];
	
	for (index = 0; index < [stimList count]; index++) {
		[[stimList objectAtIndex:index] getValue:&stimDesc];
		if (stimDesc.type0 == kValidStim && stimDesc.type1 == kValidStim) {
            if (useSingleStimulusPerTrialFlag) {
                atLeastOneValidStim = 1;
            }
            else {
                addedStim++;
            }
		}
	}
    if (useSingleStimulusPerTrialFlag) {
        return atLeastOneValidStim;
    }
    else {
        return addedStim;
    }
}

// Count the stimuli in the StimList as successfully completed
- (void)tallyStimuli {
	StimDesc stimDesc;
	long index;
    bool useSingleStimulusPerTrialFlag;
    bool atLeastOneValidStim = NO;
    useSingleStimulusPerTrialFlag = [[task defaults] boolForKey:SRCUseSingleStimulusPerTrialKey];
    
	for (index = 0; index < [stimList count]; index++) {
		[[stimList objectAtIndex:index] getValue:&stimDesc];
		if (stimDesc.type0 == kValidStim && stimDesc.type1 == kValidStim) {
            if (useSingleStimulusPerTrialFlag) {
                atLeastOneValidStim = YES;
            }
            else {
                stimDone[stimDesc.attendLoc][stimDesc.contrastIndex][stimDesc.temporalFreqIndex]++;
            }
		}
	}
    
    if (atLeastOneValidStim)
        stimDone[stimDesc.attendLoc][cSingleStimulusPerTrial][tSingleStimulusPerTrial]++;
}

- (BOOL)targetPresented {
	return targetPresented;
}

- (BOOL)distracterPresented {
	return distracterPresented;
}

@end
