//
//  NLDocument.h
//  Appline
//
//  Created by Mike Lee on 7/11/13.
//  Copyright (c) 2013 New Lemurs. All rights reserved.
//

@class NLTimelineView;

@interface NLDocument : NSPersistentDocument

@property (nonatomic, weak) IBOutlet NLTimelineView *timelineView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *segmentedControl;

- (IBAction)refreshSalesReports:(id)sender; // Due to Xcode bug that keeps trying to call it
- (IBAction)refreshSalesReports;
- (IBAction)reloadSalesReports;

@end
