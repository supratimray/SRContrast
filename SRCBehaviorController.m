//
//  SRCBehaviorController.m
//  SRContrast
//
//  Window with summary information about behavioral performance.
//
//  Copyright (c) 2006. All rights reserved.
//

#define NoGlobals

#import "SRC.h"
#import "UtilityFunctions.h"
#import "SRCBehaviorController.h"

#define kMarginPix				10
#define kPlotBinsDefault		10
#define	kXTickSpacing			100
#define kMaxTargetPosition		50
#define kMaxRewardLimitMS		500


#define kViewWidthPix			800
		
#define kPlotsPerRow			4
#define kPlotHeightPix			125
#define kPlotWidthPix			((kViewWidthPix - (kPlotsPerRow + 1) * kMarginPix) / kPlotsPerRow)
#define	displayedPlots			(MIN(temporalFreqParams.levels, kMaxTemporalFreqs))
#define plotRows				(ceil(displayedPlots / (double)kPlotsPerRow))

#define kHistsPerRow			4
#define kHistHeightPix			125
#define kHistWidthPix			((kViewWidthPix - (kHistsPerRow + 1) * kMarginPix) / kHistsPerRow)
#define	displayedHists			(MIN(contrastParams.levels, kMaxContrasts))
#define histRows				(ceil(displayedHists / (double)kHistsPerRow))

#define kJuicePlotWidthPix		(kViewWidthPix- 4*kMarginPix) / 3
#define kJuicePlotHeightPix		125
#define kTimePlotWidthPix		kJuicePlotWidthPix
#define kTimePlotHeightPix		kJuicePlotHeightPix
#define kTotalTrialsWidthPix	kJuicePlotWidthPix
#define kTotalTrialsHeightPix	kJuicePlotHeightPix
#define kTemporalFreqWidthPix	kJuicePlotWidthPix
#define kTemporalFreqHeightPix	kJuicePlotHeightPix

#define kJuicePlotEndHeight		kJuicePlotHeightPix + kMarginPix
#define kHistPlotEndHeight		kJuicePlotEndHeight + kMarginPix + (kHistHeightPix*histRows) + kMarginPix*(histRows-1)
#define kPerfPlotEndHeight      kHistPlotEndHeight + kMarginPix + (kPlotHeightPix*plotRows) + kMarginPix*(plotRows-1)
#define kReactPlotEndHeight     kPerfPlotEndHeight + kMarginPix + (kPlotHeightPix*plotRows) + kMarginPix*(plotRows-1)

#define contentWidthPix			kViewWidthPix
#define contentHeightPix		kReactPlotEndHeight + kMarginPix



@implementation SRCBehaviorController

- (void)changeResponseTimeMS {
    long h, index, base, labelSpacing;
    long factors[] = {1, 2, 5};
 
	// Find the appropriate spacing for x axis labels

	index = 0;
	base = 1;
    while ((responseTimeMS / kXTickSpacing) / (base * factors[index]) > 2) {
        index = (index + 1) % (sizeof(factors) / sizeof(long));
        if (index == 0) {
            base *= 10;
        }
    }
    labelSpacing = base * factors[index];

	// Change the ticks and tick label spacing for each histogram

	for (h = 0; h < kMaxContrasts; h++) {
		[hist[h] setDataLength:MIN(responseTimeMS, kMaxRT)];
		[hist[h] setDisplayXMin:0 xMax:MIN(responseTimeMS, kMaxRT)];
		[hist[h] setXAxisTickSpacing:kXTickSpacing];
		[hist[h] setXAxisTickLabelSpacing:labelSpacing];
		[hist[h] setNeedsDisplay:YES];
    }
}


