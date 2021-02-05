//
//  SRContrast.m
//  SRContrast
//
//  Copyright 2006. All rights reserved.
//

#import "SRC.h"
#import "SRContrast.h"
#import "SRCSummaryController.h"
#import "SRCBehaviorController.h"
#import "SRCSpikeController.h"
#import "SRCXTController.h"
#import "UtilityFunctions.h"
#import "SRCStateSystem.h"

#define		kRewardBit				0x0001

// Behavioral parameters (alphabetically)
NSString *SRCAcquireMSKey = @"SRCAcquireMS";
NSString *SRCBlockLimitKey = @"SRCBlockLimit";
NSString *SRCBreakPunishMSKey = @"SRCBreakPunishMS";
NSString *SRCCueMSKey = @"SRCCueMS";
NSString *SRCDoSoundsKey = @"SRCDoSounds";
NSString *SRCFixateKey = @"SRCFixate";
NSString *SRCFixateMSKey = @"SRCFixateMS";
NSString *SRCFixGraceMSKey = @"SRCFixGraceMS";
NSString *SRCFixWindowWidthDegKey = @"SRCFixWindowWidthDeg";
NSString *SRCHoldTargetOrientationKey = @"SRCHoldTargetOrientation";
NSString *SRCIntertrialMSKey = @"SRCIntertrialMS";
NSString *SRCMaxTargetMSKey = @"SRCMaxTargetMS";
NSString *SRCMeanTargetMSKey = @"SRCMeanTargetMS";
NSString *SRCNontargetContrastPCKey = @"SRCNontargetContrastPC";
NSString *SRCNumInstructTrialsKey = @"SRCNumInstructTrials";
NSString *SRCPrecueMSKey = @"SRCPrecueMS";
NSString *SRCPrecueJitterPCKey = @"SRCPrecueJitterPC";
NSString *SRCRelDistractorProbKey = @"SRCRelDistractorProb";
NSString *SRCRespSpotSizeDegKey = @"SRCRespSpotSizeDeg";
NSString *SRCRespTimeMSKey = @"SRCRespTimeMS";
NSString *SRCRespWindowWidthDegKey = @"SRCRespWindowWidthDeg";
NSString *SRCRewardMSKey = @"SRCRewardMS";
NSString *SRCSaccadeTimeMSKey = @"SRCSaccadeTimeMS";
NSString *SRCStimRepsPerBlockKey = @"SRCStimRepsPerBlock";
NSString *SRCTaskStatusKey = @"SRCTaskStatus";
NSString *SRCTooFastMSKey = @"SRCTooFastMS";
NSString *SRCTriesKey = @"SRCTries";
NSString *SRCVarRewardOnKey = @"SRCVarRewardOn";
NSString *SRCVarRewardMinMSKey = @"SRCVarRewardMinMS";
NSString *SRCVarRewardMaxMSKey = @"SRCVarRewardMaxMS";
NSString *SRCVarRewardTCKey = @"SRCVarRewardTC";
NSString *SRCVarRewardMeanKey = @"SRCVarRewardMean";
NSString *SRCUseSmallestContrastTargetKey = @"SRCUseSmallestContrastTarget";


// Stimulus Parameters
//Experiment
NSString *SRCPreferredLocKey = @"SRCPreferredLoc";

// Timing Information
NSString *SRCStimLeadMSKey = @"SRCStimLeadMS";
NSString *SRCStimDurationMSKey = @"SRCStimDurationMS";
NSString *SRCStimJitterPCKey = @"SRCStimJitterPC";
NSString *SRCInterstimMSKey = @"SRCInterstimMS";
NSString *SRCInterstimJitterPCKey = @"SRCInterstimJitterPC";

// Gabor 0 Settings
NSString *SRCSpatialFreq0CPDKey = @"SRCSpatialFreq0CPD";
NSString *SRCStimulusOrientation0DegKey = @"SRCStimulusOrientation0Deg";
NSString *SRCAzimuth0DegKey = @"SRCAzimuth0Deg";
NSString *SRCElevation0DegKey = @"SRCElevation0Deg";

