//
//  SRCSummaryController.m
//  Experiment
//
//  Window with summary information trial events.
//
//  Copyright (c) 2006. All rights reserved.
//

#define NoGlobals

#import "SRCSummaryController.h"
#import "SRC.h"
#import "UtilityFunctions.h"

#define kEOTDisplayTimeS		1.0
#define kLastEOTTypeDisplayed   kEOTIgnored	+ 2	// Count everything up to kEOTIgnored
#define kPlotBinsDefault		10
#define kTableRows				(kLastEOTTypeDisplayed + 4) // extra for blank rows, total, etc.
#define	kXTickSpacing			100
#define kSummaryTableRows		6


//enum {kBlankRow0 = kLastEOTTypeDisplayed + 1, kComputerRow, kBlankRow1, kRewardsRow, kTotalRow};
enum {kComputerRow = kLastEOTTypeDisplayed + 1, kRewardsRow, kTotalRow};
enum {kColorColumn = 0, kEOTColumn, kDayColumn, kRecentColumn};
enum {kTemporalFreqColumn = 0, kCurrentLoc0Column, kAllLoc0Column,  kCurrentLoc1Column, kAllLoc1Column};

NSString *SRCSummaryWindowBrokeKey = @"SRCSummaryWindowBroke";
NSString *SRCSummaryWindowComputerKey = @"SRCSummaryWindowComputer";
NSString *SRCSummaryWindowCorrectKey = @"SRCSummaryWindowCorrect";
NSString *SRCSummaryWindowDateKey = @"SRCSummaryWindowDate";
NSString *SRCSummaryWindowFailedKey = @"SRCSummaryWindowFailed";
NSString *SRCSummaryWindowIgnoredKey = @"SRCSummaryWindowIgnored";
NSString *SRCSummaryWindowTotalKey = @"SRCSummaryWindowTotal";
NSString *SRCSummaryWindowWrongKey = @"SRCSummaryWindowWrong";
NSString *SRCSummaryWindowFAlarmKey = @"SRCSummaryWindowFAlarm";
NSString *SRCSummaryWindowDistractedKey = @"SRCSummaryWindowDistracted";


@implementation SRCSummaryController

- (void)dealloc {

	[[task defaults] setFloat:[NSDate timeIntervalSinceReferenceDate] forKey:SRCSummaryWindowDateKey];
	[[task defaults] setInteger:dayEOTs[kEOTBroke] forKey:SRCSummaryWindowBrokeKey];
	[[task defaults] setInteger:dayEOTs[kEOTCorrect] forKey:SRCSummaryWindowCorrectKey];
	[[task defaults] setInteger:dayEOTs[kEOTFailed] forKey:SRCSummaryWindowFailedKey];
	[[task defaults] setInteger:dayEOTs[kEOTIgnored] forKey:SRCSummaryWindowIgnoredKey];
	[[task defaults] setInteger:dayEOTs[kEOTWrong] forKey:SRCSummaryWindowWrongKey];
	[[task defaults] setInteger:dayEOTs[kEOTFAlarm] forKey:SRCSummaryWindowFAlarmKey];
	[[task defaults] setInteger:dayEOTs[kEOTDistracted] forKey:SRCSummaryWindowDistractedKey];	
	[[task defaults] setInteger:dayEOTTotal forKey:SRCSummaryWindowTotalKey];
	[[task defaults] setInteger:dayComputer forKey:SRCSummaryWindowComputerKey];
    [fontAttr release];
    [labelFontAttr release];
    [leftFontAttr release];
    [super dealloc];
}
 