- (void)checkParams {
	long t;
	StimParams *pCurrentContrast, *pLastContrast, *pCurrentTemporalFreq, *pLastTemporalFreq;
	
	pCurrentContrast = &contrastParams;
	pLastContrast = &lastContrastParams;
	pCurrentTemporalFreq = &temporalFreqParams;
	pLastTemporalFreq = &lastTemporalFreqParams;
	
	if (pCurrentContrast->levels == 0 || pCurrentTemporalFreq->levels == 0) {	// either contrast or temporal frequency not initialized yet
		return;
	}
	if (pCurrentContrast->levels != pLastContrast->levels || pCurrentContrast->maxValue != pLastContrast->maxValue || 
		pCurrentContrast->factor != pLastContrast->factor || pCurrentTemporalFreq->levels != pLastTemporalFreq->levels || 
		pCurrentTemporalFreq->maxValue != pLastTemporalFreq->maxValue || pCurrentTemporalFreq->factor != pLastTemporalFreq->factor) {
		
		[self makeLabels];
		
		for (t = 0; t < kMaxTemporalFreqs; t++) {
			[reactPlot[t] setPoints:pCurrentContrast->levels];
			[reactPlot[t] setXAxisLabel:@"Contrasts"];
			
			[perfPlot[t] setPoints:pCurrentContrast->levels];
			[perfPlot[t] setXAxisLabel:@"Contrasts"];
		}
		
		[totalTrialsPlot setPoints:MAX(1, MIN(maxTargetIndex+1,kMaxTargetPosition))];
		[totalTrialsPlot setXAxisLabel:@"Target Position"];
		
		[meanJuiceWithTimePlot setPoints:MAX(1, MIN(maxTargetIndex+1,kMaxTargetPosition))];
		[meanJuiceWithTimePlot setXAxisLabel:@"Target Position"];
		
		[perfWithTimePlot setPoints:MAX(1, MIN(maxTargetIndex+1,kMaxTargetPosition))];
		[perfWithTimePlot setXAxisLabel:@"Target Position"];
		
		[self positionPlots];
		
		pLastContrast->levels = pCurrentContrast->levels;
		pLastContrast->maxValue = pCurrentContrast->maxValue;
		pLastContrast->factor = pCurrentContrast->factor;
		
		pLastTemporalFreq->levels = pCurrentTemporalFreq->levels;
		pLastTemporalFreq->maxValue = pCurrentTemporalFreq->maxValue;
		pLastTemporalFreq->factor = pCurrentTemporalFreq->factor;
		
		// If settings have changed (number of stimulus levels, type of stim, etc.  we reset and redraw
		[self reset:[NSData data] eventTime:[NSNumber numberWithLong:0]]; 
	}
}


- (void)dealloc {

    [labelArray release];
	[xAxisLabelArray release];
	[xAxisLabelArrayTargetIndex release];
	[super dealloc];
}

- (id) init {

    if ((self = [super initWithWindowNibName:@"SRCBehaviorController" defaults:[task defaults]]) != nil) {
    }
    return self;
}

- (LLHistView *)initHist:(LLViewScale *)scale data:(double *)data {

	LLHistView *h;
    
	h = [[[LLHistView alloc] initWithFrame:NSMakeRect(0, 0, kHistWidthPix, kHistHeightPix) scaling:scale] autorelease];
	[h setScale:scale];
	[h setData:data length:kMaxRT color:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.6]];
	[h setPlotBins:kPlotBinsDefault];
	[h setAutoBinWidth:YES];
	[h setSumWhenBinning:YES];
	[h hide:YES];
	[documentView addSubview:h];
	return h;
}

- (void) makeLabels {
	int index;
    long contrastLevels;
	double contrastValue;
	NSString *string;
    
	contrastLevels = contrastParams.levels;
	
    [labelArray removeAllObjects];
    [xAxisLabelArray removeAllObjects];
	[xAxisLabelArrayTargetIndex removeAllObjects];

	for (index = 0; index < contrastLevels; index++) {
		contrastValue = valueFromIndex(index, &contrastParams);
		string = [NSString stringWithFormat:@"%.*f", [LLTextUtil precisionForValue:contrastValue significantDigits:2], contrastValue];

		[labelArray addObject:string];
		if ((contrastLevels >= 6) && ((index % 2) == (contrastLevels % 2))) {
			[xAxisLabelArray addObject:@""];
		}
		else {
			[xAxisLabelArray addObject:string];
		}
	}
	
	for (index = 0; index <= maxTargetIndex; index++) {
		string = [NSString stringWithFormat:@"%d", index];
		
		if ((maxTargetIndex > 10) && ((index % 2) == (maxTargetIndex % 2))) {
			[xAxisLabelArrayTargetIndex addObject:@""];
		}
		else {
			[xAxisLabelArrayTargetIndex addObject:string];
		}
	} 
}

