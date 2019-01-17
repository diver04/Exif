//
//  Exif.m
//  ExifProject
//
//  Created by diver on 15/09/2017.
//  Copyright © 2017 IACP. All rights reserved.
//

#import "Exif.h"
#import <AppKit/NSImage.h>
//#import <AppKit/NSBitmapImageRep.h>
static Exif *_exif = nil;
@implementation Exif
+ (Exif *)sharedInstance{
    if (_exif == nil) {
        _exif = [[Exif alloc] init];
    }
    return _exif;
}

//一、获取网上图片的data
- (NSMutableDictionary *)getImageDataFromURL:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSMutableDictionary *dict = [self getExifFromImageData:data];
    return dict;
}

//二、获取本地图片的data
- (NSMutableDictionary *)downloadImageFromFile:(NSString *)filePath{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSMutableDictionary *dict = [self getExifFromImageData:data];
    return dict;
}

//获取EXIF信息
- (NSMutableDictionary *)getExifFromImageData: (NSData *)imageData{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    NSDictionary *dict = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL));
    NSMutableDictionary *dictInfo = [NSMutableDictionary dictionaryWithDictionary:dict];
    return dictInfo;
}

//三、写入Exif信息
- (void)saveImageAs:(NSString *)aName toPath:(NSString *)aPath fromImage:(NSString *)imagePath{
//    1.获取源图片中的EXIF文件和GPS文件
    NSData *data = [NSData dataWithContentsOfFile:imagePath];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSDictionary *imageInfo = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
    NSMutableDictionary *metaDataDic = [imageInfo mutableCopy];
    NSMutableDictionary *exifDic = [[metaDataDic objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    NSMutableDictionary *GPSDic = [[metaDataDic objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy];
//    2、修改EXIF和GPS文件中内容
    [exifDic setObject:[NSNumber numberWithFloat:1234.3] forKey:(NSString *)kCGImagePropertyExifExposureTime];
    [exifDic setObject:@"SenseTime" forKey:(NSString *)kCGImagePropertyExifLensModel];
    [GPSDic setObject:[NSNumber numberWithFloat:45.67] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDic setObject:[NSNumber numberWithFloat:116] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    [metaDataDic setObject:exifDic forKey:(NSString*)kCGImagePropertyExifDictionary];
    [metaDataDic setObject:GPSDic forKey:(NSString*)kCGImagePropertyGPSDictionary];
    //NSLog(@"修改之后:%@",metaDataDic);
//    3.将修改之后文件写入到图片之中
    CFStringRef UTI = CGImageSourceGetType(source);
    NSMutableData *newImageData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1, NULL);
    CGImageDestinationAddImageFromSource(destination, source, 0, (__bridge CFDictionaryRef)metaDataDic);
    BOOL isOK = CGImageDestinationFinalize(destination);
    if (isOK) {
//        NSLog(@"destination写入成功！！");
    }
//    4.保存图片到指定路径

    NSString *directoryDocuments = [[NSString alloc]initWithFormat:@"%@/%@.jpg",aPath,aName];
    //NSLog(@"保存的路径名称:%@",directoryDocuments);
    BOOL isSuccess = [newImageData writeToFile:directoryDocuments atomically:YES];
    if (isSuccess) {
//        NSLog(@"数据写入成功！");
    }
}

- (NSMutableArray *)getExifInfo:(NSString *)path{
    NSMutableArray *bigArray = [NSMutableArray array];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *ExifDict = [self getExifFromImageData:data];
    //NSLog(@"%@",ExifDict);
    /*对获取的数据进行处理*/
    NSMutableArray *newArray1 = [NSMutableArray array];
    NSArray *allKeysArray = [ExifDict allKeys];
    for (NSString *key in allKeysArray) {
        //不包含这个字符
        if ([key rangeOfString:@"{"].location == NSNotFound)
        {
            NSString *value = [ExifDict valueForKey:key];
            NSString *newString = [NSString stringWithFormat:@"%@ : %@",key,value];
            [newArray1 addObject:newString];
            //            NSLog(@"newArray = %@",newArray1);
        }
        else{
            //NSLog(@"{...} = %@",key);
            NSDictionary *insideItemDict = [ExifDict valueForKey:key];
            NSArray *insideAllKey = [insideItemDict allKeys];
            NSMutableArray *myArray = [NSMutableArray array];
            //对里面的字典进行重组
            for (NSString *key in insideAllKey)
            {
                NSMutableString *string = [NSMutableString string];
                id value = [insideItemDict valueForKey:key];
                if ([value isKindOfClass:[NSArray class]])
                {
                    for (NSString *item in value)
                    {
                        [string appendFormat:@"%@,",item];
                    }
                }
                else{
                    NSString *newString = [NSString stringWithFormat:@"%@ : %@",key,value];
                    [myArray addObject:newString];
                }
                
                if (![string isEqualToString:@""]) {
                    [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
                    NSString *newString = [NSString stringWithFormat:@"%@ : %@",key,string];
                    [myArray addObject:newString];
                }
            }
            NSDictionary *itemDict = @{key:myArray};
            //NSLog(@"----%@",itemDict);
            [bigArray addObject:itemDict];
        }
    }
    NSDictionary *newDict1 = @{@"Common":newArray1};
    [bigArray addObject:newDict1];
    return bigArray;
}

@end
