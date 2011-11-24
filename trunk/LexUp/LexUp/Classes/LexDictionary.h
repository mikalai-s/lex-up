//
//  LexDictionary.h
//  LexUp
//
//  Created by user on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lexcore.h"


@interface LexDictionary : NSObject {
    lex_dictionary *_dic;
}

+ (id) withValue:(lex_dictionary *) value;

- (void) set:(lex_dictionary*) dic;

- (lex_dictionary*) get;

@end
