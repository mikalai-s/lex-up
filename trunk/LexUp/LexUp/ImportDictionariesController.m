//
//  ImportDictionariesController.m
//  LexUp
//
//  Created by Mikalai on 11-11-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImportDictionariesController.h"
#import "TBXML.h"
#import "ASIHTTPRequest.h"

@implementation ImportDictionariesController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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



- (NSInteger) numberOfSectionsInTableView:(UITableView*)aTableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView*)aTableView numberOfRowsInSection: (NSInteger)section
{
    return dictionary.count;
}

- (UITableViewCell*)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{       
    UITableViewCell* cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
    if(!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSArray *keys = [dictionary allKeys];
    
    NSString *id = [keys objectAtIndex:indexPath.row];        
    cell.textLabel.text = [dictionary objectForKey:id];
    
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *id = [[dictionary allKeys] objectAtIndex:indexPath.row];
    /*
    lex_words* candidates = [self get_candidates];
    if(candidates)
    {
        WordDescriptionViewController* view = [[WordDescriptionViewController alloc] initWithEntry:candidates->items[indexPath.row]];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
     */
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];   
    // Do any additional setup after loading the view from its nib.
    
    dictionary = [[NSMutableDictionary alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://lexup.msilivonik.com/webservice.svc/dictionaries"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    TBXML *tbxml = [[[TBXML alloc] initWithXMLString:responseString] autorelease];
    
   
    if(tbxml.rootXMLElement != nil)
    {                
        TBXMLElement *dictionaryElement = tbxml.rootXMLElement->firstChild;
        while(dictionaryElement != nil)
        {
            NSString *id = [[[NSString alloc] initWithUTF8String:dictionaryElement->firstChild->text] autorelease];
            NSString *name = [[[NSString alloc] initWithUTF8String:dictionaryElement->firstChild->nextSibling->text] autorelease];
            
            [dictionary setValue:name forKey:id];
            
            dictionaryElement = dictionaryElement->nextSibling;
        }
    }
    
    [dictionariesToImportTable reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
        [dictionary release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
