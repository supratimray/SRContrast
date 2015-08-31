//
//  SRCStateSystem.h
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRC.h"

#define		kFixOnSound				@"6C"
#define		kFixateSound			@"7G"
#define		kStimOnSound			@"5C"
#define		kStimOffSound			@"4F"
#define 	kCorrectSound			@"Correct"
#define 	kNotCorrectSound		@"NotCorrect"
#define 	kFalseAlarmSound		@"loud200Hz200msSq"

extern short				attendLoc;
extern long					eotCode;			// End Of Trial code
extern LLEyeWindow			*fixWindow;
extern LLScheduleController *scheduler;
extern LLEyeWindow			*respWindows[kRespLocations];
extern TrialDesc			trial;

@interface SRCStateSystem : LLStateSystem {

	long			stimType;
}

@end