- (void)positionPlots {
	long tindex, cindex, row, column;

	// We start from the bottom
	
	// Total Trials plot
	[totalTrialsPlot setFrameOrigin:NSMakePoint(kMarginPix, kMarginPix)];
	[totalTrialsPlot setHidden:NO];
	[totalTrialsPlot setNeedsDisplay:YES];
	
	// Juice plot
	[meanJuiceWithTimePlot setFrameOrigin:NSMakePoint(kMarginPix + (kJuicePlotWidthPix + kMarginPix), kMarginPix)];
	[meanJuiceWithTimePlot setHidden:NO];
	[meanJuiceWithTimePlot setNeedsDisplay:YES];
	
	// PerfWithTime plots
	[perfWithTimePlot setFrameOrigin:NSMakePoint(kMarginPix + 2*(kJuicePlotWidthPix + kMarginPix), kMarginPix)];
	[perfWithTimePlot setHidden:NO];
	[perfWithTimePlot setNeedsDisplay:YES];
	
	// Reaction time histograms
	for (cindex = 0; cindex < kMaxContrasts; cindex++) {
		if (cindex < displayedHists) { 
			row = cindex / kHistsPerRow;
			column = (cindex % kHistsPerRow);
			[hist[cindex] setFrameOrigin:NSMakePoint(kMarginPix + column * (kHistWidthPix + kMarginPix), 
													 kJuicePlotEndHeight + kMarginPix + (histRows - row - 1) * (kHistHeightPix + kMarginPix))];
			[hist[cindex] setTitle:[NSString stringWithFormat: @"%@ %@", 
									@"Contrast", [labelArray objectAtIndex:cindex]]];
			if (row == histRows - 1) {
				[hist[cindex] setXAxisLabel:@"time (ms)"];
			}
			[hist[cindex] hide:NO];
			[hist[cindex] setNeedsDisplay:YES];
		}
		else {
			[hist[cindex] hide:YES];
		}
	}
	
	// Reaction and Performance plots
	for (tindex=0; tindex < kMaxTemporalFreqs; tindex++) {
		if (tindex < displayedPlots) {
			row = tindex / kPlotsPerRow;
			column = (tindex % kPlotsPerRow);
			
			
			[perfPlot[tindex] setFrameOrigin:NSMakePoint(kMarginPix + column*(kPlotWidthPix+kMarginPix), 
														  kHistPlotEndHeight + kMarginPix + (plotRows - row - 1) * (kPlotHeightPix + kMarginPix))];
			
			[reactPlot[tindex] setFrameOrigin:NSMakePoint(kMarginPix + column*(kPlotWidthPix+kMarginPix),
														  kPerfPlotEndHeight + kMarginPix + (plotRows - row - 1) * (kPlotHeightPix + kMarginPix))];
			
			[perfPlot[tindex] setHidden:NO];
			[perfPlot[tindex] setNeedsDisplay:YES];
			[reactPlot[tindex] setHidden:NO];
			[reactPlot[tindex] setNeedsDisplay:YES];
		}
		else {
			[perfPlot[tindex] setHidden:YES];
			[reactPlot[tindex] setHidden:YES];
		}
	}

	// Set the window to the correct size for the new number of rows and columns, forcing a 
	// re-draw of all the exposed histograms.

	[documentView setFrame:NSMakeRect(0, 0, contentWidthPix, contentHeightPix)];
	[super setBaseMaxContentSize:NSMakeSize(contentWidthPix, contentHeightPix)];
}

