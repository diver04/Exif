//
//  MyCustomCell.m
//  ExifProject
//
//  Created by diver on 2018/1/4.
//  Copyright © 2018年 IACP. All rights reserved.
//

#import "MyCustomCell.h"

@implementation MyCustomCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];
    if(backgroundStyle == NSBackgroundStyleDark)
    {
        //选中时背景颜色
        self.layer.backgroundColor = [NSColor darkGrayColor].CGColor;
        //字体颜色
        _nameLabel.textColor = [NSColor lightGrayColor];
        _pathLabel.textColor = [NSColor lightGrayColor];
    }
    else
    {
        self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
        _nameLabel.textColor = [NSColor blackColor];
        _pathLabel.textColor = [NSColor blackColor];
    }
}

@end