- (id)init {
	double timeNow, timeStored;
    
    if ((self = [super initWithWindowNibName:@"SRCSummaryController" defaults:[task defaults]]) != nil) {
		[percentTable reloadData];
        fontAttr = [self makeAttributesForFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]
                alignment:NSRightTextAlignment tailIndex:-12];
        [fontAttr retain];
        labelFontAttr = [self makeAttributesForFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]
                alignment:NSRightTextAlignment tailIndex:0];
        [labelFontAttr retain];
        leftFontAttr = [self makeAttributesForFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]
                alignment:NSLeftTextAlignment tailIndex:0];
        [leftFontAttr retain];
        
        [dayPlot setData:dayEOTs];
        [recentPlot setData:recentEOTs];
    
		lastEOTCode = -1;
		
		timeStored = [[task defaults] floatForKey:SRCSummaryWindowDateKey];
		timeNow = [NSDate timeIntervalSinceReferenceDate];
		if (timeNow - timeStored < 12 * 60 * 60) {			// Less than 12 h old?
			dayEOTs[kEOTBroke] = [[task defaults] integerForKey:SRCSummaryWindowBrokeKey];
			dayEOTs[kEOTCorrect] = [[task defaults] integerForKey:SRCSummaryWindowCorrectKey];
			dayEOTs[kEOTFailed] = [[task defaults] integerForKey:SRCSummaryWindowFailedKey];
			dayEOTs[kEOTIgnored] = [[task defaults] integerForKey:SRCSummaryWindowIgnoredKey];
			dayEOTs[kEOTWrong] = [[task defaults] integerForKey:SRCSummaryWindowWrongKey];
			dayEOTs[kEOTFAlarm] = [[task defaults] integerForKey:SRCSummaryWindowFAlarmKey];
			dayEOTs[kEOTDistracted] = [[task defaults] integerForKey:SRCSummaryWindowDistractedKey];			
			dayEOTTotal = [[task defaults] integerForKey:SRCSummaryWindowTotalKey];
			dayComputer = [[task defaults] integerForKey:SRCSummaryWindowComputerKey];
		}
		
		totalJuiceMS = 0;
		catchTrials  = 0;
    }
    return self;
}

