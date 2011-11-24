/*
 *  lexcore.c
 *  SqliteSample
 *
 *  Created by user on 11-01-03.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "lexcore.h"
#include "stdlib.h"
#include "string.h"
#include "stdio.h"

void lex_show_error(char *format, ...)
{
#ifdef DEBUG
    va_list arguments;
    va_start(arguments,format);
    printf(format, arguments);
    va_end(arguments);
#endif
}

char* copy_string(char* src)
{
    int length = strlen(src) + 1;
    char* dest = (char*)sqlite3_malloc(length * sizeof(char));
    strcpy(dest, src);
    dest[length - 1] = '\0';
    return dest;    
}

int lex_open(char *dataFileName, char *settingsFileName, lex** lx, int(*collation)(void*,int,const void*,int,const void*))
{
    *lx = (lex*)sqlite3_malloc(sizeof(lex));
    sqlite3 *sql = 0;
    int result = sqlite3_open(dataFileName, &sql);
    (*lx)->dataFileName = dataFileName;
    (*lx)->settingsFileName = settingsFileName;
    (*lx)->dataDb = sql;
    if(SQLITE_OK == result)
    {
        /*
        if(collation != 0)
        {        
            result = sqlite3_create_collation((*lx)->sqlite, "utf8ci", SQLITE_UTF8, 0, collation);
            if(result != SQLITE_OK)
            {
                printf("error: sqlite3_create_collation == %s\r\n", sqlite3_errmsg(sql));
                return -1;
            }
        }
        */
    }
    else
    {
        printf("error in opening data db: sqlite3_open == %s\r\n", sqlite3_errmsg(sql));
        return -1;
    }
    
    return lex_ensure_settings_db(*lx);
}

int lex_ensure_settings_db(lex *lx)
{
    sqlite3 *sql = 0;
    int result = sqlite3_open(lx->settingsFileName, &sql);

    lx->settingsDb = sql;
    if(SQLITE_OK == result)
    {
        int requiresTable = 0;
        
        // ensure setting file - it might not exist now
        char query[256] = "select count(*) from sqlite_master where name='settings'";
        sqlite3_stmt* stmt = 0;
        char *tail = 0;
        int result = sqlite3_prepare_v2(lx->settingsDb, query, 256, &stmt, (const char**)&tail);
        if(SQLITE_OK == result)
        {
            result = sqlite3_step(stmt);
            if(SQLITE_ROW == result)
            {
                requiresTable = (sqlite3_column_int(stmt, 0) == 0);
            }        
            else
            {
                printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->settingsDb));
            }        
        }
        else
        {
            printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        }
        
        if(SQLITE_OK != sqlite3_finalize(stmt))
        {
            printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        }        
        
        if(requiresTable)
            return lex_create_settings_table(lx);
    }
    else
    {
        printf("error in opening settings db: sqlite3_open == %s\r\n", sqlite3_errmsg(sql));
        return -1;
    }
    
    return 0;
}

int lex_create_settings_table(lex *lx)
{   
    char *error;
    char query[512] = "create table settings(option text, value integer);";
    if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
    {
        printf("error in creating settings table: sqlite3_exec == %s\r\n", error);
        return -1;
    }
    
    sprintf(query, "create table enabled_dictionaries(id integer)");
    if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
    {
        printf("error in creating enabled_dictionaries table: sqlite3_exec == %s\r\n", error);
        return -1;
    }
    
    lex_dictionaries *dics;
    if(lex_get_all_dictionaries(lx, &dics) == 0)
    {
        for(int i = 0; i < dics->count; i ++)
        {
            sprintf(query, "insert into enabled_dictionaries values(%ld)", dics->items[i]->id);

            if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
            {
                printf("error in inserting into enabled_dictionaries table: sqlite3_exec == %s\r\n", error);
                return -1;
            }
        }
    }
    return lex_free_dictionaries(&dics);
}

