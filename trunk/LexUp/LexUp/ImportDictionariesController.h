//
//  ImportDictionariesController.h
//  LexUp
//
//  Created by Mikalai on 11-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionariesSelectorController.h"

@interface ImportDictionariesController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView* dictionariesToImportTable;
    
    NSMutableDictionary *dictionary;
    
    DictionariesSelectorController *_backController;
}

- (id)initWithBackView:(DictionariesSelectorController *)backController;

- (void) importDictionary:(NSString *)filePath;

@end
