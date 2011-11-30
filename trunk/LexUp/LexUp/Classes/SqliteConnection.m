//
//  SqliteConnection.m
//  LexUp
//
//  Created by user on 11-02-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SqliteConnection.h"
#import "Global.h"

//        NSDate* start = [NSDate date];      
//NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:start];
//printf("Duration: %f\r\n", interval * 1000.0);

@implementation SqliteConnection

- (lex_words*) getWordList:(NSString*)prefix
{
    lex_words *words;
    lex* lx = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_get_words_using_dictionaries(lx, (char*)[prefix cStringUsingEncoding:NSUTF8StringEncoding], [Global sharedInstance].maxEntriesCount, &words);
    lex_close(lx);
    return words;
}

- (lex_cards*) getCardsByWord:(NSString*)word
{
    lex* lx = nil;
    lex_cards* cards = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_get_cards_by_word(lx, (char*)[word cStringUsingEncoding:NSUTF8StringEncoding], &cards);
    lex_close(lx);
    return cards;
}
/*
- (void)getCurrentWordLanguage:(lex_language**)wLang andCard:(lex_language**)cLang
{
    lex* lx = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_settings_get_current_languages(lx, wLang, cLang);
    lex_close(lx);
}

- (void)setCurrentWordLanguage:(lex_language*)wLang andCard:(lex_language*)cLang
{
    lex* lx = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_settings_set_current_languages(lx,  wLang, cLang);
    lex_close(lx);
}
*/
- (lex_dictionaries*) getDictionaries
{
    lex* lx = nil;
    lex_dictionaries* dics = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_get_all_dictionaries(lx, &dics);
    lex_close(lx);
    return dics;
}

- (void) setDictionary:(int)dicId enabled:(int)enabled
{
    lex* lx = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_settings_set_dictionary_enabled(lx, dicId, enabled);
    lex_close(lx);
}

- (int) getDictionaryEnabled:(int)dicId
{
    lex* lx = nil;
    int enabled;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
        lex_settings_get_dictionary_enabled(lx, dicId, &enabled);
    lex_close(lx);
    return enabled;
}

- (int) importDictionary:(NSString*)name indexLanguage:(NSString*)iLang contentLanguage:(NSString*)cLang indexLanguageId:(int*)ilId contentLanguageId:(int*)clId
{
    lex* lx = nil;
    int dicId;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
    {
        const char *dicName = [name cStringUsingEncoding:NSUTF8StringEncoding];
        const char *indexLanguage = [iLang cStringUsingEncoding:NSUTF8StringEncoding];
        const char *contentLanguage = [cLang cStringUsingEncoding:NSUTF8StringEncoding];
        dicId = lex_import_dictionary(lx, dicName, indexLanguage, contentLanguage, ilId, clId);
    }
    lex_close(lx);
    return dicId;
}

- (void) importCard:(char*)cardText forWord:(char*)word intoDictionary:(int)dictionaryId indexLanguageId:(int)ilId contentLanguageId:(int)clId
{
    lex* lx = nil;
    if(lex_open((char*)[[Global sharedInstance].dataFileName UTF8String], (char*)[[Global sharedInstance].settingsFileName UTF8String], &lx, utf8_compare) == 0)
    {
        lex_import_card(lx, dictionaryId, word, cardText, ilId, clId);
    }
    lex_close(lx);
}


@end
