//
//  LexUpViewController.h
//  LexUp
//
//  Created by user on 11-01-04.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lexcore.h"
#import "EntriesListView.h"

@interface LexUpViewController : UIViewController<UITableViewDelegate, UISearchBarDelegate, TouchEventObserverDelegate, UIScrollViewDelegate>
{
    IBOutlet UISearchBar* searchField;
    IBOutlet EntriesListView* candidatesTable;
    
    lex_words* _candidates;
}

- (lex_words*) get_candidates;
 
- (void) clear_candidates;

@end

