//
//  SRCIntertrialState.h
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCStateSystem.h"

@interface SRCIntertrialState : LLState {

	NSTimeInterval	expireTime;
}

- (BOOL)selectTrial;

@end
