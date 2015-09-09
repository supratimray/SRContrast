//
//  SRCEndtrialState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCEndtrialState.h"
#import "UtilityFunctions.h"
#import "SRCDigitalOut.h"

#define kMinRewardMS	10
#define kMinTrials		4

@implementation SRCEndtrialState

- (long)juiceMS {
	
	long juiceMS, rewardLimitMS, meanJuice, stimulusMS, interstimMS, trialDuration;
	double rewardMinMS, rewardMaxMS, tempVar, minT, maxT, tau, meanRateHz;
	BOOL varScheduleOn;

	varScheduleOn = [[task defaults] boolForKey:SRCVarRewardOnKey];
		
	rewardMinMS = [[task defaults] floatForKey:SRCVarRewardMinMSKey];
	rewardMaxMS = [[task defaults] floatForKey:SRCVarRewardMaxMSKey];
	tau = [[task defaults] floatForKey:SRCVarRewardTCKey];
	minT = [[task defaults] floatForKey:SRCStimLeadMSKey];
	maxT = [[task defaults] floatForKey:SRCMaxTargetMSKey];
	stimulusMS = [[task defaults] integerForKey:SRCStimDurationMSKey]; 
	interstimMS = [[task defaults] integerForKey:SRCInterstimMSKey];
	meanRateHz = 1000.0 / (stimulusMS + interstimMS);

	trialDuration = trial.targetIndex*1000.0/meanRateHz;


	if (varScheduleOn){
		tempVar = rewardMinMS - ((rewardMinMS - rewardMaxMS)/(exp(minT/tau) - exp(maxT/tau)))*exp(minT/tau);
		juiceMS = (long)(((rewardMinMS - rewardMaxMS)/(exp(minT/tau) - exp(maxT/tau)))*exp(trialDuration/tau)+tempVar);
		meanJuice = (long)((rewardMaxMS - rewardMinMS)*tau/(maxT - minT) + tempVar);
		if (minT >= maxT){
			juiceMS = [[task defaults] integerForKey:SRCRewardMSKey];
			meanJuice = [[task defaults] integerForKey:SRCRewardMSKey];
		}
		[[task defaults] setInteger:meanJuice forKey:SRCVarRewardMeanKey];
		if (juiceMS < rewardMinMS) juiceMS = rewardMinMS;
		if (juiceMS > rewardMaxMS) juiceMS = rewardMaxMS;
		
		rewardLimitMS = rewardMaxMS;
	}	
	else {
		juiceMS = [[task defaults] integerForKey:SRCRewardMSKey];
		rewardLimitMS = juiceMS;
	}
	
	// Put reward related event in dataDoc 
	[[task dataDoc] putEvent:@"juiceMS" withData:(void *)&juiceMS];
	[[task dataDoc] putEvent:@"rewardLimitMS" withData:(void *)&rewardLimitMS];
	
	return juiceMS;
}

- (void)stateAction {

	long trialCertify;
	long stimAdded;			// Number of stim added if correct	
	long breakPunishMS;
	
	[stimuli stopAllStimuli];
	[[task dataDoc] putEvent:@"fixOff"];
	//[digitalOut outputEventName:@"fixOff" withData:0x0000];
	
	// The computer may have failed to create the display correctly.  We check that now
	// If the computer failed, the monkey will still get rewarded for correct trial,
	// but the trial will be done over.  Other computer checks can be added here.

	trialCertify = 0;
	if (![[stimuli monitor] success]) {
		trialCertify |= (0x1 << kCertifyVideoBit);
	}
    
    [[task dataDoc] putEvent:@"trialCertify" withData:(void *)&trialCertify];
    //[digitalOut outputEventName:@"trialCertify" withData:(long)(trialCertify)];
    
    [[task dataDoc] putEvent:@"trialEnd" withData:(void *)&eotCode];
    //[digitalOut outputEventName:@"trialEnd" withData:(long)(eotCode)];
    [digitalOut outputEvent:kTrialEndDigitOutCode sleepInMicrosec:kSleepInMicrosec];
    
	expireTime = [LLSystemUtil timeFromNow:0];					// no delay, except for breaks (below)
	
	switch (eotCode) {
		case kEOTCorrect:
			[task performSelector:@selector(doJuice:) withObject:self];
			if (trial.instructTrial) {
				blockStatus.instructsDone++;
			}
			//NSLog(@"correct certify: %d", trialCertify);
		
			// Don't add to stim list if this is a catch trial
			if (trial.catchTrial) {
				stimAdded = 0;
			}
			else {
				[stimuli tallyStimuli];
				stimAdded = [stimuli stimuliAddedThisTrial];
			}
			
			[[task dataDoc] putEvent:@"stimAdded" withData:(void *)&stimAdded];
			break;
			
		case kEOTWrong:
			if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
				[[NSSound soundNamed:kNotCorrectSound] play];
			}
			break;
		case kEOTFAlarm:
			breakPunishMS = [[task defaults] integerForKey:SRCBreakPunishMSKey];
			
			if (breakPunishMS > 0) {
				
				if (brokeDuringStim) {
					expireTime = [LLSystemUtil timeFromNow:breakPunishMS]; // Punishing not for breaks but for false alarms
				}
				if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
					[[NSSound soundNamed:kFalseAlarmSound] play];
				}
			}
			else {
				if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
					[[NSSound soundNamed:kNotCorrectSound] play];
				}
			}
			break;
		case kEOTFailed:
		case kEOTBroke:
		case kEOTDistracted:
		default:
			if ([[task defaults] boolForKey:SRCDoSoundsKey]) {
				[[NSSound soundNamed:kNotCorrectSound] play];
			}
		break;
	}
	
	[[task synthDataDevice] setSpikeRateHz:spikeRateFromStimValue(0.0) atTime:[LLSystemUtil getTimeS]];
    [[task synthDataDevice] setEyeTargetOff];
//    [[task synthDataDevice] doLeverUp];
	if (resetFlag) {
		reset();
        resetFlag = NO;
	}
    if ([task mode] == kTaskStopping) {						// Requested to stop
        [task setMode:kTaskIdle];
	}
}

- (NSString *)name {
    return @"Endtrial";
}

- (LLState *)nextState {

	if ([task mode] == kTaskIdle) {
		return [[task stateSystem] stateNamed:@"SRCIdle"];
    }
	else if ([LLSystemUtil timeIsPast:expireTime]) {
		return [[task stateSystem] stateNamed:@"SRCIntertrial"];
	}
	else {
		return nil;
	}
}

@end
