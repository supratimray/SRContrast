//
//  SRCBehaviorController.h
//  SRContrast
//
//  Copyright (c) 2006. All rights reserved.
//

#include "SRC.h"

//#define kEOTs				(kEOTIgnored + 1)				// Plot EOT types up to ignored
#define kMaxRT				1000

@interface SRCBehaviorController : LLScrollZoomWindow {

	NSView			*documentView;
    LLHistView		*hist[kMaxContrasts];
    LLViewScale		*histScaling;
    NSColor 		*highlightColor;
    long			histHighlightIndex;
	long			plotHighlightIndex;
    NSMutableArray	*labelArray;
	NSMutableArray	*xAxisLabelArray;
	NSMutableArray	*xAxisLabelArrayTargetIndex;
	
	NSMutableArray	*juiceTimes;								// an array of LLNormDist
	LLPlotView		*meanJuiceWithTimePlot;
	
	NSMutableArray  *totalTrials;								// an array of points
	NSMutableArray  *totalCorrectTrials;						// an array of points
	LLPlotView		*totalTrialsPlot;
	
	NSMutableArray  *performanceWithTime[kEOTTotal];			// an array of LLBinomDist
	LLPlotView		*perfWithTimePlot;
	
    NSMutableArray	*performance[kEOTTotal][kMaxTemporalFreqs];				// an array of LLBinomDist
    LLPlotView		*perfPlot[kMaxTemporalFreqs];
	
	NSMutableArray	*reactTimes[kMaxTemporalFreqs];						// an array of LLNormDist
    LLPlotView		*reactPlot[kMaxTemporalFreqs];
   
    long			responseTimeMS;
    double			rtDist[kMaxContrasts][kMaxRT];
	
	StimParams		lastContrastParams;
	StimParams		contrastParams;
	StimParams		lastTemporalFreqParams;
	StimParams		temporalFreqParams;
	
	long			targetOnTimeMS;
	long			saccadeOnTimeMS;;
	TrialDesc		trial;
	
	long			juiceMS;
	long			rewardLimitMS;
	long			maxTargetIndex;
}

- (void)changeResponseTimeMS;
- (void)checkParams;
- (LLHistView *)initHist:(LLViewScale *)scale data:(double *)data;
- (void)makeLabels;
- (void)positionPlots;
- (void)reset:(NSData *)eventData eventTime:(NSNumber *)eventTime;

@end
