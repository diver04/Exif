//
//  ViewController.m
//  ExifProject
//
//  Created by diver on 15/09/2017.
//  Copyright © 2017 IACP. All rights reserved.
//

#import "ViewController.h"
#import "Exif.h"
#import "MyCustomCell.h"

static long indexOfRow = -1;//在删除图片和最后一个图片被加载起到了重要的作用
static BOOL rowSeleted = NO;//每次刷新页面，默认选择最后的一个图片
@interface ViewController()
{
    Exif *_exif;
    MyCustomCell *_myCell;
}
@end

@implementation ViewController
- (void)awakeFromNib{
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"MyCell" bundle:nil] forIdentifier:@"LY"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.设置 Table View 可以接收的 Drag Type，对应 accept 的代理方法
    // NSFilenamesPboardType : 拖文件进来会执行代理
    // NSStringPboardType : 拖字符串进来会执行代理
    [self.tableView registerForDraggedTypes:@[NSFilenamesPboardType, NSStringPboardType]];
    _exif = [Exif sharedInstance];
    self.urlArray = [NSMutableArray array];
}

// 2.此代理方法里写拖拽时的显示方式
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    return NSDragOperationCopy;
}

// 3.拖拽完成时的数据操作
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{
    //NSLog(@"%s", __FUNCTION__);
    NSPasteboard *pasteBoard = [info draggingPasteboard];
    if ([[pasteBoard types] containsObject:NSFilenamesPboardType])
    {
        NSArray *paths = [pasteBoard propertyListForType:NSFilenamesPboardType];
        
        for (NSString *path in paths)
        {
            NSURL *url = [[NSURL alloc] initWithString:[path stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLPathAllowedCharacterSet]];
            //NSLog(@"本次拖动图片的地址 = %@", url);
            //判断数组中是否已经存在该图片的url
            BOOL isURL = NO;
            for (NSString *string in self.urlArray) {
                if ([string isEqualToString:[NSString stringWithFormat:@"%@",url]]) {
                    isURL = YES;
                }
            }
            //如果不存在则更新数据，刷新页面...
            if (!isURL) {
                [self.urlArray addObject:[NSString stringWithFormat:@"%@",url]];
            }
            [self.tableView reloadData];
        }
        return YES;
    }
    return NO;
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.urlArray.count;
}

//选中某个单元格
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    NSLog(@"单元格被选中--row--%ld",row);
#pragma mark -- indexOfRow在该方法中出现始终为选中图片的索引
    indexOfRow = row;
    [self updateOutLineView:row];  //因为调用了updateOutLineView:方法，所以rowSeleted现在为NO
    return YES;
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row{
    //return [self.contents objectAtIndex:row];
    //因为是NO,所以最后一个图片可以被选中，然后信息可以被加载
    if (!rowSeleted) {
        NSIndexSet *index = [[NSIndexSet alloc] initWithIndex:self.urlArray.count - 1];
        [tableView.animator selectRowIndexes:index byExtendingSelection:NO];
#pragma mark -- indexOfRow在该方法中出现始终为最后一张图片的索引
        indexOfRow = self.urlArray.count - 1;
        [self updateOutLineView:indexOfRow];
    }
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 95;
}

- (void)autoClick{
    NSPoint p = [NSEvent mouseLocation];
    NSLog(@"自动点击");
    [self click:p];
}

- (void)click:(CGPoint)point
{
    CGEventRef mousedown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mousedown);
    CGEventRef mouseup = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseup);
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    [tableView setFocusRingType:NSFocusRingTypeExterior];
    MyCustomCell *cell = [tableView makeViewWithIdentifier:@"LY" owner:self];
    if (self.urlArray.count != 0) {
        self.urlString = [NSString stringWithFormat:@"%@",[self.urlArray objectAtIndex:row]];
        NSArray *array = [self.urlString componentsSeparatedByString:@"/"];
        NSString *pictureName = [NSString stringWithFormat:@"%@",[array lastObject]];
        NSString *pathStr = [self.urlString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@",pictureName] withString:@""];
        cell.myImageView.image = [[NSImage alloc] initWithContentsOfFile:self.urlString];
        cell.nameLabel.stringValue = pictureName;
        cell.pathLabel.stringValue = pathStr;
        [tableView scrollRowToVisible:row];
    }
    return cell;
}