- (void) windowDidLoad {

    long tindex, cindex, tpindex, p, h;
    NSColor *plotColor;
    NSRect maxScrollRect;
    
    [super windowDidLoad];
	documentView = [scrollView documentView];
    labelArray = [[NSMutableArray alloc] init];
    xAxisLabelArray = [[NSMutableArray alloc] init];
	xAxisLabelArrayTargetIndex = [[NSMutableArray alloc] init];
	
    [self makeLabels];
    highlightColor = [NSColor colorWithDeviceRed:0.85 green:0.85 blue:0.85 alpha:1.0];

	// Total Trials View
	totalTrialsPlot = [[[LLPlotView alloc] initWithFrame:NSMakeRect(0, 0, kTotalTrialsWidthPix, kTotalTrialsHeightPix)] autorelease];
	totalTrials = [[[NSMutableArray alloc] init] autorelease];
	totalCorrectTrials = [[[NSMutableArray alloc] init] autorelease];
	
	for (tpindex = 0; tpindex < kMaxTargetPosition; tpindex++) {
		[totalTrials addObject:[[[LLPointDist alloc] init] autorelease]];
		[totalCorrectTrials addObject:[[[LLPointDist alloc] init] autorelease]];
	}
	
	[totalTrialsPlot  addPlot:totalTrials plotColor:[LLStandardDataEvents eotColor:kEOTForceQuit]];
	[totalTrialsPlot  addPlot:totalCorrectTrials plotColor:[LLStandardDataEvents eotColor:kEOTCorrect]];
	[totalTrialsPlot setXAxisLabel:@"Target Position"];
	[totalTrialsPlot setXAxisTickLabels:xAxisLabelArrayTargetIndex];
	[[totalTrialsPlot scale] setHeight:1];
	[documentView addSubview:totalTrialsPlot];
	
	// Juice plot View
	meanJuiceWithTimePlot = [[[LLPlotView alloc] initWithFrame:NSMakeRect(0, 0, kJuicePlotWidthPix, kJuicePlotHeightPix)] autorelease];
	juiceTimes = [[[NSMutableArray alloc] init] autorelease];
	
	for (tpindex = 0; tpindex < kMaxTargetPosition; tpindex++) {
		[juiceTimes addObject:[[[LLNormDist alloc] init] autorelease]];
	}
	
	[meanJuiceWithTimePlot  addPlot:juiceTimes plotColor:nil];
	[meanJuiceWithTimePlot setXAxisLabel:@"Target Position"];
	[meanJuiceWithTimePlot setXAxisTickLabels:xAxisLabelArrayTargetIndex];
	[[meanJuiceWithTimePlot scale] setHeight:MAX(1,MIN(rewardLimitMS,kMaxRewardLimitMS))];
	[documentView addSubview:meanJuiceWithTimePlot];
	
	// Performance with Time Plots
	// Initialize the performance with time plot.  We set the color for kEOTWrong to clear, because we don't 
	// want to see those values.  They are mirror image to the correct data
	perfWithTimePlot = [[[LLPlotView alloc] initWithFrame:NSMakeRect(0, 0, kTimePlotWidthPix, kTimePlotHeightPix)] autorelease];
	
	for (p = 0; p < kEOTTotal; p++) {
		performanceWithTime[p] = [[[NSMutableArray alloc] init] autorelease];
		
		for (tpindex = 0; tpindex < kMaxTargetPosition; tpindex++) {
			[performanceWithTime[p] addObject:[[[LLBinomDist alloc] init] autorelease]];
		}
		if (p != kEOTWrong) {
			[perfWithTimePlot  addPlot:performanceWithTime[p] plotColor:[LLStandardDataEvents eotColor:p]];
		}
		else {
			[perfWithTimePlot  addPlot:performanceWithTime[p] plotColor:[NSColor clearColor]];
		}
	}
	
	[perfWithTimePlot setXAxisLabel:@"Target Position"];
	[perfWithTimePlot setXAxisTickLabels:xAxisLabelArrayTargetIndex];
	[[perfWithTimePlot scale] setHeight:1];	 
	[perfWithTimePlot  setHighlightXRangeColor:highlightColor];
	[perfWithTimePlot  setHighlightYRangeFrom:0.49 to:0.51];
	[perfWithTimePlot  setHighlightYRangeColor:highlightColor];
	[documentView addSubview:perfWithTimePlot];
	
	
	// Reaction time and Performance plots
	
	for (tindex=0; tindex < kMaxTemporalFreqs; tindex++) {
		reactTimes[tindex] = [[[NSMutableArray alloc] init] autorelease];
    
		for (cindex = 0; cindex < kMaxContrasts; cindex++) {
			[reactTimes[tindex] addObject:[[[LLNormDist alloc] init] autorelease]];
		}
		
		// Initialize the reaction time plot
		reactPlot[tindex] = [[[LLPlotView alloc] initWithFrame:NSMakeRect(0, 0, kPlotWidthPix, kPlotHeightPix)] autorelease];
		[reactPlot[tindex] addPlot:reactTimes[tindex] plotColor:nil];
		[reactPlot[tindex] setXAxisLabel:@"Contrast"];
		[reactPlot[tindex] setXAxisTickLabels:xAxisLabelArray];
		[reactPlot[tindex] setHighlightXRangeColor:highlightColor];
		[documentView addSubview:reactPlot[tindex]];
	
		// Initialize the performance plot.  We set the color for kEOTWrong to clear, because we don't 
		// want to see those values.  They are mirror image to the correct data
		perfPlot[tindex] = [[[LLPlotView alloc] initWithFrame:NSMakeRect(0, 0, kPlotWidthPix, kPlotHeightPix)] autorelease];
		
		for (p = 0; p < kEOTTotal; p++) {
			performance[p][tindex] = [[[NSMutableArray alloc] init] autorelease];
			
			for (cindex = 0; cindex < kMaxContrasts; cindex++) {
				[performance[p][tindex]  addObject:[[[LLBinomDist alloc] init] autorelease]];
			}
			
			if (p != kEOTWrong) {
				[perfPlot[tindex]  addPlot:performance[p][tindex] plotColor:[LLStandardDataEvents eotColor:p]];
			}
			else {
				[perfPlot[tindex]  addPlot:performance[p][tindex]  plotColor:[NSColor clearColor]];
			}
		}
		
		[perfPlot[tindex]  setXAxisLabel:@"Contrast"];
		[perfPlot[tindex]  setXAxisTickLabels:xAxisLabelArray];
		[[perfPlot[tindex]  scale] setAutoAdjustYMax:NO];
		[[perfPlot[tindex]  scale] setHeight:1];
		[perfPlot[tindex]  setHighlightXRangeColor:highlightColor];
		[perfPlot[tindex]  setHighlightYRangeFrom:0.49 to:0.51];
		[perfPlot[tindex]  setHighlightYRangeColor:highlightColor];
		[documentView addSubview:perfPlot[tindex]];
	}
	
	
	plotHighlightIndex = -1;
	
	// Initialize the histogram views
    plotColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.6];
    histScaling = [[[LLViewScale alloc] init] autorelease];
    for (h = 0; h < kMaxContrasts; h++) {
		hist[h] = [self initHist:histScaling data:rtDist[h]];
    }
    histHighlightIndex = -1;

    [[zoomButton cell] setBordered:NO];
    [[zoomButton cell] setBezeled:YES];
    [[zoomButton cell] setFont:[NSFont labelFontOfSize:10.0]];

	// Work down from the default window max size to a default content max size, which 
	// we will use as a reference for setting window max size when the view scaling is changed.

    maxScrollRect = [NSWindow contentRectForFrameRect:
        NSMakeRect(0, 0, [[self window] maxSize].width, [[self window] maxSize].height)
        styleMask:[[self window] styleMask]];

    [self checkParams];
	[self changeResponseTimeMS];
}


