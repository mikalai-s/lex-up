//
//  DictionariesSelectorController.m
//  LexUp
//
//  Created by user on 11-01-18.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import "DictionariesSelectorController.h"
#import "ImportDictionariesController.h"
#import "Global.h"
#import "SqliteConnection.h"
#import "LexDictionary.h"


@implementation DictionariesSelectorController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    DLog();
    
    return [_groupedDictionaries count] + 1 /* import row */;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog();
    
    // if it's import row
    if(section == 0)
        return 1;
    
    // if it's not import row
    NSArray *dics = [_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:(section - 1)]];
    return [dics count];
}

- (UITableViewCell*)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DLog();
    
    UITableViewCell* cell;
    
    if(indexPath.section > 0)
    {
        cell = [tView dequeueReusableCellWithIdentifier:@"dictionaryCell"];
        if(!cell)
        {        
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dictionaryCell"] autorelease];
            
            CGRect rect = CGRectMake(220, 8, 1, 1);
            UISwitch* switch1 = [[[UISwitch alloc] initWithFrame:rect] autorelease];
            [switch1 addTarget:self action:@selector(dictionaryEnabled:) forControlEvents:UIControlEventValueChanged];
            switch1.transform = CGAffineTransformMakeScale(0.7, 0.7);
            [switch1 setTag:13];
            
            [cell addSubview:switch1];
        }
        
        LexDictionary *dic = [[_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:(indexPath.section - 1)]] objectAtIndex:indexPath.row];
        
        NSString* name = [NSString stringWithUTF8String:[dic get]->name];
        cell.textLabel.text = name;
        
        UISwitch* sw = (UISwitch*)[cell viewWithTag:13];
        BOOL on = [dic get]->enabled;
        [sw setOn:on];
    }
    else
    {
        cell = [tView dequeueReusableCellWithIdentifier:@"importCell"];
        if(!cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"importCell"] autorelease];
            cell.textLabel.text = @"Import more dictionaries";
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
    }
    
    return cell;
}

-(void)dictionaryEnabled:(id)sender
{
    DLog();
    
    UISwitch* sw = (UISwitch*)sender;
    UITableViewCell*cell = (UITableViewCell*)sw.superview;
    NSIndexPath* cellPath = [self.tableView indexPathForCell:cell];
    
    LexDictionary *dicW = [[_groupedDictionaries objectForKey:[[_groupedDictionaries allKeys] objectAtIndex:(cellPath.section - 1)]] objectAtIndex:cellPath.row];
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

- (void) loadDictionaries
{
    DLog();
    
    SqliteConnection *con = [[SqliteConnection alloc] init];
    _dictionaries = [con getDictionaries];
    [con release];
    
    if(_dictionaries == 0)
        return;
    
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

- (void) clearDictionaries
{
    DLog();
    
    [_groupedDictionaries release];
    
    lex_free_dictionaries(&_dictionaries);
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    DLog();
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.allowsSelection = NO;
    
    [self loadDictionaries];
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
 {
     DLog();
     
     if(indexPath.section == 0)
     {
         ImportDictionariesController* crl = [[ImportDictionariesController alloc] initWithBackView:self];
         [self.navigationController pushViewController:crl animated:YES];
 
         [crl release];
     }
 }

- (void)reloadView
{
    DLog();
    
    [self clearDictionaries];
    [self loadDictionaries];
    [self.tableView reloadData];
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
    
    [self clearDictionaries];    
}


@end
