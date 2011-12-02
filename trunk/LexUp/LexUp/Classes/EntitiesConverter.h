//
//  EntitiesConverter.h
//  LexUp
//
//  Created by Mikalai on 11-12-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntitiesConverter : NSObject
{
    NSMutableString* resultString;
}

@property (nonatomic, retain) NSMutableString* resultString;

- (NSString*)convertEntiesInString:(NSString*)s;

@end