- (void)contrastParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	[eventData getBytes:&contrastParams length:sizeof(StimParams)];
	[self checkParams];
}

- (void)juiceMS:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
	[eventData getBytes:&juiceMS length:sizeof(long)];
}

- (void)maxTargetIndex:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	long newMaxTargetIndex;
	
	[eventData getBytes:&newMaxTargetIndex length:sizeof(long)];
	
	
	if (newMaxTargetIndex != maxTargetIndex) { 
		maxTargetIndex = newMaxTargetIndex;
		[self makeLabels];
		[totalTrialsPlot setPoints:MIN(maxTargetIndex,kMaxTargetPosition)];
		[perfWithTimePlot setPoints:MIN(maxTargetIndex,kMaxTargetPosition)];
		[meanJuiceWithTimePlot setPoints:MIN(maxTargetIndex,kMaxTargetPosition)];
	}
}

- (void)rewardLimitMS:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	long newRewardLimitMS;
	
	[eventData getBytes:&newRewardLimitMS length:sizeof(long)];
	
	if (rewardLimitMS != newRewardLimitMS) {
		rewardLimitMS = newRewardLimitMS;
		[[meanJuiceWithTimePlot scale] setHeight:MAX(1,MIN(rewardLimitMS,kMaxRewardLimitMS))];
	}
}


