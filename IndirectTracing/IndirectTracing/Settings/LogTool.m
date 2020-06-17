//
//  LogTool.m
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "LogTool.h"

@implementation LogTool

+ (NSString *)timeEpoch:(NSString *)format_str switchTimezone:(bool)enable_zone {
    NSDate *gcr = [NSDate date];
    NSDate *today;
    if (enable_zone) {
        NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
        NSInteger currentinterval = [timeZone secondsFromGMTForDate:gcr];
        today = [gcr dateByAddingTimeInterval:currentinterval];
    } else {
        today = gcr;
    }
    NSString *gcr_str = @"";
    if (!format_str) {
        NSInteger gcrInSeconds = [today timeIntervalSince1970];
        gcr_str = [NSString stringWithFormat:@"%ld", gcrInSeconds];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:format_str];
        gcr_str = [formatter stringFromDate:today];
    }
    return gcr_str;
}

+ (void)controllog:(NSString *)tag content:(NSString *)content {
    NSLog(@"%@: %@\t%@\n", tag, content, [LogTool timeEpoch:@"yyyy-MM-dd HH:mm:ss" switchTimezone:true]);
}

@end