// Gabor 1 Settings
NSString *SRCSpatialFreq1CPDKey = @"SRCSpatialFreq1CPD";
NSString *SRCStimulusOrientation1DegKey = @"SRCStimulusOrientation1Deg";
NSString *SRCAzimuth1DegKey = @"SRCAzimuth1Deg";
NSString *SRCElevation1DegKey = @"SRCElevation1Deg";

// Variable Gabor Settings
NSString *SRCChangeInOrientationDegKey = @"SRCChangeInOrientationDeg";
NSString *SRCGaborRadiusDegKey = @"SRCGaborRadiusDeg";
NSString *SRCGaborSigmaDegKey = @"SRCGaborSigmaDeg";

NSString *SRCContrastsKey = @"SRCContrasts";
NSString *SRCMaxContrastKey = @"SRCMaxContrast";
NSString *SRCContrastFactorKey = @"SRCContrastFactor";
NSString *SRCDistractorContrastRatioKey = @"SRCDistractorContrastRatio";

NSString *SRCTemporalFreqsKey = @"SRCTemporalFreqs";
NSString *SRCMaxTemporalFreqHzKey = @"SRCMaxTemporalFreqHz";
NSString *SRCTemporalFreqFactorKey = @"SRCTemporalFreqFactor";
NSString *SRCGaborTemporalFreqHzKey = @"SRCGaborTemporalFreqHz";

NSString *SRCCoupleTemporalFreqsKey = @"SRCCoupleTemporalFreqs";
NSString *SRCUseStaircaseProcedureKey = @"SRCUseStaircaseProcedure";

NSString *SRCUseFeatureAttentionKey = @"SRCUseFeatureAttention";
NSString *SRCFeatureAttentionOrientation0DegKey = @"SRCFeatureAttentionOrientation0Deg";
NSString *SRCFeatureAttentionOrientation1DegKey = @"SRCFeatureAttentionOrientation1Deg";

NSString *SRCUseSingleStimulusPerTrialKey = @"SRCUseSingleStimulusPerTrial";

NSString *keyPaths[] = {@"values.SRCTries", @"values.SRCBlockLimit", @"values.SRCRespTimeMS", @"values.SRCStimDurationMS",
					 @"values.SRCInterstimMS", @"values.SRCContrasts", @"values.SRCMaxContrast", @"values.SRCContrastFactor", 
					 @"values.SRCTemporalFreqs", @"values.SRCMaxTemporalFreqHz", @"values.SRCTemporalFreqFactor",
					 @"values.SRCStimRepsPerBlock", @"values.SRCPreferredLoc", @"values.SRCCoupleTemporalFreqs",
                     @"values.SRCUseFeatureAttention",
                     @"values.SRCUseSingleStimulusPerTrial", nil};

LLScheduleController	*scheduler = nil;
SRCStimuli				*stimuli = nil;
SRCDigitalOut			*digitalOut = nil;

LLDataDef gaborStructDef[] = kLLGaborEventDesc;
LLDataDef fixWindowStructDef[] = kLLEyeWindowEventDesc;
LLDataDef blockStatusDef[] = {
	{@"long",	@"attendLoc", 1, offsetof(BlockStatus, attendLoc)},
	{@"long",	@"instructsDone", 1, offsetof(BlockStatus, instructsDone)},
	{@"long",	@"presentationsPerLoc", 1, offsetof(BlockStatus, presentationsPerLoc)},
	{@"long",	@"presentationsDoneThisLoc", 1, offsetof(BlockStatus, presentationsDoneThisLoc)},
	{@"long",	@"locsPerBlock", 1, offsetof(BlockStatus, locsPerBlock)},
	{@"long",	@"locsDoneThisBlock", 1, offsetof(BlockStatus, locsDoneThisBlock)},	
	{@"long",	@"blockLimit", 1, offsetof(BlockStatus, blockLimit)},
	{@"long",	@"blocksDone", 1, offsetof(BlockStatus, blocksDone)},
	{nil}};