int lex_get_language(lex* lx, long id, lex_language **lang)
{
    int querySize = 512;
    char query[querySize];
    sprintf(query, "select l.id, l.name, l.code from languages as l where l.id = %ld", id);
    lex_show_error("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        result = sqlite3_step(stmt);
        if(SQLITE_ROW == result)
        {
            lex_language* wl = (lex_language*)sqlite3_malloc(sizeof(lex_language));
            wl->id = sqlite3_column_int(stmt, 0);
            wl->name = copy_string((char*)sqlite3_column_text(stmt, 1));
            wl->code = copy_string((char*)sqlite3_column_text(stmt, 2));
            (*lang) = wl;
        }        
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
        }        
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;  
}
/*
// returns list of words from dictionary table
int lex_get_words(lex* lx, char* prefix, long count, long wordLanguageId, lex_words** words)
{    
    lex_words* fetch = (lex_words*)sqlite3_malloc(sizeof(lex_words));
    fetch->count = 0;
    fetch->items = 0;
    
    int querySize = 1024;
    char query[querySize];

    if(prefix == 0 || prefix[0] == '\0')
    {
        sprintf(query, 
               "select distinct word from cards \
               where word_language_id = %ld \
               limit %ld", wordLanguageId, count);        
    }
    else
    {    
        sprintf(query, 
            "select distinct word from cards \
             where word like ? and word_language_id = %ld \
             limit %ld", wordLanguageId, count);
    }
    printf("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
    int _allocatedMemory = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        if(prefix != 0 && prefix[0] != '\0')
        {
            result = sqlite3_bind_text(stmt, 1, prefix, strlen(prefix) * sizeof(char), SQLITE_STATIC);
            if(SQLITE_OK != result)
            {
                printf("error: sqlite3_bind_text == %s\r\n", sqlite3_errmsg(lx->dataDb));
            }
        }
        
        if(SQLITE_OK == result)
        {        
            while(SQLITE_ROW == (result = sqlite3_step(stmt)))
            {        		
                // check whether there is need to reallocate memory for words    
                if(fetch->count >= _allocatedMemory)
                {
                    _allocatedMemory += INITIAL_SIZE;
                    fetch->items = (lex_word**)sqlite3_realloc(fetch->items, _allocatedMemory * sizeof(lex_word*));
                }
            
                lex_word* lw = (lex_word*)sqlite3_malloc(sizeof(lex_word));            
                //lw->id = sqlite3_column_int(stmt, 0);
                lw->word = copy_string((char*)sqlite3_column_text(stmt, 0));
        
                fetch->items[fetch->count++] = lw;
            }
        
            if(SQLITE_DONE == result)
            {
                *words = fetch;
            }
            else
            {
                printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
            }
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;
}
*/
void get_enabled_dictionaries_string(int count, int *dics, char *dictionaries)
{
    if(count == 0)
    {
        sprintf(dictionaries, "0");
    }
    else
    {
        sprintf(dictionaries, "%d", dics[0]);
        for(int i = 1; i < count; i ++)
        {
            sprintf(dictionaries, "%s,%d", dictionaries, dics[i]);
        }
    }
}