#pragma mark == OutLineView 数据刷新
- (void)updateOutLineView:(NSInteger)index{
    NSMutableArray *ExifArray = [NSMutableArray array];
    //如果为-1，不会加载数据，代表清空
    if (indexOfRow != -1 && self.urlArray.count != 0) {
        ExifArray = [_exif getExifInfo:[self.urlArray objectAtIndex:index]];
//        NSLog(@"%@",ExifArray);
    }
    _childrenDictionary = [[NSMutableDictionary alloc] init];
    // Group Children
    for (NSDictionary *dict in ExifArray) {
        [_childrenDictionary addEntriesFromDictionary:dict];
        //NSLog(@"%@",_childrenDictionary);
    }
    // Group Names
    _topLevelItem = [_childrenDictionary allKeys];
    
    [_outlineView sizeLastColumnToFit];
    [_outlineView reloadData];//重新加载
    [_outlineView setFloatsGroupRows:YES];
    [_outlineView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    
    // Expand all the root items; disable the expansion animation that normally happens
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [_outlineView expandItem:nil expandChildren:YES];
    [NSAnimationContext endGrouping];
    //保证最后一个图片始终会被选中
    rowSeleted = NO;
}

#pragma mark outlineView
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    //NSLog(@"--%@",item);
    //重新加载之后会先进入此方法,之后还会进入一次。第一次加载父节点，第二次获取相应的子节点
    //NSLog(@"11 %s",__func__);
    NSInteger count = [[self childrenForItem:item] count];
//    NSLog(@"count = %ld", count);
    return count;
}

//返回一个节点名字（root）,该方法会多次调用
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    //item代表父节点
    //NSLog(@"*******%@",item);
    //NSLog(@"22 %s",__func__);
    NSArray *array = [self childrenForItem:item];
    NSString *string = [array objectAtIndex:index];
//    NSLog(@"%@",string);
    return string;
}

//判断每个节点是否可以扩展
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
   // NSLog(@"item = %@",item);
    //判断item是否属于某个节点，如果返回为空，则代表是该item是节点名称
    //NSLog(@"%@",[outlineView parentForItem:item]);
    if ([outlineView parentForItem:item] == nil) {
//        NSLog(@"YES");
        return YES;
    }
    else{
//        NSLog(@"NO");
        return NO;
    }
}

//当节点内的所有item加载完之后，调用此方法，该方法会不停的调用
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    id objectValue = nil;
    objectValue = item;
    return objectValue;
}

//将item作为key值，获取字典的value
- (NSArray *)childrenForItem:(id)item
{
    NSArray *children = nil;
    if (item == nil)
    {
        children = _topLevelItem;
    }
    else
    {
        children = [_childrenDictionary objectForKey:item];
        //NSLog(@"%@",children);
    }
    return children;
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (IBAction)deleteImage:(id)sender {
    if (indexOfRow != -1){
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        [alert setMessageText:@"确定删除该图片?"];
        [alert setInformativeText:@"删除之后，图片无法恢复"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
            if(returnCode == NSAlertFirstButtonReturn)
            {
                [self.urlArray removeObjectAtIndex:indexOfRow];
                rowSeleted = YES;//因为只有YES才可以，保证tableView中的数据可以正常删除
                [self.tableView reloadData];
                [self.outlineView reloadData];
                indexOfRow = -1;
                [self updateOutLineView:indexOfRow];
            }
        }];
    }else{
        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"确定"];
        [alert setInformativeText:@"请选择要删除的图片"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        }];
    }
}

@end