- (NSDictionary *)makeAttributesForFont:(NSFont *)font alignment:(NSTextAlignment)align tailIndex:(float)indent {

	NSMutableParagraphStyle *para; 
    NSMutableDictionary *attr;
    
        para = [[NSMutableParagraphStyle alloc] init];
        [para setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        [para setAlignment:align];
        [para setTailIndent:indent];
        
        attr = [[NSMutableDictionary alloc] init];
        [attr setObject:font forKey:NSFontAttributeName];
        [attr setObject:para forKey:NSParagraphStyleAttributeName];
        [attr autorelease];
        [para release];
        return attr;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	StimParams *pTemporalFreqParam;
		
	if (tableView == percentTable) {
        return kTableRows;    
	}
    else if (tableView == trialTable) {
		pTemporalFreqParam = &temporalFreqParams;
        return ((int)(pTemporalFreqParam->levels)+1);
    }
	else if (tableView == summaryTable) {
        return kSummaryTableRows;
    }
	else {
        return 0;
    }
}


// Return an NSAttributedString for a cell in the percent performance table

- (id)percentTableColumn:(NSTableColumn *)tableColumn row:(long)row {

    long column;
    NSString *string;
	NSDictionary *attr = fontAttr;
 
//    if (row == kBlankRow0 || row == kBlankRow1) {		// the blank rows
//        return @" ";
//    }
    column = [[tableColumn identifier] intValue];
    switch (column) {
		case kColorColumn:
            string = @" ";
			break;
        case kEOTColumn:
			attr = labelFontAttr;
            switch (row) {
                case kTotalRow:
                    string = @"Total:";
                    break;
				case kRewardsRow:
					string = @"Rewards:";
					break;
				case kComputerRow:					// row for computer failures
                    string = @"Computer:";
					break;
				case kLastEOTTypeDisplayed-kEOTFAlarm:
					string = @"FAlarm";
					break;
				case kLastEOTTypeDisplayed-kEOTDistracted:
					string = @"Distracted";
					break;
                default:
                    string = [NSString stringWithFormat:@"%@:", 
								[LLStandardDataEvents trialEndName:kLastEOTTypeDisplayed - row]];
                    break;
            }
            break;
        case kDayColumn:
            if (row == kTotalRow) {
                string = [NSString stringWithFormat:@"%ld", dayEOTTotal];
            }
            else if (row == kRewardsRow) {
                string = [NSString stringWithFormat:@"%ld", dayEOTs[kEOTCorrect]];
            }
            else if (dayEOTTotal == 0) {
                string = @" ";
            }
			else if (row == kComputerRow) {		// row reserved for computer failures
               string = [NSString stringWithFormat:@"%ld", dayComputer];
			}
			else if (row == kLastEOTTypeDisplayed-kEOTFAlarm){
				string = [NSString stringWithFormat:@"%ld%%", 
						(long)round(dayEOTs[kLastEOTTypeDisplayed - row] * 100.0 / dayEOTTotal)];
			}
			else if (row == kLastEOTTypeDisplayed-kEOTDistracted){
				string = [NSString stringWithFormat:@"%ld%%", 
						(long)round(dayEOTs[kLastEOTTypeDisplayed - row] * 100.0 / dayEOTTotal)];
			}
			
            else {
               string = [NSString stringWithFormat:@"%ld%%",
							(long)round(dayEOTs[kLastEOTTypeDisplayed - row] * 100.0 / dayEOTTotal)];
            }
            break;
       case kRecentColumn:
            if (row == kTotalRow) {
                string = [NSString stringWithFormat:@"%ld", recentEOTTotal];
            }
            else if (row == kRewardsRow) {
                string = [NSString stringWithFormat:@"%ld", recentEOTs[kEOTCorrect]];
            }
            else if (recentEOTTotal == 0) {
                string = @" ";
            }
			else if (row == kComputerRow) {		// row reserved for computer failures
               string = [NSString stringWithFormat:@"%ld", recentComputer];
			}
           else {
				if (recentEOTTotal == 0) {
					string = @"";
				}
				else if (row == kLastEOTTypeDisplayed-kEOTFAlarm){
					string = [NSString stringWithFormat:@"%ld%%",
							(long)round(recentEOTs[kLastEOTTypeDisplayed - row] * 100.0 / recentEOTTotal)];
				}
				else if (row == kLastEOTTypeDisplayed-kEOTDistracted){
					string = [NSString stringWithFormat:@"%ld%%",
							(long)round(recentEOTs[kLastEOTTypeDisplayed - row] * 100.0 / recentEOTTotal)];
				}
				else {
					string = [NSString stringWithFormat:@"%ld%%",
							(long)round(recentEOTs[kLastEOTTypeDisplayed - row] * 100.0 / recentEOTTotal)];
				}
            }
            break;
        default:
            string = @"???";
            break;
    }
	return [[[NSAttributedString alloc] initWithString:string attributes:attr] autorelease];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row {

    if (tableView == percentTable) {
        return [self percentTableColumn:tableColumn row:row];
    }
    else if (tableView == trialTable) {
        return [self trialTableColumn:tableColumn row:row];
    }
	else if (tableView == summaryTable) {
		return [self summaryTableColumn:tableColumn row:row];
	}
    else {
        return @"";
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row {
	return NO;
}

// Display the color patches showing the EOT color coding, and highlight the text for the last EOT type

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex {

	long column;
	
	if (tableView == percentTable) { 
		column = [[tableColumn identifier] intValue];
		if (column == kColorColumn) {
			[cell setDrawsBackground:YES]; 
			if (rowIndex <= kLastEOTTypeDisplayed) {
				[cell setBackgroundColor:[LLStandardDataEvents eotColor:kLastEOTTypeDisplayed - rowIndex]];
			}
			else {
				[cell setBackgroundColor:[NSColor whiteColor]];
			}
		}
		else {
			if (!newTrial && (lastEOTCode >= 0) && (lastEOTCode == (kLastEOTTypeDisplayed - rowIndex))) {
				[cell setBackgroundColor:[NSColor controlHighlightColor]];
			}
			else {
				[cell setBackgroundColor:[NSColor whiteColor]];
			}
		}
    }
		
	if (tableView == trialTable) {
		column = [[tableColumn identifier] intValue];
		
		if (column >= kTemporalFreqColumn) {
			if (rowIndex == trial.targetTemporalFreqIndex) {
				[cell setBackgroundColor:[NSColor controlHighlightColor]];
			}
			else {
				[cell setBackgroundColor:[NSColor whiteColor]];
			}
		}
	}
}

- (id)trialTableColumn:(NSTableColumn *)tableColumn row:(long)row {
	
    long column, temporalFreqs;
	
    //double timeLeftS;
    NSAttributedString *cellContents;
    NSString *string;
	StimParams *pContrastParam;
	StimParams *pTemporalFreqParam;
	BlockStatus *pBS = &blockStatus;

	pContrastParam = &contrastParams;
	pTemporalFreqParam = &temporalFreqParams;
	
	column = [[tableColumn identifier] intValue];
	temporalFreqs = pTemporalFreqParam->levels;
	
	switch (column) {
		case kTemporalFreqColumn:
			if (row < temporalFreqs) {
				string = [NSString stringWithFormat: @"%.2f",temporalFreqFromIndex(row,0)];
			}
			else {
				string = @"Total: ";
			}
			break;
		
		case kCurrentLoc0Column:
			if (row < temporalFreqs) {
				string = [NSString stringWithFormat:@"%ld",stimDoneThisBlockGivenTemporalFreq(pBS->blocksDone, kAttend0, row)];
			}
			else {
				string = [NSString stringWithFormat:@"%ld",stimDoneThisBlock(pBS->blocksDone, kAttend0)];
				
			}
			break;
			
		case kAllLoc0Column:
			if (row < temporalFreqs) {
				string = [NSString stringWithFormat:@"%ld",stimDoneAllBlocksGivenTemporalFreq(kAttend0, row)];
			}
			else {
				string = [NSString stringWithFormat:@"%ld",stimDoneAllBlocks(kAttend0)];
				
			}
			break;
			
		case kCurrentLoc1Column:
			if (row < temporalFreqs) {
				string = [NSString stringWithFormat:@"%ld",stimDoneThisBlockGivenTemporalFreq(pBS->blocksDone, kAttend1, row)];
			}
			else {
				string = [NSString stringWithFormat:@"%ld",stimDoneThisBlock(pBS->blocksDone, kAttend1)];
				
			}
			break;
			
		case kAllLoc1Column:
			if (row < temporalFreqs) {
				string = [NSString stringWithFormat:@"%ld",stimDoneAllBlocksGivenTemporalFreq(kAttend1, row)];
			}
			else {
				string = [NSString stringWithFormat:@"%ld",stimDoneAllBlocks(kAttend1)];
			}
			break;	
			
		default:
			string = @"???";
			break;
	}
	
	cellContents = [[NSAttributedString alloc] initWithString:string attributes:leftFontAttr];
	[cellContents autorelease];
    return cellContents;
}
			
			
- (id)summaryTableColumn:(NSTableColumn *)tableColumn row:(long)row {
	
    long column, contrasts, temporalFreqs;
	long index;
	
    //double timeLeftS;
    NSAttributedString *cellContents;
    NSString *string;
	StimParams *pContrastParam;
	StimParams *pTemporalFreqParam;
	BlockStatus *pBS = &blockStatus;
	
	pContrastParam = &contrastParams;
	pTemporalFreqParam = &temporalFreqParams;
	
	contrasts = pContrastParam->levels;
	temporalFreqs = pTemporalFreqParam->levels;
	
	column = [[tableColumn identifier] intValue];
	
	switch (row) {
        case 0:
			string = [NSString stringWithFormat:@"Attend side %ld %@",  pBS->attendLoc, (trial.instructTrial) ? @"(Instruction trial)" : @""];
			break;
        case 1:
			string = [NSString stringWithFormat:@"Contrasts: %ld, TFs: %ld", contrasts, temporalFreqs];
			break;
        case 2:
            string = [NSString stringWithFormat:@"Side %ld of %ld; Block %ld of %ld", (pBS->locsDoneThisBlock) + 1, (pBS->locsPerBlock), 
								(pBS->blocksDone) + 1, (pBS->blockLimit)];
            break;
		case 3:
			string = [NSString stringWithFormat:@"Num Stim: %ld, Target contrast: %.1f, TF: %.2f", trial.numStim, contrastFromIndex(trial.targetContrastIndex),temporalFreqFromIndex(trial.targetTemporalFreqIndex,0)];
			break;
		case 4:
			
			string = @"X ";
			if (trial.numStim>1) {
				for (index=1;index<trial.numStim;index++)		// First sample doesn't count
				{
					if (index<trial.targetIndex) {
						
						if (index==trial.distIndex)
							string = [string stringByAppendingString:@"X "];
						else
							string = [string stringByAppendingString:@"S "];
					}
					else if (index == trial.targetIndex)
						string = [string stringByAppendingString:@"T "];
					
					else {
						if (index==trial.distIndex)
							string = [string stringByAppendingString:@"X "];
						else
							string = [string stringByAppendingString:@"s "];
					}
				}
			}
			break;
			
		case 5:
			
			string = @"X ";
			if (trial.numStim>1) {
				
				for (index=1;index<trial.numStim;index++)		// First sample doesn't count
				{
					if (index==trial.targetIndex)
						string = [string stringByAppendingString:@"X "];
					else
						if (index==trial.distIndex)
							string = [string stringByAppendingString:@"D "];
						else
							string = [string stringByAppendingString:@"S "];
				}
			}
			break;
        default:
            string = @"???";
            break;
    }
    cellContents = [[NSAttributedString alloc] initWithString:string attributes:leftFontAttr];
	[cellContents autorelease];
    return cellContents;
} 

// Methods related to data events follow:

- (void)blockStatus:(NSData *)eventData eventTime:(NSNumber *)eventTime {

    [eventData getBytes:&blockStatus length:sizeof(BlockStatus)];
}

- (void) contrastParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	[eventData getBytes:&contrastParams length:sizeof(StimParams)];
}

- (void)juiceMS:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
	[eventData getBytes:&juiceMS length:sizeof(long)];
	totalJuiceMS += juiceMS;
	[juiceTextField setStringValue:[NSString stringWithFormat:@"%ld", totalJuiceMS ]];
}

- (void)reset:(NSData *)eventData eventTime:(NSNumber *)eventTime {

    long index;
    
    recentComputer = recentEOTTotal = 0;
    for (index = 0; index <= kLastEOTTypeDisplayed; index++) {
        recentEOTs[index] = 0;
    }
    accumulatedRunTimeS = 0;
    if (taskMode == kTaskRunning) {
        lastStartTimeS = [LLSystemUtil getTimeS];
    }
	[eotHistory reset];
	[percentTable reloadData];
	[trialTable reloadData];
	[summaryTable reloadData];
	
	catchTrials = 0;
}

- (void)stimAdded:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
	[eventData getBytes:&stimAdded length:sizeof(long)];
}


- (void) taskMode:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	[eventData getBytes:&taskMode length:sizeof(long)];
    switch (taskMode) {
        case kTaskRunning:
            lastStartTimeS = [LLSystemUtil getTimeS];
            break;
        case kTaskStopping:
            accumulatedRunTimeS += [LLSystemUtil getTimeS] - lastStartTimeS;
            break;
        default:
            break;
    }
}