LLDataDef stimParamsDef[] = {
	{@"long",	@"levels", 1, offsetof(StimParams, levels)},
	{@"float",	@"maxValue", 1, offsetof(StimParams, maxValue)},
	{@"float",	@"factor", 1, offsetof(StimParams, factor)},
	{nil}};
LLDataDef stimDescDef[] = {
	{@"long",	@"attendLoc", 1, offsetof(StimDesc, attendLoc)},
	{@"long",	@"stimOnFrame", 1, offsetof(StimDesc, stimOnFrame)},
	{@"long",	@"stimOffFrame", 1, offsetof(StimDesc, stimOffFrame)},
	{@"long",	@"type0", 1, offsetof(StimDesc, type0)},
	{@"long",	@"type1", 1, offsetof(StimDesc, type1)},	
	{@"long",	@"contrastIndex", 1, offsetof(StimDesc, contrastIndex)},
	{@"long",	@"temporalFreqIndex", 1, offsetof(StimDesc, temporalFreqIndex)},
    {@"float",	@"contrast0PC", 1, offsetof(StimDesc, contrast0PC)},
    {@"float",	@"contrast1PC", 1, offsetof(StimDesc, contrast1PC)},
	{@"float",	@"orientation0Deg", 1, offsetof(StimDesc, orientation0Deg)},
	{@"float",	@"orientation1Deg", 1, offsetof(StimDesc, orientation1Deg)},
    {@"float",	@"spatialFreq0CPD", 1, offsetof(StimDesc, spatialFreq0CPD)},
    {@"float",	@"spatialFreq1CPD", 1, offsetof(StimDesc, spatialFreq1CPD)},
    {@"float",	@"temporalFreq0Hz", 1, offsetof(StimDesc, temporalFreq0Hz)},
    {@"float",	@"temporalFreq1Hz", 1, offsetof(StimDesc, temporalFreq1Hz)},
	{nil}};
LLDataDef trialDescDef[] = {
	{@"boolean",@"catchTrial", 1, offsetof(TrialDesc, catchTrial)},
	{@"boolean",@"instructTrial", 1, offsetof(TrialDesc, instructTrial)},
	{@"long",	@"attendLoc", 1, offsetof(TrialDesc, attendLoc)},
	{@"long",	@"numStim", 1, offsetof(TrialDesc, numStim)},
	{@"float",	@"stimulusOrientation0", 1, offsetof(TrialDesc, stimulusOrientation0)},
    {@"float",	@"stimulusOrientation1", 1, offsetof(TrialDesc, stimulusOrientation1)},
	{@"float",	@"changeInOrientation", 1, offsetof(TrialDesc, changeInOrientation)},
	{@"long",	@"targetIndex", 1, offsetof(TrialDesc, targetIndex)},
	{@"long",	@"distIndex", 1, offsetof(TrialDesc, distIndex)},
	{@"long",	@"targetContrastIndex", 1, offsetof(TrialDesc, targetContrastIndex)},
	{@"long",	@"targetTemporalFreqIndex", 1, offsetof(TrialDesc, targetTemporalFreqIndex)},
	{nil}};	
	
DataAssignment eyeXDataAssignment = {@"eyeXData",	@"Synthetic", 0, 5.0};	
DataAssignment eyeYDataAssignment = {@"eyeYData",	@"Synthetic", 1, 5.0};	
DataAssignment spikeDataAssignment = {@"spikeData", @"Synthetic", 2, 1};
DataAssignment VBLDataAssignment =   {@"VBLData",	@"Synthetic", 1, 1};	
	
