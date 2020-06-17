//
//  FileManager.h
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileManager : NSObject

+ (FileManager *)sharedinstance;
- (BOOL)fileExisted:(NSString *)filePath isDirectory:(BOOL)isDirectory;

@end

NS_ASSUME_NONNULL_END
