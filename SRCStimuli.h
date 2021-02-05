/*
SRCStimuli.h
*/

#import "SRC.h"

@interface SRCStimuli : NSObject {

	LLGabor					*gabor0;
	LLGabor					*gabor1;
	BOOL					abortStimuli;
	long					attendLoc;
	LLFixTarget				*cueSpot;
	DisplayParam			display;
	long					durationMS;
	float					fixSizePix;
	LLFixTarget				*fixSpot;
	BOOL					fixSpotOn;
	NSArray					*fixTargets;
	LLIntervalMonitor 		*monitor;
	long					selectTable[kMaxContrasts][kMaxTemporalFreqs];
	NSMutableArray			*stimList;
	BOOL					stimulusOn;
	BOOL					targetPresented;
	BOOL					distracterPresented;
    long                    cSingleStimulusPerTrial;
    long                    tSingleStimulusPerTrial;
}

- (DisplayParam *)displayParameters;
- (void)doCueSettings;
- (void)doFixSettings;
- (void)presentStimList;
- (void)dumpStimList;
- (void)erase;
- (LLGabor *)gabor0;
- (LLGabor *)gabor1;
- (LLGabor *)initGabor;
- (void)insertStimSettingsAtIndex:(long)index trial:(TrialDesc *)pTrial 
							type0:(long)type0 type1:(long)type1 contrastIndex:(long)cIndex temporalFreqIndex:(long)tIndex;				
- (void)loadGaborsWithStimDesc:(StimDesc *)pSD;
- (void)makeStimList:(TrialDesc *)pTrial;
- (LLIntervalMonitor *)monitor;
- (long)randomHighContrastIndex:(long)contrasts;
- (long)randomVisibleContrastIndex:(long)contrasts;
- (long)randomVisibleAndNotSmallestContrastIndex:(long)contrasts;
- (void)setCueSpot:(BOOL)state location:(long)loc;
- (void)setFixSpot:(BOOL)state;
- (void)shuffleStimListFrom:(long)start count:(long)count;
- (void)startStimList;
- (BOOL)stimulusOn;
- (void)stopAllStimuli;
- (void)tallyStimuli;
- (long)stimuliAddedThisTrial;
- (BOOL)targetPresented;
- (BOOL)distracterPresented;

@end
