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
#import "SSZipArchive.h"
#import "SqliteConnection.h"

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
    NSString *guid = [[dictionary allKeys] objectAtIndex:indexPath.row];
    
    NSString *urlString = [NSString stringWithFormat:@"http://lexup.msilivonik.com/Download.aspx?guid=%@", guid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *tempFolder = NSTemporaryDirectory();
    NSString *downloadPath = [tempFolder stringByAppendingPathComponent:@"dic.zip"];
   
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:downloadPath];
    [request startSynchronous];
    
    if([request responseStatusCode] == 200)
    {
        tempFolder = [tempFolder stringByAppendingPathComponent:@"Zip"];
        
        [SSZipArchive unzipFileAtPath:downloadPath toDestination:tempFolder];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempFolder error:nil];
        for(int i = 0; i < files.count; i ++)
        {
            NSString *xmlFile = (NSString*)[files objectAtIndex:i];
            [self importDictionary:[tempFolder stringByAppendingPathComponent:xmlFile]];
        }
        
        // delete files
        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:tempFolder error:nil];
    }    
}

- (void) importDictionary:(NSString *)filePath
{
    TBXML *tbxml = [[TBXML alloc] initWithXMLFile:filePath];
  //  NSString *dictionaryElement = tbxml.rootXMLElement->firstChild->text;    
    NSString *name = [TBXML valueOfAttributeNamed:@"name" forElement:tbxml.rootXMLElement];
    NSString *indexLanguage = [TBXML valueOfAttributeNamed:@"indexLanguage" forElement:tbxml.rootXMLElement];
    NSString *contentLanguage = [TBXML valueOfAttributeNamed:@"contentLanguage" forElement:tbxml.rootXMLElement];
    
    SqliteConnection *con = [[SqliteConnection alloc] init];
    [con importDictionary:name indexLanguage:indexLanguage contentLanguage:contentLanguage];
    
    [tbxml release];
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