EventDefinition SRCEvents[] = {
// recorded at start of file
	
	{@"contrastParams",		sizeof(StimParams),		{@"struct", @"contrastParams", 1, 0, sizeof(StimParams), stimParamsDef}},
	{@"temporalFreqParams", sizeof(StimParams),		{@"struct", @"temporalFreqParams", 1, 0, sizeof(StimParams), stimParamsDef}},
	{@"gabor",				sizeof(Gabor),			{@"struct", @"gabor", 1, 0, sizeof(Gabor), gaborStructDef}},
	{@"azimuth0Deg",        sizeof(float),			{@"float"}},
    {@"azimuth1Deg",        sizeof(float),			{@"float"}},
    {@"elevation0Deg",      sizeof(float),			{@"float"}},
	{@"elevation1Deg",      sizeof(float),			{@"float"}},
	
	{@"sigmaDeg",			sizeof(float),			{@"float"}},
	{@"radiusDeg",			sizeof(float),			{@"float"}},
	{@"stimOrientation0Deg", sizeof(float),			{@"float"}},
    {@"stimOrientation1Deg", sizeof(float),			{@"float"}},
	{@"spatialFreq0CPD",	sizeof(float),			{@"float"}},
    {@"spatialFreq1CPD",	sizeof(float),			{@"float"}},
    
// Dialog parameters
	{@"stimDurationMS",		sizeof(long),			{@"long"}},
	{@"stimJitterPC",		sizeof(long),			{@"long"}},
	{@"interstimMS",		sizeof(long),			{@"long"}},
	{@"interstimJitterPC",	sizeof(long),			{@"long"}},
	{@"stimLeadMS",			sizeof(long),			{@"long"}},
	{@"responseTimeMS",		sizeof(long),			{@"long"}},
	{@"tooFastTimeMS",		sizeof(long),			{@"long"}},
	{@"tries",				sizeof(long),			{@"long"}},
	{@"stimRepsPerBlock",	sizeof(long),			{@"long"}},
	{@"preferredLoc",		sizeof(long),			{@"long"}},
    {@"precueDurationMS",	sizeof(long),			{@"long"}},
	{@"precueJitterPC",     sizeof(long),			{@"long"}},
    {@"cueDurationMS",      sizeof(long),			{@"long"}},
    
	{@"taskMode", 			sizeof(long),			{@"long"}},
	{@"reset", 				sizeof(long),			{@"long"}},
	
// declared at start of each trial
	{@"blockStatus",		sizeof(BlockStatus),	{@"struct", @"blockStatus", 1, 0, sizeof(BlockStatus), blockStatusDef}},
	{@"maxTargetIndex",		sizeof(long),			{@"long"}},
	
// marking the course of each trial
//	{@"trialStart",			0,						{@"no data"}},
	{@"trial",				sizeof(TrialDesc),		{@"struct", @"trial", 1, 0, sizeof(TrialDesc), trialDescDef}},
//	{@"eyeWindow",			sizeof(FixWindowData),	{@"struct", @"fixWindowData", 1, 0, sizeof(FixWindowData), fixWindowStructDef}},
	{@"responseWindow",		sizeof(FixWindowData),	{@"struct", @"respWindowData", 1, 0, sizeof(FixWindowData), fixWindowStructDef}},

//	{@"blocked",			0,						{@"no data"}},
//	{@"fixOn",				0,						{@"no data"}},
//	{@"fixate",				0,						{@"no data"}},
	{@"cueOn",				0,						{@"no data"}},
	{@"preStimuli",			0,						{@"no data"}}, 
	{@"visualStimsOn",		0,						{@"no data"}},
	{@"stimulus",			sizeof(StimDesc),		{@"struct", @"stimDesc", 1, 0, sizeof(StimDesc), stimDescDef}},
//	{@"stimulusOn",			sizeof(long),			{@"long"}},
//	{@"stimulusOff",		sizeof(long),			{@"long"}},
	{@"break",				0,						{@"no data"}},	
	{@"saccade",			0,						{@"no data"}},
	
// End Trial		
	{@"stimAdded",			sizeof(long),			{@"long"}},
	{@"rewardLimitMS",		sizeof(long),			{@"long"}},
	{@"juiceMS",			sizeof(long),			{@"long"}},
//	{@"trialEnd",			sizeof(long),			{@"long"}},
//	{@"trialCertify",		sizeof(long),			{@"long"}},
};

BOOL			brokeDuringStim;
BlockStatus		blockStatus;
long			stimDone[kLocations][kMaxContrasts][kMaxTemporalFreqs] = {};
LLTaskPlugIn	*task = nil;
NSTimeInterval	tooFastExpire;


@implementation SRContrast

