//
//  WordDescriptionViewController.h
//  LexUp
//
//  Created by user on 11-01-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lexcore.h"


@interface WordDescriptionViewController : UIViewController<UIWebViewDelegate> {
    lex_word* _entry;
    NSString * _word;
    IBOutlet UIWebView* _webView;
}

- (id) initWithEntry: (lex_word*) entry;

@end
