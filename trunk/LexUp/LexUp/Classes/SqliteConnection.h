//
//  SqliteConnection.h
//  LexUp
//
//  Created by user on 11-02-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lexcore.h"

@interface SqliteConnection : NSObject {

   
}

-(lex_words*)getWordList:(NSString*)prefix;

- (lex_cards*) getCardsByWord:(NSString*)word;
/*
- (void)getCurrentWordLanguage:(lex_language**)wLang andCard:(lex_language**)cLang;

- (void)setCurrentWordLanguage:(lex_language*)wLang andCard:(lex_language*)cLang;
*/
- (lex_dictionaries*) getDictionaries;

- (void) setDictionary:(int)dicId enabled:(int)enabled;

- (int) getDictionaryEnabled:(int)dicId;

@end