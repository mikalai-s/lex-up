//
//  LexUpViewController.m
//  LexUp
//
//  Created by user on 11-01-04.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "LexUpViewController.h"
#import "lexcore.h"
#import "WordDescriptionViewController.h"
#import "global.h"
#import "SqliteConnection.h"

@implementation LexUpViewController
  

- (lex_words*) get_candidates
{
    DLog();
    
    if(_candidates == nil)
    {
        SqliteConnection *con = [[SqliteConnection alloc] init];
        _candidates = [con getWordList:[searchField text]];
        [con release];
     }
    return _candidates;
}

- (void) clear_candidates
{
    DLog();
    
    if(_candidates != nil)
        lex_free_words(&_candidates);
}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)aTableView
{
    DLog();
    
    return 1;
}

- (NSInteger) tableView: (UITableView*)aTableView numberOfRowsInSection: (NSInteger)section
{
    DLog();
    
    return [self get_candidates]->count;
}

- (UITableViewCell*)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DLog();
    
    UITableViewCell* cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
    if(!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    lex_words* candidates = [self get_candidates];
    if(candidates)
    {
        if(indexPath.row < candidates->count)
        {
            char* w = candidates->items[indexPath.row]->word;
            
            cell.textLabel.text = [NSString stringWithUTF8String:w];
        }
    }            

    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DLog();
    
    lex_words* candidates = [self get_candidates];
    if(candidates)
    {
        char *word = candidates->items[indexPath.row]->word;
        WordDescriptionViewController* view = [[WordDescriptionViewController alloc] initWithWord:[NSString stringWithUTF8String:word]];
        [self.navigationController pushViewController:view animated:YES];
        [view release];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    DLog();
    
    [self clear_candidates];
    [candidatesTable reloadData];
    
    if([candidatesTable numberOfRowsInSection:0] > 0)
        [candidatesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];   
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/









// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    DLog();
    
    [super viewDidLoad];
    
    CGRect r = CGRectMake(0.0f, 0.0f, 230.0f + 78.0f, 44.0f);
    UIView *v = [[[UIView alloc] initWithFrame:r] autorelease];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 308.0f, 44.0f);
    searchField = [[[UISearchBar alloc] initWithFrame:rect] autorelease];
    searchField.delegate = self;
    searchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
   
    [v addSubview:searchField];

    self.navigationItem.titleView = v;

    _candidates = nil;

    [candidatesTable addTouchEventObserver:self];
    
   // [searchField becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    DLog();
    
    [searchField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DLog();
    
    [searchField resignFirstResponder];
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [self clear_candidates];
       
    [super dealloc];
}

@end
