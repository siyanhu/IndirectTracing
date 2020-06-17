//
//  FileManager.m
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "FileManager.h"

@interface FileManager () <NSFileManagerDelegate> {
    NSFileManager *fileManager;
}

@end

@implementation FileManager

static FileManager *_instance = nil;
static NSString *sitename = @"default";

+ (FileManager *)sharedinstance {
    if (_instance) return _instance;
    @synchronized ([FileManager class]) {
        if (!_instance) {
            _instance = [[self alloc]init];
            [_instance preset];
            return _instance;
        }
    }
    return nil;
}

- (void)preset {
    fileManager = [NSFileManager defaultManager];
    fileManager.delegate = self;
}

#pragma mark - Public Functions
- (BOOL)fileExisted:(NSString *)filePath isDirectory:(BOOL)isDirectory {
    BOOL ifDirectory = isDirectory;
    return [fileManager fileExistsAtPath:filePath isDirectory:&ifDirectory];
}

@end
