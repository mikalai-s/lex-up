//
//  DictionaryConfigController.h
//  LexUp
//
//  Created by Mikalai on 11-11-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lexcore.h"

@interface DictionaryConfigController : UITableViewController
{
    lex_dictionaries* _dictionaries;
    NSMutableDictionary *_groupedDictionaries;
}

- (lex_dictionaries*) get_dictionaries;

- (void) clearDictionaries;

@end
