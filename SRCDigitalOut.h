//
//  SRCDigitalOut.h
//  SRCContrast
//
//  Created by Marlene Cohen on 12/6/07.
//  Modified by Supratim Ray on 9/10/08.
//  Copyright 2008 . All rights reserved.
//

#import "SRC.h"
#import "LablibITC18.h" 

@interface SRCDigitalOut : NSObject {

	LLITC18DataDevice		*digitalOutDevice;
	NSLock					*lock;

}

- (BOOL)outputEvent:(long)event sleepInMicrosec:(int)sleepTimeInMicrosec;
- (BOOL)outputEvent:(long)event withData:(long)data;
- (BOOL)outputEventName:(NSString *)eventName withData:(long)data;
@end
