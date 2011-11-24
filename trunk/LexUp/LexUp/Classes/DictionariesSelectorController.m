//
//  DictionariesSelectorController.m
//  LexUp
//
//  Created by user on 11-01-18.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import "DictionariesSelectorController.h"
#import "Global.h"
#import "SqliteConnection.h"
#import "LexDictionary.h"


@implementation DictionariesSelectorController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_groupedDictionaries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *dics = [_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:section]];
    return [dics count];
}

- (UITableViewCell*)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
    if(!cell)
    {        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"] autorelease];
        
        CGRect rect = CGRectMake(220, 8, 1, 1);
        UISwitch* switch1 = [[[UISwitch alloc] initWithFrame:rect] autorelease];
        [switch1 addTarget:self action:@selector(dictionaryEnabled:) forControlEvents:UIControlEventValueChanged];
        switch1.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [switch1 setTag:13];
        
        [cell addSubview:switch1];
    }
    
    LexDictionary *dic = [[_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

    NSString* name = [NSString stringWithUTF8String:[dic get]->name];
    cell.textLabel.text = name;
    
    UISwitch* sw = (UISwitch*)[cell viewWithTag:13];
    BOOL on = [dic get]->enabled;
    [sw setOn:on];
    //[name release];
    
    return cell;
}

-(void)dictionaryEnabled:(id)sender
{
    UISwitch* sw = (UISwitch*)sender;
    UITableViewCell*cell = (UITableViewCell*)sw.superview;
    NSIndexPath* cellPath = [self.tableView indexPathForCell:cell];
    
    LexDictionary *dicW = [[_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:cellPath.section]] objectAtIndex:cellPath.row];
    lex_dictionary *dic = [dicW get];
    dic->enabled = sw.on;
    
    // store modifed dictionary
    SqliteConnection *con = [[SqliteConnection alloc] init];
    [con setDictionary:dic->id enabled:dic->enabled];
    [con release];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.allowsSelection = NO;

    SqliteConnection *con = [[SqliteConnection alloc] init];
    _dictionaries = [con getDictionaries];
    [con release];
    
    _groupedDictionaries = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < _dictionaries->count; i ++)
    {
        NSNumber *key =[NSNumber numberWithInt:_dictionaries->items[i]->wordLanguage->id];
        NSMutableArray *dics = [_groupedDictionaries objectForKey:key];
        if(dics == nil)
        {
            dics = [[NSMutableArray alloc] init];
            [_groupedDictionaries setObject:dics forKey:key];
        }
        
        bool contains = false;
        for(int j = 0; j < [dics count]; j++)
        {
            LexDictionary *dic = [dics objectAtIndex:j];
            if([dic get]->id == _dictionaries->items[i]->id)
            {
                contains = true;
                break;
            }
        }
        
        if(!contains)
            [dics addObject:[LexDictionary withValue:_dictionaries->items[i]]];
    }
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
    
    [_groupedDictionaries release];
    
    lex_free_dictionaries(&_dictionaries);
    
}


@end
