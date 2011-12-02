//
//  ImportDictionariesController.h
//  LexUp
//
//  Created by Mikalai on 11-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DictionaryConfigController.h"

@interface ImportDictionariesController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView* dictionariesToImportTable;
    
    NSMutableDictionary *dictionary;
    
    DictionaryConfigController *_backController;
}

- (id)initWithBackView:(DictionaryConfigController *)backController;

- (void) importDictionary:(NSString *)filePath;

@end
