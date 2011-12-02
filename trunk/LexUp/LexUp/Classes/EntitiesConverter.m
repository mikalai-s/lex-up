//
//  EntitiesConverter.m
//  LexUp
//
//  Created by Mikalai on 11-12-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EntitiesConverter.h"

@implementation EntitiesConverter

@synthesize resultString;

- (id)init
{
    if([super init]) {
        resultString = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
    [self.resultString appendString:s];
}

- (NSString*)convertEntiesInString:(NSString*)s {
    if(s == nil) {
        NSLog(@"ERROR : Parameter string is nil");
    }
    [self.resultString setString:@""];
    NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
    NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSXMLParser* xmlParse = [[[NSXMLParser alloc] initWithData:data] autorelease];
    [xmlParse setDelegate:self];
    [xmlParse parse];
    return [NSString stringWithFormat:@"%@",resultString];
}

- (void)dealloc {
    [resultString release];
    [super dealloc];
}

@end