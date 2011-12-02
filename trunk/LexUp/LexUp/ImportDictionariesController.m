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
#import "Global.h"
#import "DictionaryConfigController.h"
#import "EntitiesConverter.h"

@implementation ImportDictionariesController



- (id)initWithBackView:(DictionaryConfigController *)backController
{
    DLog();
    
    self = [super init];
    if (self) {
        _backController = backController;
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
    DLog();
    
    return 1;
}

- (NSInteger) tableView: (UITableView*)aTableView numberOfRowsInSection: (NSInteger)section
{
    DLog();
    
    return dictionary.count;
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
    
    NSArray *keys = [dictionary allKeys];
    
    NSString *id = [keys objectAtIndex:indexPath.row];        
    cell.textLabel.text = [dictionary objectForKey:id];
    
    return cell;
}

- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    DLog();
    
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
    DLog();
    
    [Global sharedInstance].JustImportedDictionary = true;
    
    TBXML *tbxml = [[TBXML alloc] initWithXMLFile:filePath];
    
    NSString *name = [TBXML valueOfAttributeNamed:@"n" forElement:tbxml.rootXMLElement];
    NSString *indexLanguage = [TBXML valueOfAttributeNamed:@"i" forElement:tbxml.rootXMLElement];
    NSString *contentLanguage = [TBXML valueOfAttributeNamed:@"c" forElement:tbxml.rootXMLElement];
    
    int ilId, clId;
    
    SqliteConnection *con = [[SqliteConnection alloc] init];
    int dictionaryId = [con importDictionary:name indexLanguage:indexLanguage contentLanguage:contentLanguage indexLanguageId:&ilId contentLanguageId:&clId];
    
    EntitiesConverter *converter = [[EntitiesConverter alloc] init];
    
    TBXMLElement *entry = tbxml.rootXMLElement->firstChild;
    while(entry != 0)
    {
        TBXMLElement *wordElement = entry->firstChild;
        NSString* word = [converter convertEntiesInString:[TBXML textForElement:wordElement]];

        TBXMLElement *cardElement = wordElement->nextSibling;
        NSString* card = [converter convertEntiesInString:[TBXML textForElement:cardElement]];

        [con importCard:card forWord:word intoDictionary:dictionaryId indexLanguageId:ilId contentLanguageId:clId];
        
        entry = entry->nextSibling;
    }
    
    [tbxml release];
    
    [_backController reloadView];
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    DLog();
    
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
    DLog();
    
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
    DLog();

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
