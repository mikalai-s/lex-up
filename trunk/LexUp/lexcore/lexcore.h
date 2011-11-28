/*
 *  lexcore.h
 *  SqliteSample
 *
 *  Created by user on 11-01-03.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */



#include "sqlite3.h"

typedef struct lex
{
    char* dataFileName;
    char* settingsFileName;
    sqlite3* dataDb;
    sqlite3* settingsDb;
} lex;

typedef struct
{
    long id;
    char *word;
} lex_word;

typedef struct
{
    long count;
    lex_word** items;
} lex_words;

typedef struct
{
    long id;
    char* name;
    char* code;
} lex_language;

typedef struct
{
    long id;
    char* name;
    int enabled;
    lex_language *wordLanguage;
} lex_dictionary;

typedef struct
{
    long count;
    lex_dictionary** items;
} lex_dictionaries;

typedef struct
{
    lex_dictionary* dictionary;
    char *card;
} lex_card;

typedef struct
{
    lex_word* word;
    long count;
    lex_card** items;
} lex_cards;


#define INITIAL_SIZE 1000

char* copy_string(char* src);
//
int lex_ensure_settings_db(lex *lx);
//
int lex_create_settings_table(lex *lx);
//
int lex_open(char *dataFileName, char *settingsFileName, lex** lx, int(*collation)(void*,int,const void*,int,const void*));
//
int lex_get_words(lex* lx, char* prefix, long count, long wordLanguageId, lex_words** words);
//
int lex_get_words_using_dictionaries(lex* lx, char* prefix, long count, lex_words** words);
//
int lex_get_cards_by_word(lex* lx, char* word, lex_cards** cards);
//
int lex_get_dictionaries(lex* lx, long wordLanguageId, lex_dictionaries** dictionaries);
//
int lex_get_all_dictionaries(lex* lx, lex_dictionaries** dictionaries);
//
int lex_get_language(lex* lx, long id, lex_language **lang);
//
void get_enabled_dictionaries_string(int count, int *dics, char *dictionaries);
//
int lex_close(lex* lx);
//
int lex_free_word(lex_word** entry);
//
int lex_free_words(lex_words** fetch);
//                         
int lex_free_card(lex_card** card);
//
int lex_free_cards(lex_cards** cards);
//
int lex_free_dictionary(lex_dictionary** dictionary);
//
int lex_free_dictionaries(lex_dictionaries** dictionaries);
//
int lex_free_language(lex_language** language);

/* settings */

int lex_settings_get_option(lex *lx, char *option, int *value);

int lex_settings_set_option(lex *lx, char *option, int value);

int lex_settings_get_enabled_dictionaries(lex *lx, int *count, int *dicIds);
/*
int lex_settings_get_current_languages(lex* lx, lex_language** wlang, lex_language** clang);

int lex_settings_set_current_languages(lex* lx, lex_language* wlang, lex_language* clang);
*/
int lex_settings_set_dictionary_enabled(lex *lx, int dicId, int enabled);

int lex_settings_get_dictionary_enabled(lex *lx, int dicId, int *enabled);

int lex_import_dictionary(lex *lx, const char *name, const char *indexLanguage, const char *contentLanguage);
/*
int lex_insert_dictionary(lex *lx, const char *name, int indexLanguageId, int contentLanguageId);

int lex_insert_langauge(lex *lx, const char *name);
*/
/* end settings */