int lex_get_words_using_dictionaries(lex* lx, char* prefix, long count, lex_words** words)
{/*
    int wordLanguageId;
    lex_settings_get_option(lx, "word_language_id", &wordLanguageId);
    */
    lex_words* fetch = (lex_words*)sqlite3_malloc(sizeof(lex_words));
    fetch->count = 0;
    fetch->items = 0;
    
    int querySize = 1024;
    char query[querySize];
    
    int dicCount;
    int dictionaries[256];
    lex_settings_get_enabled_dictionaries(lx, &dicCount, dictionaries);
    
    char dicString[256];
    get_enabled_dictionaries_string(dicCount, dictionaries, dicString);
    /*
    if(prefix == 0 || prefix[0] == '\0')
    {
        sprintf(query, 
                "select distinct word from cards \
                where word >= '' and word_language_id = %d and dictionary_id in (%s) \
                limit %ld", wordLanguageId, dicString, count);        
    }
    else*/
    {    
        sprintf(query, 
                "select distinct word from cards \
                where word >= ? and dictionary_id in (%s) \
                limit %ld", dicString, count);
    }
    printf("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
    int _allocatedMemory = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        if(prefix != 0 && prefix[0] != '\0')
        {
            result = sqlite3_bind_text(stmt, 1, prefix, strlen(prefix) * sizeof(char), SQLITE_STATIC);
            if(SQLITE_OK != result)
            {
                printf("error: sqlite3_bind_text == %s\r\n", sqlite3_errmsg(lx->dataDb));
            }
        }
        
        if(SQLITE_OK == result)
        {        
            while(SQLITE_ROW == (result = sqlite3_step(stmt)))
            {        		
                // check whether there is need to reallocate memory for words    
                if(fetch->count >= _allocatedMemory)
                {
                    _allocatedMemory += INITIAL_SIZE;
                    fetch->items = (lex_word**)sqlite3_realloc(fetch->items, _allocatedMemory * sizeof(lex_word*));
                }
                
                lex_word* lw = (lex_word*)sqlite3_malloc(sizeof(lex_word));            
                //lw->id = sqlite3_column_int(stmt, 0);
                lw->word = copy_string((char*)sqlite3_column_text(stmt, 0));
                
                fetch->items[fetch->count++] = lw;
            }
            
            if(SQLITE_DONE == result)
            {
                *words = fetch;
            }
            else
            {
                printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
            }
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;
}



/*
int lex_get_entry_by_word_id(lex* lx, int wordId, lex_word** entry)
{
    int querySize = 128;
    char query[querySize];
    sprintf(query, "select w.id, w.word, d.description from dictionaries as d inner join words as w on d.word = w.word where w.id = %d limit 1", wordId);
    printf("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
	int result = sqlite3_prepare_v2(lx->sqlite, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
            result = sqlite3_step(stmt);
            if(SQLITE_ROW == result)
            {
                lex_word* e = (lex_word*)sqlite3_malloc(sizeof(lex_word));
                e->id = sqlite3_column_int(stmt, 0);
                e->word = copy_string((char*)sqlite3_column_text(stmt, 1));
                e->card = copy_string((char*)sqlite3_column_text(stmt, 2));
                (*entry) = e;
            }        
            else
            {
                printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->sqlite));
            }        
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->sqlite));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->sqlite));
    }
    
    return 0;
}*/
/*
int lex_get_entry_by_word(lex* lx, char* word, lex_words** entry)
{
    int querySize = 128;
    char query[querySize];
    sprintf(query, "select w.id, w.word, d.description from cards as c inner join words as w on c.word_id = w.id where w.word = ?", word);
    printf("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
	int result = sqlite3_prepare_v2(lx->sqlite, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        result = sqlite3_bind_text(stmt, 1, word, strlen(word) * sizeof(char), SQLITE_STATIC);
        if(SQLITE_OK == result)
        {        
            result = sqlite3_step(stmt);
            if(SQLITE_ROW == result)
            {
                lex_entry* e = (lex_entry*)sqlite3_malloc(sizeof(lex_entry));
                e->id = sqlite3_column_int(stmt, 0);
                e->word = copy_string((char*)sqlite3_column_text(stmt, 1));
                e->card = copy_string((char*)sqlite3_column_text(stmt, 2));
                (*entry) = e;
            }        
            else
            {
                printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->sqlite));
            }
        }
        else
        {
            printf("error: sqlite3_bind == %s\r\n", sqlite3_errmsg(lx->sqlite));
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->sqlite));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->sqlite));
    }
    
    return 0;
}
*/

int lex_get_cards_by_word(lex* lx, char* word, lex_cards** cards)
{   /*
    int wordLanguageId, cardLanguageId;
    lex_settings_get_option(lx, "word_language_id", &wordLanguageId);
    lex_settings_get_option(lx, "card_language_id", &cardLanguageId);
    */
    lex_cards* fetch = (lex_cards*)sqlite3_malloc(sizeof(lex_cards));
    fetch->word = 0;
    fetch->count = 0;
    fetch->items = 0;
    
    int querySize = 1024;
    char query[querySize];
    sprintf(query, 
            "select 0, c.word, d.id, d.name, c.card from cards as c \
            inner join dictionaries as d on c.dictionary_id = d.id \
            where c.word = ? \
            order by ui_order asc");
    lex_show_error("%s:\r\n...with paramter '%s'\r\n", query, word);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
    int _allocatedMemory = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        result = sqlite3_bind_text(stmt, 1, word, strlen(word) * sizeof(char), SQLITE_STATIC);
        if(SQLITE_OK == result)
        {
            while(SQLITE_ROW == (result = sqlite3_step(stmt)))
            {            		
                // check whether there is need to reallocate memory for words    
                if(fetch->count >= _allocatedMemory)
                {
                    _allocatedMemory += INITIAL_SIZE;
                    fetch->items = (lex_card**)sqlite3_realloc(fetch->items, _allocatedMemory * sizeof(lex_card*));
                }
                
                if(fetch->word == 0)
                {
                    lex_word* wd = (lex_word*)sqlite3_malloc(sizeof(lex_word));            
                    wd->id = sqlite3_column_int(stmt, 0);
                    wd->word = copy_string((char*)sqlite3_column_text(stmt, 1));
                    fetch->word = wd;
                }
                
                lex_dictionary* dt = (lex_dictionary*)sqlite3_malloc(sizeof(lex_dictionary));            
                dt->id = sqlite3_column_int(stmt, 2);
                dt->name = copy_string((char*)sqlite3_column_text(stmt, 3));
                dt->enabled = sqlite3_column_int(stmt, 4);
                
                lex_card* cr = (lex_card*)sqlite3_malloc(sizeof(lex_card));            
                cr->card = copy_string((char*)sqlite3_column_text(stmt, 4));
                cr->dictionary = dt;
                
                fetch->items[fetch->count++] = cr;
            }            
        }
        else
        {
            printf("error: sqlite3_bind == %s\r\n", sqlite3_errmsg(lx->dataDb));
        }
                
        if(SQLITE_DONE == result)
        {
            *cards = fetch;
        }
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;
}

int lex_get_dictionaries(lex* lx, long wordLanguageId, lex_dictionaries** lFetch)
{   
    lex_dictionaries* fetch = (lex_dictionaries*)sqlite3_malloc(sizeof(lex_dictionaries));
    fetch->count = 0;
    fetch->items = 0;
    
    int querySize = 256;
    char query[querySize];
    sprintf(query, "select id, name, ui_enabled from dictionaries where word_language_id = %ld", wordLanguageId);
    lex_show_error("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
    int _allocatedMemory = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        while(SQLITE_ROW == (result = sqlite3_step(stmt)))
        {            		
            // check whether there is need to reallocate memory for words    
            if(fetch->count >= _allocatedMemory)
            {
                _allocatedMemory += INITIAL_SIZE;
                fetch->items = (lex_dictionary**)sqlite3_realloc(fetch->items, _allocatedMemory * sizeof(lex_dictionary*));
            }
            
            lex_dictionary* lw = (lex_dictionary*)sqlite3_malloc(sizeof(lex_dictionary));            
            lw->id = sqlite3_column_int(stmt, 0);
            lw->name = copy_string((char*)sqlite3_column_text(stmt, 1));
            lw->enabled = sqlite3_column_int(stmt, 2);
            
            fetch->items[fetch->count++] = lw;
        }
        
        if(SQLITE_DONE == result)
        {
            *lFetch = fetch;
        }
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;
}

int lex_get_all_dictionaries(lex* lx, lex_dictionaries** lFetch)
{   
    lex_dictionaries* fetch = (lex_dictionaries*)sqlite3_malloc(sizeof(lex_dictionaries));
    fetch->count = 0;
    fetch->items = 0;
    
    int querySize = 256;
    char query[querySize];
    sprintf(query, "select d.id, d.name, l.id, l.name, l.code from dictionaries as d inner join languages as l on d.word_language_id = l.id order by ui_order asc");
    lex_show_error("%s:\r\n", query);
    
	sqlite3_stmt* stmt = 0;
	char *tail = 0;
    int _allocatedMemory = 0;
	int result = sqlite3_prepare_v2(lx->dataDb, query, querySize, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        while(SQLITE_ROW == (result = sqlite3_step(stmt)))
        {            		
            // check whether there is need to reallocate memory for words    
            if(fetch->count >= _allocatedMemory)
            {
                _allocatedMemory += INITIAL_SIZE;
                fetch->items = (lex_dictionary**)sqlite3_realloc(fetch->items, _allocatedMemory * sizeof(lex_dictionary*));
            }
            
            lex_dictionary* lw = (lex_dictionary*)sqlite3_malloc(sizeof(lex_dictionary));
            lw->id = sqlite3_column_int(stmt, 0);
            lw->name = copy_string((char*)sqlite3_column_text(stmt, 1));
            
            lex_settings_get_dictionary_enabled(lx, lw->id, &(lw->enabled)); // read enabled flag from settings table
            
            lw->wordLanguage = (lex_language*)sqlite3_malloc(sizeof(lex_language)); // todo: we can share one language object for different dictionaries
            lw->wordLanguage->id = sqlite3_column_int(stmt, 2);
            lw->wordLanguage->name = copy_string((char*)sqlite3_column_text(stmt, 3));
            lw->wordLanguage->code = copy_string((char*)sqlite3_column_text(stmt, 4));            
            
            fetch->items[fetch->count++] = lw;
        }
        
        if(SQLITE_DONE == result)
        {
            *lFetch = fetch;
        }
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->dataDb));
    }
    
    return 0;
}

int lex_free_card(lex_card** card)
{
    lex_card* d = (*card);
    if(d == 0)
        return 0;
    if(d->card != 0)
        sqlite3_free(d->card);
    if(d->dictionary != 0)
        lex_free_dictionary(&d->dictionary);
    sqlite3_free(d);
    (*card) = 0;
    return 0;
}

int lex_free_cards(lex_cards** fetch)
{
    lex_cards* f = (*fetch);
    if(f == 0)
        return 0;
    for(int i = 0; i < f->count; i ++)
        lex_free_card(&(f->items[i]));
    if(f->word != 0)
        lex_free_word(&f->word);
    sqlite3_free(f->items);
    sqlite3_free(f);
    (*fetch) = 0;    
    return 0;
}


int lex_free_dictionary(lex_dictionary** ld)
{
    lex_dictionary* d = (*ld);
    if(d == 0)
        return 0;
    if(d->name != 0)
        sqlite3_free(d->name);
    lex_free_language(&(d->wordLanguage));
    sqlite3_free(d);
    (*ld) = 0;
    return 0;
}

int lex_free_dictionaries(lex_dictionaries** fetch)
{
    lex_dictionaries* f = (*fetch);
    if(f == 0)
        return 0;
    for(int i = 0; i < f->count; i ++)
        lex_free_dictionary(&(f->items[i]));
    sqlite3_free(f->items);
    sqlite3_free(f);
    (*fetch) = 0;    
    return 0;
}

int lex_close(lex* lex_obj)
{
    int result = sqlite3_close(lex_obj->dataDb);
    if(SQLITE_OK != result)
        printf("data db closing error: %s\r\n", sqlite3_errmsg(lex_obj->dataDb));

    result = sqlite3_close(lex_obj->settingsDb);
    if(SQLITE_OK != result)
        printf("setting db closing error: %s\r\n", sqlite3_errmsg(lex_obj->settingsDb));    

    sqlite3_free(lex_obj);
    
    return 0;
}

int lex_free_word(lex_word** entry)
{
    lex_word* e = (*entry);    
    if(e == 0)
        return 0;    
    if(e->word != 0)
        sqlite3_free(e->word);
    sqlite3_free(e);
    (*entry) = 0;
    return 0;
}

int lex_free_words(lex_words** fetch)
{
    lex_words* f = (*fetch);
    if(f == 0)
        return 0;
    for(int i = 0; i < f->count; i ++)
        lex_free_word(&(f->items[i]));
    sqlite3_free(f->items);
    sqlite3_free(f);
    (*fetch) = 0;    
    return 0;
}

int lex_free_language(lex_language** language)
{
    lex_language* l = (*language);
    if(l == 0)
        return 0;
    sqlite3_free(l->name);
    sqlite3_free(l->code);
    sqlite3_free(l);
    (*language) = 0;
    return 0;
}

/* settings */

#define SETTING_NO_VALUE 117

int lex_settings_get_option(lex *lx, char *option, int *value)
{
    char query[256];
    sprintf(query, "select value from settings where option='%s'", option);
    sqlite3_stmt* stmt = 0;
    char *tail = 0;
    int result = sqlite3_prepare_v2(lx->settingsDb, query, 256, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        result = sqlite3_step(stmt);
        if(SQLITE_ROW == result)
        {
            *value = sqlite3_column_int(stmt, 0);
            result = 0;
        }        
        else if(SQLITE_DONE == result) // check it if there is no row
        {
            result = SETTING_NO_VALUE;                  
        }
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->settingsDb));
            result = -1;
        }        
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
            
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
    
    return result;
}

