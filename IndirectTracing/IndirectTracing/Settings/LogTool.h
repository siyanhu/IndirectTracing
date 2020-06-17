//
//  LogTool.h
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LogTool : NSObject

+ (NSString *)timeEpoch:(NSString *)format_str switchTimezone:(bool)enable_zone;
+ (void)controllog:(NSString *)tag content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