- (void)reset:(NSData *)eventData eventTime:(NSNumber *)eventTime {

    long tindex, cindex, p, bin;
    
	for (tindex=0; tindex < kMaxTemporalFreqs; tindex++) {
		[reactTimes[tindex] makeObjectsPerformSelector:@selector(clear)];
		for (p = 0; p < kEOTTotal; p++) {
			[performance[p][tindex] makeObjectsPerformSelector:@selector(clear)];
		}
		[[reactPlot[tindex] scale] setHeight:100];					// Reset scaling as well
	}

    for (cindex = 0; cindex < kMaxContrasts; cindex++) {
		for (bin = 0; bin < kMaxRT; bin++) {
            rtDist[cindex][bin] = 0;
        }
	}
	
	for (p = 0; p < kEOTTotal; p++) {
		[performanceWithTime[p] makeObjectsPerformSelector:@selector(clear)];
	}
	[juiceTimes makeObjectsPerformSelector:@selector(clear)];
	[totalTrials makeObjectsPerformSelector:@selector(clear)];
	[totalCorrectTrials makeObjectsPerformSelector:@selector(clear)];
	
    [[[self window] contentView] setNeedsDisplay:YES];
}

	
- (void)responseTimeMS:(NSData *)eventData eventTime:(NSNumber *)eventTime {

    long newResponseTimeMS;
    
    [eventData getBytes:&newResponseTimeMS length:sizeof(long)];
    if (responseTimeMS != newResponseTimeMS) {
        responseTimeMS = newResponseTimeMS;
        [self changeResponseTimeMS];
    }
}

- (void)saccade:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
	saccadeOnTimeMS = [eventTime unsignedLongValue];
}

- (void)stimulus:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	StimDesc stimDesc;
	
	[eventData getBytes:&stimDesc length:sizeof(StimDesc)];
	if ((stimDesc.attendLoc == 0 && stimDesc.type0 == kTargetStim) || (stimDesc.attendLoc == 1 && stimDesc.type1 == kTargetStim)) {
		targetOnTimeMS = [eventTime unsignedLongValue];
	}
}

- (void)taskMode:(NSData *)eventData eventTime:(NSNumber *)eventTime {
    long taskMode;
    
	[eventData getBytes:&taskMode length:sizeof(long)];
    if (taskMode == kTaskIdle) {
        if (histHighlightIndex >= 0) {
            [hist[histHighlightIndex] setHighlightHist:NO];
            histHighlightIndex = -1;
        }
		
		if (plotHighlightIndex >= 0) {
			[reactPlot[plotHighlightIndex] setHighlightPlot:NO];
			[perfPlot[plotHighlightIndex] setHighlightPlot:NO];
			plotHighlightIndex = -1;
		}
    }
}

