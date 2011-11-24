//
//  Global.h
//  LexUp
//
//  Created by user on 11-01-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lexcore.h"

@interface Global : NSObject
{
}

@property (readonly, nonatomic) NSString* dataFileName;

@property (readonly, nonatomic) NSString* settingsFileName;

@property (readonly, nonatomic) int maxEntriesCount;

@property (readonly, nonatomic) NSString* cardTemplateFileName;

@property (readonly, nonatomic) NSString* dictionaryTemplateFileName;

+ (Global *)sharedInstance;
- (id) init;
- (void) dealloc;
+ (id)allocWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id) retain;
- (unsigned) retainCount;
- (void) release;
- (id) autorelease;

@end


int utf8_compare(void* pArg, int aLength, const void* a, int bLength, const void* b);