//
//  ViewController.h
//  ExifProject
//
//  Created by diver on 15/09/2017.
//  Copyright © 2017 IACP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>
{
    NSArray *_topLevelItem;
    NSMutableDictionary *_childrenDictionary;
}
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSOutlineView *outlineView;
@property NSString *urlString;
@property NSMutableArray *urlArray;

@end

