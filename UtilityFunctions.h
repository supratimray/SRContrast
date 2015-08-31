//
//  UtilityFunctions.h
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#include "SRC.h"

void			announceEvents(void);
NSPoint			azimuthAndElevationForStimIndex(long index);
float			contrastFromIndex(long index);
float			temporalFreqFromIndex(long index); 
StimParams		*getContrastParams(void);
StimParams		*getTemporalFreqParams(void);
void			putBlockDataEvents(long blocksDone, long location);
void			requestReset(void);
void			reset(void);
BOOL			selectTrial(long *pIndex);
float			spikeRateFromStimValue(float normalizedValue);
long			stimPerBlock(void);
long			stimDoneThisBlock(long blocksDone, long location);
long			stimDoneThisBlockGivenTemporalFreq(long blocksDone, long location, long tindex);
long			stimDoneAllBlocks(long location);
long			stimDoneAllBlocksGivenTemporalFreq(long location, long tindex);	
long			repsDoneAtLoc(long loc);
void			updateBlockStatus(void);
float			valueFromIndex(long index, StimParams *pStimParams);
float			maxAllowableTempFreq(void);
