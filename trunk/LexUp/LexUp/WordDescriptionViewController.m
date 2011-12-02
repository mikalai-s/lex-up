//
//  WordDescriptionViewController.m
//  LexUp
//
//  Created by user on 11-01-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WordDescriptionViewController.h"
#import "lexcore.h"
#import "global.h"
#import "SqliteConnection.h"


@implementation WordDescriptionViewController

- (id) initWithWord: (NSString*) word
{
    self = [super init];
    if(self)
    {
        _word = word;        
    }
    return self;
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

- (NSString*) translateToHTML: (lex_cards*)cards
{
    NSMutableString* dictionariesHtml = [[NSMutableString alloc] init];
    
    NSError* error;

    for(int i = 0; i < cards->count; i ++)
    {      
        NSMutableString* card = [NSMutableString stringWithUTF8String:cards->items[i]->card];      
        NSMutableString* dictionaryTemplate = [[NSString stringWithContentsOfFile:[Global sharedInstance].dictionaryTemplateFileName encoding:NSUTF8StringEncoding error:&error] mutableCopy];
        [dictionaryTemplate replaceOccurrencesOfString:@"{0}" withString:[NSString stringWithUTF8String:cards->items[i]->dictionary->name] options:NSLiteralSearch range:NSMakeRange(0, [dictionaryTemplate length])];
        [dictionaryTemplate replaceOccurrencesOfString:@"{1}" withString:[NSString stringWithUTF8String:cards->word->word] options:NSLiteralSearch range:NSMakeRange(0, [dictionaryTemplate length])];
        [dictionaryTemplate replaceOccurrencesOfString:@"{2}" withString:card options:NSLiteralSearch range:NSMakeRange(0, [dictionaryTemplate length])];
      
        [dictionariesHtml appendString:dictionaryTemplate];
        
        [dictionaryTemplate release];
    }
    
    
    NSMutableString* cardTemplate = [[NSString stringWithContentsOfFile:[Global sharedInstance].cardTemplateFileName encoding:NSUTF8StringEncoding error:&error] mutableCopy];
    [cardTemplate replaceOccurrencesOfString:@"{0}" withString:dictionariesHtml options:NSLiteralSearch range:NSMakeRange(0, [cardTemplate length])];
    [cardTemplate writeToFile:@"/Volumes/VMware Shared Folders/IPhone on Windows7/output.html" atomically:YES encoding:NSUTF8StringEncoding error:&error];
   
    return cardTemplate;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     [self title:@"sdfg"];
     
     title = [NSString stringWithCString:_entry->word encoding:NSUTF8StringEncoding]];
     */
   
    self.title = _word;
   // NSMutableString* urlString = [NSMutableString stringWithString:@"http://"];
   // [urlString appendString:[word stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   // [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    
    
     //if(_entry)
    // {                             
     //    NSString *description = [NSString stringWithCString:_entry->description encoding:NSUTF8StringEncoding];

       //[description writeToFile:@"/Volumes/VMware Shared Folders/IPhone on Windows7/output.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
       // [self translateToHTML:&description];
     

     //   [_webView loadHTMLString:description baseURL:[NSURL URLWithString:@"about:blank"]];
     
     //NSString* word = @"word woo + something";
     
     //NSMutableString* urlString = [NSMutableString stringWithString:@"gap://"];
   //  [urlString appendString:[word stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     //[_webView loadHTMLString:nil baseURL:[NSURL URLWithString:urlString]];
   //  [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
     //}
    
    
    
    
    
    
    SqliteConnection *con = [[SqliteConnection alloc] init];
    lex_cards *cards = [con getCardsByWord:_word];
    
    if(cards == nil)
        return;
    NSString* description = [self translateToHTML:cards];
    
    //[description writeToFile:@"/Volumes/VMware Shared Folders/IPhone on Windows7/output.html" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [_webView loadHTMLString:description baseURL:[NSURL URLWithString:@""]];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* word = [[[request URL] host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(word == nil)
        return NO;
    
    //[webView stopLoading];
    
    SqliteConnection *con = [[SqliteConnection alloc] init];
    lex_cards *cards = [con getCardsByWord:word];
    
    if(cards == nil)
        return NO;
    
    //[webView setAlpha:0.0f];
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
   // [UIView beginAnimations:nil context:context];
   /// [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
   // [UIView setAnimationDuration:1.0];
   // [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:webView cache:YES];
   // [webView setTransform: setAlpha:1.0f];
//   [UIView commitAnimations];
    
    
    //NSString *description = [NSString stringWithCString:entry->description encoding:NSUTF8StringEncoding];
    //NSError *error;
    //[description writeToFile:@"/Volumes/VMware Shared Folders/IPhone on Windows7/output.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSString* description = [self translateToHTML:cards];
    
    //[description writeToFile:@"/Volumes/VMware Shared Folders/IPhone on Windows7/output.html" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [webView loadHTMLString:description baseURL:[NSURL URLWithString:@""]];
    
    WordDescriptionViewController *next = [[[WordDescriptionViewController alloc] initWithWord:word] autorelease];
    [self.navigationController pushViewController:next animated:YES];     
    return YES;
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
}


@end
