//
//  Localizer.m
//  IndirectTracing
//
//  Created by HU Siyan on 16/6/2020.
//  Copyright © 2020 HU Siyan. All rights reserved.
//

#import "Localizer.h"
#import "LogTool.h"
#import "FileManager.h"

@implementation Localizer

static NSString *LOCALIZER_ERROR_TAG = @"LOCALIZER_ERROR";

static Localizer *_instance = nil;
static NSBundle *bundle = nil;
static NSString *default_code = nil;
static NSString *current_code = nil;

+ (Localizer *)sharedinstance {
    if (_instance) return _instance;
    @synchronized ([Localizer class]) {
        if (!_instance) {
            _instance = [[self alloc]init];
            [_instance preset];
            return _instance;
        }
    }
    return nil;
}

- (void)preset {
    NSDictionary *constantContent = [self readpreset];
    if (!constantContent) {
        [LogTool controllog:LOCALIZER_ERROR_TAG content:@"FATAL ERROR"];
        return;
    }
    if ([[constantContent valueForKey:@"SAVED_LANG"] length] > 0) {
        current_code = [constantContent valueForKey:@"SAVED_LANG"];
        default_code = @"en";
        [self switchLanguageTo:current_code];
    }
}

#pragma mark - Private Functions
- (void)setLocalizedLanguage:(NSString *)localizedLang {
    NSString *path = [[NSBundle mainBundle] pathForResource:localizedLang ofType:@"lproj"];
    if (![[FileManager sharedinstance] fileExisted:path isDirectory:YES]) {
        path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    }
        bundle = [NSBundle bundleWithPath:path];
}

- (void)switchLanguageTo:(NSString *)toLang {
    // add code to switch language for the whole app
    [self setLocalizedLanguage:@"Base"];
}

#pragma mark - Public Functions
- (NSString *)getLocalizedStringFrom:(NSString *)key alter:(NSString *)alter {
    return [bundle localizedStringForKey:key value:alter table:nil];
}

- (NSDictionary *)readpreset {
    NSArray *catelog = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [[catelog objectAtIndex:0] stringByAppendingPathComponent:@"savedstatus.plist"];
    NSDictionary *constantContent = [NSDictionary dictionaryWithContentsOfFile:path];
    if (!constantContent) {
        constantContent = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"savedstatus" ofType:@"plist"]];
        NSError *error;
        NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:constantContent format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListWriteInvalidError error:&error];
        if (!error && plistData) {
            [plistData writeToFile:path atomically:YES];
            constantContent = [NSDictionary dictionaryWithContentsOfFile:path];
        } else {
            [LogTool controllog:LOCALIZER_ERROR_TAG content:error.localizedDescription];
        }
    }
    if (constantContent)
        return constantContent;
    else {
        [LogTool controllog:LOCALIZER_ERROR_TAG content:@"CANNOT FIND CONSTANT DICT"];
        return nil;
    }
}

- (void)modifypreset:(NSString *)preset_k withContent:(NSString *)preset_v {
    NSArray *catelog = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [[catelog objectAtIndex:0] stringByAppendingPathComponent:@"savedstatus.plist"];

    NSMutableDictionary *constantContent = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [constantContent setValue:preset_v forKey:preset_k];
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:constantContent format:NSPropertyListXMLFormat_v1_0 options:NSPropertyListWriteInvalidError error:&error];
    if (!error && plistData) {
        [plistData writeToFile:path atomically:YES];
    } else {
        [LogTool controllog:LOCALIZER_ERROR_TAG content:error.localizedDescription];
    }
}

@end
