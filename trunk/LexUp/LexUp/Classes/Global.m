//
//  Global.m
//  LexUp
//
//  Created by user on 11-01-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Global.h"


@implementation Global



// properties

- (NSString*) dataFileName
{       
    return [[NSBundle mainBundle] pathForResource:@"data" ofType:@"slt"];
}

- (NSString*) settingsFileName
{   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"settings.slt"];
}

- (NSString*) cardTemplateFileName
{
    return [[NSBundle mainBundle] pathForResource:@"CardTemplate" ofType:@"html"];
}

- (NSString*) dictionaryTemplateFileName
{
    return [[NSBundle mainBundle] pathForResource:@"DictionaryTemplate" ofType:@"html"];
}

- (int) maxEntriesCount
{
    return 1000;
}

+ (Global *)sharedInstance
{
    // the instance of this class is stored here
    static Global *myInstance = nil;
	
    // check to see if an instance already exists
    if (nil == myInstance) { myInstance  = [[[self class] alloc] init]; }
    
    // return the instance of this class
    return myInstance;
}

- (id) init
{
	self = [super init];	
		
	return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
	static Global *myInstance = nil;
    @synchronized(self)
	{
        if(myInstance == nil)
		{
            myInstance = [super allocWithZone:zone];
            return myInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone { return self; }

- (id) retain { return self; }

- (unsigned) retainCount { return UINT_MAX; }

- (void) release { [super release]; }

- (id) autorelease
{
    return self;
}

- (void)dealloc
{    
    [super dealloc];
}


@end


int utf8_compare(void* pArg, int aLength, const void* a, int bLength, const void* b)
{/*   
    NSString *aa = [[NSString alloc] initWithUTF8String:(const char *)a];    
    NSString *bb = [[NSString alloc] initWithUTF8String:(const char *)b];
    
    NSComparisonResult result = [aa caseInsensitiveCompare:bb];
    
    [aa release];
    [bb release];
    
    return (int)result;*/
    return 0;
}
