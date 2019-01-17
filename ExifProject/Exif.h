//
//  Exif.h
//  ExifProject
//
//  Created by diver on 15/09/2017.
//  Copyright © 2017 IACP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface Exif : NSObject
+ (Exif *)sharedInstance;
- (NSMutableDictionary *)getExifFromImageData: (NSData *)imageData;
- (NSMutableDictionary *)getImageDataFromURL:(NSString *)urlString;
- (NSMutableDictionary *)downloadImageFromFile:(NSString *)filePath;
- (void)saveImageAs:(NSString *)aName toPath:(NSString *)aPath fromImage:(NSString *)bPath;
- (NSMutableArray *)getExifInfo:(NSString *)path;
@end
