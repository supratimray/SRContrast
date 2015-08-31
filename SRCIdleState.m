//
//  SRCIdleState.m
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRCIdleState.h"

@implementation SRCIdleState

- (void)stateAction {

    [[task dataController] setDataEnabled:[NSNumber numberWithBool:NO]];
}

- (NSString *)name {

    return @"SRCIdle";
}

- (LLState *)nextState {

	if ([task mode] == kTaskEnding) {
		return [[task stateSystem] stateNamed:@"SRCStop"];
    }
	if (![task mode] == kTaskIdle) {
		return [[task stateSystem] stateNamed:@"SRCIntertrial"];
    }
	else {
        return nil;
    }
}

@end