+ (NSInteger)version {
	return kLLPluginVersion;
}

// Start the method that will collect data from the event buffer
- (void)activate { 
	long longValue;
	NSMenu *mainMenu;
	
	if (active) {
		return;
	}

	// Insert Actions and Settings menus into menu bar
	mainMenu = [NSApp mainMenu];
	[mainMenu insertItem:actionsMenuItem atIndex:([mainMenu indexOfItemWithTitle:@"Tasks"] + 1)];
	[mainMenu insertItem:settingsMenuItem atIndex:([mainMenu indexOfItemWithTitle:@"Tasks"] + 1)];
	
	// Erase the stimulus display
	[stimuli erase];
	
	// Create on-line display windows	
	[[controlPanel window] orderFront:self];
  
	behaviorController = [[SRCBehaviorController alloc] init];
    [dataDoc addObserver:behaviorController];

	//spikeController = [[SRCSpikeController alloc] init];
    //[dataDoc addObserver:spikeController];

    eyeXYController = [[SRCEyeXYController alloc] init];
    [dataDoc addObserver:eyeXYController];

    summaryController = [[SRCSummaryController alloc] init];
    [dataDoc addObserver:summaryController];
 
	xtController = [[SRCXTController alloc] init];
    [dataDoc addObserver:xtController];

	// Set up data events (after setting up windows to receive them)
	[dataDoc defineEvents:[LLStandardDataEvents eventsWithDataDefs] count:[LLStandardDataEvents countOfEventsWithDataDefs]];
	[dataDoc defineEvents:SRCEvents count:(sizeof(SRCEvents) / sizeof(EventDefinition))];
	announceEvents();
	longValue = 0;
	[[task dataDoc] putEvent:@"reset" withData:&longValue];
	

	// Set up the data collector to handle our data types
	[dataController assignSampleData:eyeXDataAssignment];
	[dataController assignSampleData:eyeYDataAssignment];
	[dataController assignTimestampData:spikeDataAssignment];
	[dataController assignTimestampData:VBLDataAssignment];
	[dataController assignDigitalInputDevice:@"Synthetic"];
	[dataController assignDigitalOutputDevice:@"Synthetic"];
	
	xFilter = [[LLFilterExp alloc] init];
	[xFilter setStepWeight:0.01]; 
	//[xFilter setStepWeight:(1.0 - [defaults floatForKey:MSPEyeFilterWeightKey])];
	yFilter = [[LLFilterExp alloc] init];
	[yFilter setStepWeight:0.01]; 
	//[yFilter setStepWeight:(1.0 - [defaults floatForKey:MSPEyeFilterWeightKey])];
	
	collectorTimer = [NSTimer scheduledTimerWithTimeInterval:0.010 target:self 
			selector:@selector(dataCollect:) userInfo:nil repeats:YES];
	[dataDoc addObserver:[task stateSystem]];
	[[self stateSystem] startWithCheckIntervalMS:5];				// Start the experiment state system
	
	active = YES;
}

// The following function is called after the nib has finished loading.  It is the correct
// place to initialize nib related components, such as menus.

- (void)awakeFromNib {
	if (actionsMenuItem == nil) {
		actionsMenuItem = [[NSMenuItem alloc] init]; 
		[actionsMenu setTitle:@"Actions"];
		[actionsMenuItem setSubmenu:actionsMenu];
		[actionsMenuItem setEnabled:YES];
	}
	if (settingsMenuItem == nil) {
		settingsMenuItem = [[NSMenuItem alloc] init]; 
		[settingsMenu setTitle:@"Settings"];
		[settingsMenuItem setSubmenu:settingsMenu];
		[settingsMenuItem setEnabled:YES];
	}
}

