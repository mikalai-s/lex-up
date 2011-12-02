//
//  DictionaryConfigController.m
//  LexUp
//
//  Created by Mikalai on 11-11-29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DictionaryConfigController.h"
#import "ImportDictionariesController.h"
#import "Global.h"
#import "SqliteConnection.h"
#import "LexDictionary.h"

@implementation DictionaryConfigController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

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

- (void) clearDictionaries
{
    DLog();
    
    [_groupedDictionaries release];
    
    lex_free_dictionaries(&_dictionaries);
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{   
    DLog();
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.allowsSelection = NO;
    
    [self loadDictionaries];


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}
- (void)dealloc {
    [self clearDictionaries];
    [super dealloc];
}


@end
