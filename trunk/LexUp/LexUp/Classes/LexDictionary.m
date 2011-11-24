//
//  LexDictionary.m
//  LexUp
//
//  Created by user on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LexDictionary.h"


@implementation LexDictionary

+ (id) withValue:(lex_dictionary *) value
{
    LexDictionary *dic = [[[LexDictionary alloc] init] autorelease];
    [dic set:value];
    return dic;
}

- (void) set:(lex_dictionary*) dic
{
    _dic = dic;
}

- (lex_dictionary*) get
{
    return _dic;
}


@end