- (void)dataCollect:(NSTimer *)timer {
	NSData *data;
	
	if ((data = [dataController dataOfType:@"eyeXData"]) != nil) {
		//data = [xFilter filteredValues:data];
		[dataDoc putEvent:@"eyeXData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyeUnits.x = *(short *)([data bytes] + [data length] - sizeof(short));
	}
	if ((data = [dataController dataOfType:@"eyeYData"]) != nil) {
		//data = [yFilter filteredValues:data];
		[dataDoc putEvent:@"eyeYData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
		currentEyeUnits.y = *(short *)([data bytes] + [data length] - sizeof(short));
		currentEyeDeg = [eyeCalibrator degPointFromUnitPoint:currentEyeUnits];
	}
	if ((data = [dataController dataOfType:@"VBLData"]) != nil) {
		[dataDoc putEvent:@"VBLData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
	}
	if ((data = [dataController dataOfType:@"spikeData"]) != nil) {
		[dataDoc putEvent:@"spikeData" withData:(Ptr)[data bytes] lengthBytes:[data length]];
	}
}
	
// Stop data collection and shut down the plug in
- (void)deactivate:(id)sender {
	if (!active) {
		return;
	}
    [dataController setDataEnabled:[NSNumber numberWithBool:NO]];
    [[self stateSystem] stop];
	[collectorTimer invalidate];
	[xFilter release];
	[yFilter release];
    [dataDoc removeObserver:[self stateSystem]];
    [dataDoc removeObserver:behaviorController];
    //[dataDoc removeObserver:spikeController];
    [dataDoc removeObserver:eyeXYController];
    [dataDoc removeObserver:summaryController];
    [dataDoc removeObserver:xtController];
	[dataDoc clearEventDefinitions];

	// Remove Actions and Settings menus from menu bar
	[[NSApp mainMenu] removeItem:settingsMenuItem];
	[[NSApp mainMenu] removeItem:actionsMenuItem];

	// Release all the display windows
    [behaviorController close];
    [behaviorController release];
    //[spikeController close];
    //[spikeController release];
    [eyeXYController deactivate];			// requires a special call
    [eyeXYController release];
    [summaryController close];
    [summaryController release];
    [xtController close];
    [xtController release];
    [[controlPanel window] close];
	
	active = NO;
}

- (void)dealloc {
	long index;
 
	while ([[self stateSystem] running]) {};		// wait for state system to stop, then release it
	
	for (index = 0; keyPaths[index] != nil; index++) {
		[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:keyPaths[index]];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 

    [[task dataDoc] removeObserver:[self stateSystem]];
    [[self stateSystem] release];
	
	[actionsMenuItem release];
	[settingsMenuItem release];
	[scheduler release];
	[stimuli release];
	[digitalOut release];
	[controlPanel release];
	[taskStatus dealloc];
	[super dealloc];
}

- (void)doControls:(NSNotification *)notification {
	if ([[notification name] isEqualToString:LLTaskModeButtonKey]) {
		[self doRunStop:self];
	}
	else if ([[notification name] isEqualToString:LLJuiceButtonKey]) {
		[self doJuice:self];
	}
	if ([[notification name] isEqualToString:LLResetButtonKey]) {
		[self doReset:self];
	}
}

- (IBAction)doCueSettings:(id)sender {
	[stimuli doCueSettings];
}

- (IBAction)doFixSettings:(id)sender {
	[stimuli doFixSettings];
}

/*- (IBAction)doGaborSettings:(id)sender {
	[stimuli doGaborSettings];
}*/

- (IBAction)doJuice:(id)sender {
	long juiceMS;
	NSSound *juiceSound;
	
	if ([sender respondsToSelector:@selector(juiceMS)]) {
		juiceMS = (long)[sender performSelector:@selector(juiceMS)];
	}
	else {
		juiceMS = [[task defaults] integerForKey:SRCRewardMSKey];
	}
	//NSLog(@"reward:%d", juiceMS);
	[[task dataController] digitalOutputBitsOff:kRewardBit];
	[scheduler schedule:@selector(doJuiceOff) toTarget:self withObject:nil delayMS:juiceMS];
	if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
		juiceSound = [NSSound soundNamed:@"Correct"];
		if ([juiceSound isPlaying]) {   // won't play again if it's still playing
			[juiceSound stop];
		}
		[juiceSound play];			// play juice sound
	}
}

- (void)doJuiceOff {
	[[task dataController] digitalOutputBitsOn:kRewardBit];
}

- (IBAction)doReset:(id)sender {
    requestReset();
}

- (IBAction)doRFMap:(id)sender {
	[host performSelector:@selector(switchToTaskWithName:) withObject:@"RFMap"];
}

- (IBAction)doRunStop:(id)sender {
	long newMode;
	
    switch ([taskStatus mode]) {
    case kTaskIdle:
		newMode = kTaskRunning;
        break;
    case kTaskRunning:
		newMode = kTaskStopping;
        break;
    case kTaskStopping:
    default:
		newMode = kTaskIdle;
        break;
    }
	[self setMode:newMode];
}

// After our -init is called, the host will provide essential pointers such as
// defaults, stimWindow, eyeCalibrator, etc.  Only aMSer those are initialized, the
// following method will be called.  We therefore defer most of our initialization here

- (void)initializationDidFinish {
	long index;
	NSString *userDefaultsValuesPath;
    NSDictionary *userDefaultsValuesDict;
	NSBundle *ourBundle;
	
	task = self;
	
	// Register our default settings. This should be done first thing, before the
	// nib is loaded, because items in the nib are linked to defaults
	ourBundle = [NSBundle bundleForClass:[self class]];
	userDefaultsValuesPath = [[NSBundle bundleForClass:[self class]] 
						pathForResource:@"UserDefaults" ofType:@"plist"];
	userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
	[[task defaults] registerDefaults:userDefaultsValuesDict];
	[NSValueTransformer 
			setValueTransformer:[[[LLFactorToOctaveStepTransformer alloc] init] autorelease]
			forName:@"FactorToOctaveStepTransformer"];

	// Set up to respond to changes to the values
	for (index = 0; keyPaths[index] != nil; index++) {
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:keyPaths[index]
				options:NSKeyValueObservingOptionNew context:nil];
	}
		
	// Set up the task mode object.  We need to do this before loading the nib,
	// because some items in the nib are bound to the task mode. We also need
	// to set the mode, because the value in defaults will be the last entry made
	// which is typically kTaskEnding.
	taskStatus = [[LLTaskStatus alloc] init];
	stimuli = [[SRCStimuli alloc] init];
	digitalOut = [[SRCDigitalOut alloc] init];

	// Load the items in the nib
    [[NSBundle bundleForClass:[self class]] loadNibNamed:@"SRContrast" owner:self topLevelObjects:&topLevelObjects];
    [topLevelObjects retain];
	
	// Initialize other task objects
	scheduler = [[LLScheduleController alloc] init];
	stateSystem = [[SRCStateSystem alloc] init];

	// Set up control panel and observer for control panel
	controlPanel = [[LLControlPanel alloc] init];
	[controlPanel setWindowFrameAutosaveName:@"SRCControlPanel"];
	[[controlPanel window] setFrameUsingName:@"SRCControlPanel"];
	[[controlPanel window] setTitle:@"SRContrast"];
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(doControls:) name:nil object:controlPanel];
}

- (long)mode {
	return [taskStatus mode];
}

- (NSString *)name {
	return @"SRContrast";
}

// The release notes for 10.3 say that the options for addObserver are ignore
// (http://developer.apple.com/releasenotes/Cocoa/AppKit.html).   This means that the change dictionary
// will not contain the new values of the change.  For now it must be read directly from the model

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	static BOOL tested = NO;
	NSString *key;
	id newValue;
	long longValue;
    bool boolValue;

	if (!tested) {
		newValue = [change objectForKey:NSKeyValueChangeNewKey];
		if (![[newValue className] isEqualTo:@"NSNull"]) {
			NSLog(@"NSKeyValueChangeNewKey is not NSNull, JHRM needs to change how values are accessed");
		}
		tested = YES;
	}
	key = [keyPath pathExtension];
	if ([key isEqualTo:SRCTriesKey]) {
		longValue = [defaults integerForKey:SRCTriesKey];
		[dataDoc putEvent:@"tries" withData:&longValue];
	}
	else if ([key isEqualTo:SRCRespTimeMSKey]) {
		longValue = [defaults integerForKey:SRCRespTimeMSKey];
		[dataDoc putEvent:@"responseTimeMS" withData:&longValue];
	}
	else if ([key isEqualTo:SRCStimDurationMSKey]) {
		longValue = [defaults integerForKey:SRCStimDurationMSKey];
		[dataDoc putEvent:@"stimDurationMS" withData:&longValue];
		requestReset();
	}
	else if ([key isEqualTo:SRCInterstimMSKey]) {
		longValue = [defaults integerForKey:SRCInterstimMSKey];
		[dataDoc putEvent:@"interstimMS" withData:&longValue];
		requestReset();
	}
	else if ([key isEqualTo:SRCContrastsKey] || [key isEqualTo:SRCContrastFactorKey] || [key isEqualTo:SRCMaxContrastKey]) {
		[[task dataDoc] putEvent:@"contrastParams" withData:(Ptr)getContrastParams()];
		requestReset();
	}
	else if ([key isEqualTo:SRCTemporalFreqsKey] || [key isEqualTo:SRCTemporalFreqFactorKey] || [key isEqualTo:SRCMaxTemporalFreqHzKey]) {
		[[task dataDoc] putEvent:@"temporalFreqParams" withData:(Ptr)getTemporalFreqParams()];
		requestReset();
	}
	else if ([key isEqualTo:SRCStimRepsPerBlockKey]) {
		longValue = [defaults integerForKey:SRCStimRepsPerBlockKey];
		[dataDoc putEvent:@"stimRepsPerBlock" withData:&longValue];
	}
	else if ([key isEqualTo:SRCPreferredLocKey]){
		longValue = [defaults integerForKey:SRCPreferredLocKey];
		[dataDoc putEvent:@"preferredLoc" withData:&longValue];
		requestReset();
	}
    else if ([key isEqualTo:SRCCoupleTemporalFreqsKey]){
        boolValue = [defaults boolForKey:SRCCoupleTemporalFreqsKey];
        if (boolValue) {
            [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:SRCTemporalFreqsKey];
        }
    }
    else if ([key isEqualTo:SRCUseFeatureAttentionKey]){
        boolValue = [defaults integerForKey:SRCUseFeatureAttentionKey];
//        [dataDoc putEvent:@"useFeatureAttentionFlag" withData:&longValue];
        requestReset();
    }
    else if ([key isEqualTo:SRCUseSingleStimulusPerTrialKey]){
        boolValue = [defaults integerForKey:SRCUseSingleStimulusPerTrialKey];
        requestReset();
    }
}

