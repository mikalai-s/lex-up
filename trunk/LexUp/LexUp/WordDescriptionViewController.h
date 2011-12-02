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
    NSString * _word;
    IBOutlet UIWebView* _webView;
}

- (id) initWithWord: (NSString*) word;

@end
