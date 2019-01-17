//
//  MyCustomCell.h
//  ExifProject
//
//  Created by diver on 2018/1/4.
//  Copyright © 2018年 IACP. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyCustomCell : NSTableCellView
@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *pathLabel;
@property (weak) IBOutlet NSImageView *myImageView;

@end