- (DisplayModeParam)requestedDisplayMode {
	displayMode.widthPix = 1280;
	displayMode.heightPix = 720;
	displayMode.pixelBits = 32;
	displayMode.frameRateHz = 100;
	return displayMode;
}

- (void)setMode:(long)newMode {
	[taskStatus setMode:newMode];
	[defaults setInteger:[taskStatus status] forKey:SRCTaskStatusKey];
	[controlPanel setTaskMode:[taskStatus mode]];
	[dataDoc putEvent:@"taskMode" withData:&newMode];
	switch ([taskStatus mode]) {
	case kTaskRunning:
	case kTaskStopping:
		[runStopMenuItem setKeyEquivalent:@"."];
		break;
	case kTaskIdle:
		[runStopMenuItem setKeyEquivalent:@"r"];
		break;
	default:
		break;
	}
}

// Respond to changes in the stimulus settings
- (void)setWritingDataFile:(BOOL)state {
	if ([taskStatus dataFileOpen] != state) {
		[taskStatus setDataFileOpen:state];
		[defaults setInteger:[taskStatus status] forKey:SRCTaskStatusKey];
		if ([taskStatus dataFileOpen]) {
			announceEvents();
			[controlPanel displayFileName:[[[dataDoc filePath] lastPathComponent] 
												stringByDeletingPathExtension]];
			[controlPanel setResetButtonEnabled:NO];
		}
		else {
			[controlPanel displayFileName:@""];
			[controlPanel setResetButtonEnabled:YES];
		}
	}
}

- (SRCStimuli *)stimuli {
	return stimuli;
}
@end
