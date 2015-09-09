//
//  SRCDigitalOut.m
//
//  Created by Marlene Cohen on 12/6/07.
//  Modified by Supratim Ray on 9/10/08.
//  Copyright 2008. All rights reserved.

// We move away from the practice of putting in too many digital codes. The main reason is that unlike Blackrock, EEG data acquisition systems such as BrainProducts or EGI are not fast enough to catch digital words that change very quickly. So instead we put in only a few words, but also make sure that they are long enough. We also assume that a single Labjack/ITC18 is being used for data I/O.

#import "SRCDigitalOut.h" 

@implementation SRCDigitalOut

-(void)dealloc;
{
	[lock release];
	[super dealloc];
}

-(id) init;
{
	if ((self = [super init])) {
		digitalOutDevice = (LLITC18DataDevice *)[[task dataController] deviceWithName:@"ITC-18 1"];
		if (digitalOutDevice == nil) {
//			NSRunAlertPanel(@"SRCDigitalOut",  @"Can't find data device named \"%@\", trying ITC-18 instead.",
//						@"OK", nil, nil, @"ITC-18 1");
			digitalOutDevice = (LLITC18DataDevice *)[[task dataController] deviceWithName:@"ITC-18"];
			if (digitalOutDevice == nil) {
//				NSRunAlertPanel(@"SRCContrast",  @"Can't find data device named \"%@\" (Quitting)",
//							@"OK", nil, nil, @"ITC-18");
				exit(0);
			}
		}
		lock = [[NSLock alloc] init];
	}
	return self;
}

- (BOOL)outputEvent:(long)event sleepInMicrosec:(int)sleepTimeInMicrosec;
{
    if (digitalOutDevice == nil) {
        return NO;
    }
    [lock lock];
    [[task dataController] digitalOutputBits:((event | 0x8001))];
    if (sleepTimeInMicrosec>0)
        usleep(sleepTimeInMicrosec);
    [[task dataController] digitalOutputBits:(kDefaultStateDigitOutCode | 0x0001)];
    if (sleepTimeInMicrosec>0)
        usleep(sleepTimeInMicrosec);
    [lock unlock];
    return YES;
}

- (BOOL)outputEvent:(long)event withData:(long)data;
{
	if (digitalOutDevice == nil) {
		return NO;
	}
	[lock lock];
	[digitalOutDevice digitalOutputBits:(event | 0x8000)];
	[digitalOutDevice digitalOutputBits:(data & 0x7fff)];
	[lock unlock];
	return YES;
}

- (BOOL)outputEventName:(NSString *)eventName withData:(long)data;
{
	
	if (digitalOutDevice == nil) {
		return NO;
	}
	[lock lock];
	
	if ([eventName isEqualTo:@"attendLoc"] || [eventName isEqualTo:@"AL"] )
		[digitalOutDevice digitalOutputBits:(0x414C | 0x8000)];
	else if ([eventName isEqualTo:@"break"] || [eventName isEqualTo:@"BR"] )
		[digitalOutDevice digitalOutputBits:(0x4252 | 0x8000)];
	else if ([eventName isEqualTo:@"contrastIndex"] || [eventName isEqualTo:@"CO"] )
		[digitalOutDevice digitalOutputBits:(0x434F | 0x8000)];
	else if ([eventName isEqualTo:@"catchTrial"] || [eventName isEqualTo:@"CT"] )
		[digitalOutDevice digitalOutputBits:(0x4354 | 0x8000)];
	else if ([eventName isEqualTo:@"eccentricity"] || [eventName isEqualTo:@"EC"] )
		[digitalOutDevice digitalOutputBits:(0x4543 | 0x8000)];
	else if ([eventName isEqualTo:@"fixate"] || [eventName isEqualTo:@"FI"] )
		[digitalOutDevice digitalOutputBits:(0x4649 | 0x8000)];
	else if ([eventName isEqualTo:@"fixOn"] || [eventName isEqualTo:@"FO"] )
		[digitalOutDevice digitalOutputBits:(0x464F | 0x8000)];
	else if ([eventName isEqualTo:@"instructTrial"] || [eventName isEqualTo:@"IT"] )
		[digitalOutDevice digitalOutputBits:(0x4954 | 0x8000)];
	else if ([eventName isEqualTo:@"stimulusOn"] || [eventName isEqualTo:@"ON"] )
		[digitalOutDevice digitalOutputBits:(0x4F4E | 0x8000)];
	else if ([eventName isEqualTo:@"stimulusOff"] || [eventName isEqualTo:@"OF"] )
		[digitalOutDevice digitalOutputBits:(0x4F46 | 0x8000)];
	else if ([eventName isEqualTo:@"orientation"] || [eventName isEqualTo:@"OR"] )
		[digitalOutDevice digitalOutputBits:(0x4F52 | 0x8000)];
	else if ([eventName isEqualTo:@"polarAngle"] || [eventName isEqualTo:@"PA"] )
		[digitalOutDevice digitalOutputBits:(0x5041 | 0x8000)];
	else if ([eventName isEqualTo:@"radius"] || [eventName isEqualTo:@"RA"] )
		[digitalOutDevice digitalOutputBits:(0x5241 | 0x8000)];
	else if ([eventName isEqualTo:@"saccade"] || [eventName isEqualTo:@"SA"] )
		[digitalOutDevice digitalOutputBits:(0x5341 | 0x8000)];
	else if ([eventName isEqualTo:@"spatialFrequency"] || [eventName isEqualTo:@"SF"] )
		[digitalOutDevice digitalOutputBits:(0x5346 | 0x8000)];	
	else if ([eventName isEqualTo:@"sigma"] || [eventName isEqualTo:@"SI"] )
		[digitalOutDevice digitalOutputBits:(0x5349 | 0x8000)];
	else if ([eventName isEqualTo:@"trialCertify"] || [eventName isEqualTo:@"TC"] )
		[digitalOutDevice digitalOutputBits:(0x5443 | 0x8000)];
	else if ([eventName isEqualTo:@"trialEnd"] || [eventName isEqualTo:@"TE"] )
		[digitalOutDevice digitalOutputBits:(0x5445 | 0x8000)];
	else if ([eventName isEqualTo:@"temporalFrequencyIndex"] || [eventName isEqualTo:@"TF"] )
		[digitalOutDevice digitalOutputBits:(0x5446 | 0x8000)];
	else if ([eventName isEqualTo:@"trialStart"] || [eventName isEqualTo:@"TS"] )
		[digitalOutDevice digitalOutputBits:(0x5453 | 0x8000)];
	else if ([eventName isEqualTo:@"type0"] || [eventName isEqualTo:@"T0"] )
		[digitalOutDevice digitalOutputBits:(0x5430 | 0x8000)];
	else if ([eventName isEqualTo:@"type1"] || [eventName isEqualTo:@"T1"] )
		[digitalOutDevice digitalOutputBits:(0x5431 | 0x8000)]; 
	else
//		NSRunAlertPanel(@"SRCDigitalOut",  @"Can't find digital event named \"%@\".",
//						@"OK", nil, nil, eventName);
	
	
	[digitalOutDevice digitalOutputBits:(data & 0x7fff)];
	[lock unlock];
	return YES;
}

@end
