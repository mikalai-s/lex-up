//
//  EntriesListView.h
//  LexUp
//
//  Created by user on 11-01-12.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchEventObserverDelegate.h"


@interface EntriesListView : UITableView {
    NSMutableArray* _touchEventObservers;
}

- (void) addTouchEventObserver:(NSObject<TouchEventObserverDelegate>*)target;

- (void) removeTouchEventObserver:(NSObject<TouchEventObserverDelegate>*)target;

@end