int lex_settings_set_option(lex *lx, char *option, int value)
{
    int temp;
    char query[256];
    char *error;
    if(lex_settings_get_option(lx, option, &temp) == SETTING_NO_VALUE)
    {
        // insert new value
        sprintf(query, "insert into settings values('%s', %d)", option, value);
        if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
        {
            printf("error in iserting settings option ('%s' = %d: sqlite3_exec == %s\r\n", option, value, error);
            return -1;
        }
    }    
    else
    {
        // insert new value
        sprintf(query, "update settings set value = %d where option = '%s'", value, option);
        if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
        {
            printf("error in updating settings option ('%s' = %d: sqlite3_exec == %s\r\n", option, value, error);
            return -1;
        }        
    }
    return 0;
}

int lex_settings_get_dictionary_enabled(lex *lx, int dicId, int *enabled)
{
    char query[128];
    sprintf(query, "select count(*) from enabled_dictionaries where id = %d", dicId);
    
    sqlite3_stmt* stmt = 0;
    char *tail = 0;
    int result = sqlite3_prepare_v2(lx->settingsDb, query, 128, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        result = sqlite3_step(stmt);
        if(SQLITE_ROW == result)
        {
            *enabled = (sqlite3_column_int(stmt, 0) > 0);
            result = 0;
        }        
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->settingsDb));
            result = -1;
        }        
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
    return result;
}

