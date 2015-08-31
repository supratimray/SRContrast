//
//  SRCSpikeController.h
//  SRContrast
//
//  Copyright (c) 2006. All rights reserved.
//

#include "SRC.h"

#define kEOTs				(kEOTIgnored + 1)				// Plot EOT types up to ignored
#define kMaxSpikeMS				10000

@interface SRCSpikeController : LLScrollZoomWindow {

    NSMutableArray	*rates[kLocations];						// arrays of LLNormDist for plotting
	NSView			*documentView;
    LLViewScale		*histScaling;
    NSMutableArray	*histViews;
    NSMutableArray	*attRates;								// an array of LLNormDist
    long			interstimDurMS;
    NSMutableArray	*labelArray;
	StimParams		lastStimParams;
    LLPlotView		*ratePlot;
    double			spikeHists[kLocations][kMaxContrasts][kMaxSpikeMS];
    long			stimDurMS;
	long			spikeHistsN[kLocations][kMaxContrasts];
	NSMutableArray	*stimList;
	NSMutableArray	*stimTimes;
	StimParams		stimParams;
	TrialDesc		trial;
	long			trialStartTime;
	NSMutableData	*trialSpikes;
    NSMutableArray	*xAxisLabelArray;
	//long			experimentType;
}

- (void)changeHistTimeMS;
- (void)checkParams;
- (LLHistView *)initHist:(LLViewScale *)scale data0:(double *)data0 data1:(double *)data1;
- (void)makeLabels;
- (void)positionPlots;
- (void)reset:(NSData *)eventData eventTime:(NSNumber *)eventTime;

@end

