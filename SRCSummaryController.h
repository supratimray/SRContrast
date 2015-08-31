//
//  SRCSummaryController.h
//  Experiment
//
//  Copyright (c) 2006. All rights reserved.
//

#import "SRC.h"
#import "SRCStateSystem.h"

@interface SRCSummaryController : LLScrollZoomWindow {

    double				accumulatedRunTimeS;
	BlockStatus			blockStatus;
	StimParams			contrastParams;
	long				catchTrials;
	long				dayComputer;			// Count of trials with computer certification errors
	long				dayEOTs[kEOTTotal];
    long				dayEOTTotal;
    long 				eotCode;
    NSDictionary		*fontAttr;
	long				juiceMS;
    NSDictionary		*labelFontAttr;
    NSDictionary		*leftFontAttr;
	long 				lastEOTCode;
    double				lastStartTimeS;
    BOOL				newTrial;
	long				recentComputer;			// Count of trials with computer certification errors
    long				recentEOTs[kEOTTotal];
    long				recentEOTTotal;
	long				stimAdded;
	StimParams			temporalFreqParams;
    long 				taskMode;
	long				totalJuiceMS;
	TrialDesc			trial;

    IBOutlet			LLEOTView *dayPlot;
    IBOutlet			LLEOTHistoryView *eotHistory;
    IBOutlet			NSTableView *percentTable;
    IBOutlet			LLEOTView *recentPlot;
    IBOutlet			NSTableView *trialTable;
	IBOutlet			NSTableView *summaryTable;
	IBOutlet			NSTextField *textField;
	IBOutlet			NSTextField *juiceTextField;
	IBOutlet			NSTextField *catchTrialsTextField;
}

- (NSDictionary *)makeAttributesForFont:(NSFont *)font alignment:(NSTextAlignment)align tailIndex:(float)indent;
- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (id)percentTableColumn:(NSTableColumn *)tableColumn row:(long)row;
- (id)trialTableColumn:(NSTableColumn *)tableColumn row:(long)row;
- (id)summaryTableColumn:(NSTableColumn *)tableColumn row:(long)row;

@end
