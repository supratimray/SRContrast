/*
 *  SRC.h
 *  SRContrast
 *
 *  Copyright (c) 2006. All rights reserved.
 *
 */
@class SRCDigitalOut;

#ifdef MAIN
#define EXTERN
#else
#define EXTERN	extern 
#endif

#define kRadiansPerDeg      (kPI / 180.0)
#define kDegPerRadian		(180.0 / kPI)


// The following should be changed to be unique for each application

enum {kAttend0 = 0, kAttend1, kLocations};
enum {kNullStim = 0, kValidStim, kTargetStim, kFrontPadding, kBackPadding};
//enum {kV1ECoGExperiment = 0, kV1MicroElectrodeExperiment, kV4MicroElectrodeExperiment, kExperimentTypes};

// False Alarm
#define		kEOTFAlarm			(kEOTIgnored + 1) 
// Distracted by distracter
#define		kEOTDistracted		(kEOTIgnored + 2)

#define		kEOTTotal			(kEOTIgnored + 3)
#define		kEOTForceQuit		kEOTQuit + 2

#define		kMaxContrasts			16
#define		kMaxTemporalFreqs		8

#define		kRespLocations			kLocations

typedef struct {
	long	levels;				// number of active stimulus levels
	float   maxValue;			// maximum stimulus value
	float   factor;				// factor between values
} StimParams;

typedef struct BlockStatus {
	long attendLoc;											// currently attended location
	long instructsDone;										// number of instructions completed this loc
	long presentationsPerLoc;								// number of stimulus presentations on each loc (contrasts * temp freqs * reps)
	long presentationsDoneThisLoc;							// number presentations completed, current loc, current block
	long locsPerBlock;										// number of locations (kLocations)	
	long locsDoneThisBlock;									// number of locations completed, current block	
	long blockLimit;										// number of blocks before stopping
	long blocksDone;										// number of blocks completed
} BlockStatus;

typedef struct StimDesc {
	long	attendLoc;				// Location to attend
	long	stimOnFrame;
	long	stimOffFrame;
	long	type0;					// 'type' of stimulus at location 0. The possible types are - Null (0), Valid (1), Target (2), FrontPadding (3), BackPadding (4)
	long	type1;					// 'type' of stimulus at location 1.
	long	contrastIndex;			// Contrast index number of the stimulus at both locations
	long	temporalFreqIndex;		// Temporal frequency of both stimuli
	float	orientation0Deg;		// Orientation of the stimulus at location 0
	float	orientation1Deg;		// Orientation of the stimulus at location 1
    float   spatialFreq0CPD;
    float   spatialFreq1CPD;
    float   temporalFreq0Hz;
    float   temporalFreq1Hz;
} StimDesc;

typedef struct TrialDesc {
	BOOL	catchTrial;				// Indicates if this is a catch trial 
	BOOL	instructTrial;			// Indicates if this is an instruction trial
	long	attendLoc;				// Location to attend
	long	numStim;				// Number of stimuli in the trial
	float	stimulusOrientation0;		// Orientation of the stimulus
    float	stimulusOrientation1;		// Orientation of the stimulus
	float	changeInOrientation;			// Change in orientation in the target (and distractor)
	long	targetIndex;				// Position of the target stimulus
	long	distIndex;					// Position of the distractor stimulus
	long	targetContrastIndex;		// Contrast index of the target (and distractor)
	long	targetTemporalFreqIndex;	// Temporal freq index of the target (and distractor)
} TrialDesc;



#ifndef	NoGlobals

// Behavior settings dialog

extern NSString *SRCAcquireMSKey;
extern NSString *SRCBlockLimitKey;
extern NSString *SRCBreakPunishMSKey;
extern NSString *SRCCueMSKey;
extern NSString *SRCDoSoundsKey;
extern NSString *SRCFixateKey;
extern NSString *SRCFixateMSKey;
extern NSString *SRCFixGraceMSKey;
extern NSString *SRCFixWindowWidthDegKey;
extern NSString *SRCHoldTargetOrientationKey;
extern NSString *SRCIntertrialMSKey;
extern NSString *SRCMaxTargetMSKey;
extern NSString *SRCMeanTargetMSKey;
extern NSString *SRCNontargetContrastPCKey;
extern NSString *SRCNumInstructTrialsKey;
extern NSString *SRCPrecueMSKey;
extern NSString *SRCPrecueJitterPCKey;
extern NSString *SRCRelDistractorProbKey;
extern NSString *SRCRespSpotSizeDegKey;
extern NSString *SRCRespTimeMSKey;
extern NSString *SRCRespWindowWidthDegKey;
extern NSString *SRCRewardMSKey;
extern NSString *SRCSaccadeTimeMSKey;
extern NSString *SRCStimRepsPerBlockKey;			
extern NSString *SRCTooFastMSKey;
extern NSString *SRCTriesKey;
extern NSString *SRCVarRewardOnKey;
extern NSString *SRCVarRewardMinMSKey;
extern NSString *SRCVarRewardMaxMSKey;
extern NSString *SRCVarRewardTCKey;
extern NSString *SRCVarRewardMeanKey;
extern NSString *SRCUseSmallestContrastTargetKey;


// Stimulus Settings Dialog
// Experiment
extern NSString *SRCPreferredLocKey;

// Timing Information
extern NSString *SRCStimLeadMSKey;
extern NSString *SRCStimDurationMSKey;
extern NSString *SRCStimJitterPCKey;
extern NSString *SRCInterstimMSKey;
extern NSString *SRCInterstimJitterPCKey;

// Gabor 0 Settings
extern NSString *SRCSpatialFreq0CPDKey;
extern NSString *SRCStimulusOrientation0DegKey;
extern NSString *SRCAzimuth0DegKey;
extern NSString *SRCElevation0DegKey;

// Gabor 1 Settings
extern NSString *SRCSpatialFreq1CPDKey;
extern NSString *SRCStimulusOrientation1DegKey;
extern NSString *SRCAzimuth1DegKey;
extern NSString *SRCElevation1DegKey;

// Variable Gabor Settings
extern NSString *SRCChangeInOrientationDegKey;
extern NSString *SRCGaborRadiusDegKey;
extern NSString *SRCGaborSigmaDegKey;

extern NSString *SRCContrastsKey;					// Number of contrasts
extern NSString *SRCMaxContrastKey;
extern NSString *SRCContrastFactorKey;
extern NSString *SRCDistractorContrastRatioKey;

extern NSString	*SRCTemporalFreqsKey;
extern NSString	*SRCMaxTemporalFreqHzKey;
extern NSString *SRCTemporalFreqFactorKey;
extern NSString *SRCGaborTemporalFreqHzKey;

extern NSString *SRCCoupleTemporalFreqsKey;
extern NSString *SRCUseStaircaseProcedureKey;

#import "SRCStimuli.h"

BlockStatus						blockStatus;
BOOL							brokeDuringStim;
BOOL							resetFlag;
LLScheduleController			*scheduler;
long							stimDone[kLocations][kMaxContrasts][kMaxTemporalFreqs];
SRCStimuli						*stimuli;
SRCDigitalOut					*digitalOut;
NSTimeInterval					tooFastExpire;
NSTimeInterval					tooFastExpireDist;
NSTimeInterval					respTimeWinDist;

#endif

LLTaskPlugIn					*task;
