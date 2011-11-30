//
//  DictionariesSelectorController.h
//  LexUp
//
//  Created by user on 11-01-18.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lexcore.h"

@interface DictionariesSelectorController : UITableViewController
{
    lex_dictionaries* _dictionaries;
    NSMutableDictionary *_groupedDictionaries;
}

- (lex_dictionaries*) get_dictionaries;

- (void) reloadView;

@end
