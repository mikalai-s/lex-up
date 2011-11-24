//
//  LexUpAppDelegate.h
//  LexUp
//
//  Created by user on 11-01-04.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LexUpViewController;

@interface LexUpAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    LexUpViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet LexUpViewController *viewController;

@end