- (void)temporalFreqParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	[eventData getBytes:&temporalFreqParams length:sizeof(StimParams)];
	[self checkParams];
}

		
- (void)trial:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	[eventData getBytes:&trial length:sizeof(TrialDesc)];
	
	// Highlight the appropriate histogram
	if (histHighlightIndex != trial.targetContrastIndex) {
        if (histHighlightIndex >= 0) {
            [hist[histHighlightIndex] setHighlightHist:NO];
        }
		histHighlightIndex = trial.targetContrastIndex;
        if (histHighlightIndex >= 0) {
			[hist[histHighlightIndex] setHighlightHist:YES];
		}
    }
	
	// HighLight the appropriate plots
	if (plotHighlightIndex != trial.targetTemporalFreqIndex) {
		if (plotHighlightIndex >= 0) {
			[reactPlot[plotHighlightIndex] setHighlightPlot:NO];
			[perfPlot[plotHighlightIndex] setHighlightPlot:NO];
		}
		plotHighlightIndex = trial.targetTemporalFreqIndex;
		if (plotHighlightIndex >= 0) {
			[reactPlot[plotHighlightIndex] setHighlightPlot:YES];
			[perfPlot[plotHighlightIndex] setHighlightPlot:YES];
		}
	}
}

- (void)trialEnd:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
    long clevel, eot, minN, reactTimeMS, eotCode, ignoredValue, contrastIndex;
    long contrastLevels = contrastParams.levels;
	long temporalFreqIndex, targetIndex;
	double numberOfCompletedTrials, numberOfCorrectTrials;

	temporalFreqIndex = trial.targetTemporalFreqIndex;
	contrastIndex = trial.targetContrastIndex;
	targetIndex = trial.targetIndex;
	
	
	// Nothing to update on catch trials
	if (contrastIndex < 0) {
		return;
	}
	[eventData getBytes:&eotCode length:sizeof(long)];
	
	// if correct, add the juice reward value to juiceTimes
	if (eotCode == kEOTCorrect) {
		[[juiceTimes objectAtIndex:targetIndex] addValue:juiceMS];
	}
	[meanJuiceWithTimePlot setNeedsDisplay:YES];
	
	
	// Process reaction time on correct or wrong decisions
	if (eotCode == kEOTCorrect || eotCode == kEOTWrong) {
		reactTimeMS = saccadeOnTimeMS - targetOnTimeMS;
		[[reactTimes[temporalFreqIndex] objectAtIndex:contrastIndex] addValue:reactTimeMS];
		
		if (reactTimeMS < kMaxRT) {					// Irrespective of temporal frequency
			rtDist[contrastIndex][reactTimeMS]++;
			[hist[contrastIndex] setNeedsDisplay:YES];
		}
		
		for (clevel = (contrastLevels > 1) ? 1 : 0, minN = LONG_MAX; clevel < contrastLevels; clevel++) {
			minN = MIN(minN, [[reactTimes[temporalFreqIndex] objectAtIndex:clevel] n]);
		}
		if (minN == LONG_MAX) {
			[reactPlot[temporalFreqIndex] setTitle:[NSString stringWithFormat:@"Reaction Times (TF: %.1f)", 
												temporalFreqFromIndex(temporalFreqIndex)]];
		}
		else
			[reactPlot[temporalFreqIndex] setTitle:[NSString stringWithFormat:@"Reaction Times (TF: %.1f, n >= %ld)", 
													temporalFreqFromIndex(temporalFreqIndex), minN]];
		
		[reactPlot[temporalFreqIndex] setNeedsDisplay:YES];
	}
	
	// We increment the counts of different eots in a customized way.  We want corrects, wrongs, fails and Distracted
	// to add to 100%, because these are outcomes of completed trials.  Ignores are
	// computed to be percentages of all trials, and are set to be averaged across all contrast values and temporal frequencies,
	// because they occur before a contrast value or temporal frequency is defined.  We leave breaks and false alarms as computed on the
	// target contrast and temporal frequency of the trial, although these two should not depend of the target contrast or temporal frequency 
	// because the tiral is over before the target apears.

	ignoredValue = 0;
	switch (eotCode) {
		case kEOTCorrect:
		case kEOTWrong:
		case kEOTFailed:
		case kEOTDistracted:
			for (eot = 0; eot < kEOTTotal; eot++) {
				if (eot != kEOTIgnored) {
					[[performance[eot][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:((eot == eotCode) ? 1 : 0)];
					[[performanceWithTime[eot] objectAtIndex:targetIndex] addValue:((eot == eotCode) ? 1 : 0)];
				}
			}
			break;
		case kEOTFAlarm:
			[[performance[kEOTBroke][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:0];
			[[performance[kEOTFAlarm][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:1];
			[[performanceWithTime[kEOTBroke] objectAtIndex:targetIndex] addValue:0];
			[[performanceWithTime[kEOTFAlarm] objectAtIndex:targetIndex] addValue:1];
			break;
		case kEOTBroke:
			[[performance[kEOTBroke][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:1];
			[[performance[kEOTFAlarm][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:0];
			[[performanceWithTime[kEOTBroke] objectAtIndex:targetIndex] addValue:1];
			[[performanceWithTime[kEOTFAlarm] objectAtIndex:targetIndex] addValue:0];
			break;
		case kEOTIgnored:
			[[performance[kEOTBroke][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:0];
			[[performance[kEOTFAlarm][temporalFreqIndex] objectAtIndex:contrastIndex] addValue:0];
			[[performanceWithTime[kEOTBroke] objectAtIndex:targetIndex] addValue:0];
			[[performanceWithTime[kEOTFAlarm] objectAtIndex:targetIndex] addValue:0];
			ignoredValue = 1;
			break;
		default:
			break;
	}
	
	if (eotCode < kEOTTotal) {
		for (clevel = (contrastLevels > 1) ? 1 : 0; clevel < contrastLevels; clevel++) {
			[[performance[kEOTIgnored][temporalFreqIndex] objectAtIndex:clevel] addValue:ignoredValue];
		}
		[[performanceWithTime[kEOTIgnored] objectAtIndex:targetIndex] addValue:ignoredValue];
	}
	
    for (clevel = (contrastLevels > 1) ? 1 : 0, minN = LONG_MAX; clevel < contrastLevels; clevel++) {
        for (eot = 0; eot < kEOTTotal; eot++) {
            if (eot != kEOTBroke && eot != kEOTFAlarm && eot != kEOTIgnored) {
                minN = MIN(minN, [[performance[eot][temporalFreqIndex] objectAtIndex:clevel] n]);
            }
        }
    }
	
	if (minN == LONG_MAX) {
		[perfPlot[temporalFreqIndex] setTitle:[NSString stringWithFormat:@"Performance (TF: %.1f)", 
										   temporalFreqFromIndex(temporalFreqIndex)]];
	}
	else {
		[perfPlot[temporalFreqIndex] setTitle:[NSString stringWithFormat:@"Performance (TF: %.1f, n >= %ld)", 
											   temporalFreqFromIndex(temporalFreqIndex), minN]];
	}
	
	[perfPlot[temporalFreqIndex] setNeedsDisplay:YES];
	[perfWithTimePlot setNeedsDisplay:YES];
	
	
	// Total number of trials
	// if correct, add the juice reward value to juiceTimes
	numberOfCompletedTrials = [[performanceWithTime[kEOTCorrect] objectAtIndex:targetIndex] n];
	numberOfCorrectTrials = (double)(numberOfCompletedTrials*[[performanceWithTime[kEOTCorrect] objectAtIndex:targetIndex] mean]);
	[[totalTrials objectAtIndex:targetIndex] addValue:numberOfCompletedTrials];
	[[totalCorrectTrials objectAtIndex:targetIndex] addValue:numberOfCorrectTrials];
	[totalTrialsPlot setNeedsDisplay:YES];
}

@end