- (void) temporalFreqParams:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
	[eventData getBytes:&temporalFreqParams length:sizeof(StimParams)];
}

- (void) trialCertify:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	long certifyCode; 
	
	[eventData getBytes:&certifyCode length:sizeof(long)];
    if (certifyCode != 0) { // -1 because computer errors stored separately
        recentComputer++;  
        dayComputer++;  
    }
}


- (void) trialEnd:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	[eventData getBytes:&eotCode length:sizeof(long)];
    if (eotCode <= kLastEOTTypeDisplayed) {
        recentEOTs[eotCode]++;
        recentEOTTotal++;  
        dayEOTs[eotCode]++;
        dayEOTTotal++;  
    }
    newTrial = NO;
	lastEOTCode = eotCode;
	[eotHistory addEOT:eotCode];
    [percentTable reloadData];
	[trialTable reloadData];
	[summaryTable reloadData];
	[dayPlot setNeedsDisplay:YES];
	[recentPlot setNeedsDisplay:YES];
		
	switch (lastEOTCode) {
		case kEOTCorrect:
			if (trial.instructTrial)
				[textField setStringValue:[NSString stringWithFormat:@"Correct... %ld instruction trials done.", (blockStatus.instructsDone+1)]];
			else if (trial.catchTrial)
				[textField setStringValue:[NSString stringWithFormat:@"Correct... catch trial."]];
			else {
				[textField setStringValue:[NSString stringWithFormat:@"Correct... adding %ld stims", stimAdded ]];
			}
			break;
		case kEOTWrong:
			[textField setStringValue:@"Wrong..."];
			break;
		case kEOTFailed:
            [textField setStringValue:[NSString stringWithFormat:@"Failed... adding %ld stims", stimAdded]];
			break;
		case kEOTBroke:
			[textField setStringValue:@"Broke..."];
			break;	
		case kEOTIgnored:
			[textField setStringValue:@"Ignored..."];
			break;
		case kEOTFAlarm:
			[textField setStringValue:@"False alarm..."];
			break;
		case kEOTDistracted:
			[textField setStringValue:@"Distracted..."];
			break;
		default:
			break;
	}
	
	if (trial.catchTrial) {
		catchTrials++;
	}
	
	if (recentEOTTotal>0) {
		[catchTrialsTextField setStringValue:[NSString stringWithFormat:@"%ld of %ld, %.1f pc",catchTrials, recentEOTTotal ,(float)(100.0*((float)(catchTrials)/(float)(recentEOTTotal)))]];
	}
}

//- (void) stimuli:(NSData *)eventData eventTime:(NSNumber *)eventTime {
	
//	[eventData getBytes:stimuli];
//}

- (void) trial:(NSData *)eventData eventTime:(NSNumber *)eventTime {

	[eventData getBytes:&trial length:sizeof(TrialDesc)];
    newTrial = YES;
	[trialTable reloadData];
    [percentTable reloadData];
	[summaryTable reloadData];
}

@end