int lex_settings_set_dictionary_enabled(lex *lx, int dicId, int enabled)
{
    char *error;
    char query[128];
    sprintf(query, enabled ? 
            "delete from enabled_dictionaries where id = %d; \
             insert into enabled_dictionaries values(%d)" : 
            "delete from enabled_dictionaries where id = %d", dicId, dicId);
    if(SQLITE_OK != sqlite3_exec(lx->settingsDb, query, 0, 0, &error))
    {
        printf("error in setting dictioary enabled: sqlite3_exec == %s\r\n", error);
        return -1;
    }
    return 0;
}

int lex_settings_get_enabled_dictionaries(lex *lx, int *count, int *dicIds)
{
    int c = 0;
    
    char query[128];
    sprintf(query, "select id from enabled_dictionaries");
    
    sqlite3_stmt* stmt = 0;
    char *tail = 0;
    int result = sqlite3_prepare_v2(lx->settingsDb, query, 128, &stmt, (const char**)&tail);
    if(SQLITE_OK == result)
    {
        while(SQLITE_ROW == (result = sqlite3_step(stmt)))
        {
            dicIds[c++] = sqlite3_column_int(stmt, 0);
        }
        
        if(SQLITE_DONE == result)
        {
            *count = c;
        }
        else
        {
            printf("error: sqlite3_step == %s\r\n", sqlite3_errmsg(lx->dataDb));
            result = -1;
        }
    }
    else
    {
        printf("error: sqlite3_prepare_v2 == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
    
    if(SQLITE_OK != sqlite3_finalize(stmt))
    {
        printf("error: sqlite3_finalize == %s\r\n", sqlite3_errmsg(lx->settingsDb));
        result = -1;
    }
    return result;
}
/*
int lex_settings_get_current_languages(lex* lx, lex_language** wlang, lex_language** clang)
{
    int wLangId, cLangId;
    int result = lex_settings_get_option(lx, "word_language_id", &wLangId);
    if(result == 0)
    {
        result = lex_get_language(lx, wLangId, wlang);
        if(result == 0)
        {
            result = lex_settings_get_option(lx, "card_language_id", &cLangId);
            if(result == 0)
            {
                result = lex_get_language(lx, cLangId, clang);                
            }
        }
    }
    return result;
}

int lex_settings_set_current_languages(lex* lx, lex_language* wlang, lex_language* clang)
{
    lex_settings_set_option(lx, "word_language_id", wlang->id);
    lex_settings_set_option(lx, "card_language_id", clang->id);
    
    return 0;    
}
*/
/* end settings */

