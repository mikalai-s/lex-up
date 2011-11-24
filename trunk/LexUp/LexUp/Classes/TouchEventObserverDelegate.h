//
//  TouchEventObserverDelegate.h
//  LexUp
//
//  Created by user on 11-01-12.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TouchEventObserverDelegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view;

@end
