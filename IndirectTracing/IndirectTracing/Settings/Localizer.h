//
//  Localizer.h
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Localizer : NSObject
+ (Localizer *)sharedinstance;

- (NSDictionary *)readpreset;
- (void)modifypreset:(NSString *)preset_k withContent:(NSString *)preset_v;

- (NSString *)getLocalizedStringFrom:(NSString *)key alter:(NSString *)alter;

@end

NS_ASSUME_NONNULL_END
