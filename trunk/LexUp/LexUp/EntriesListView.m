//
//  EntriesListView.m
//  LexUp
//
//  Created by user on 11-01-12.
//  Copyright 2011 nexuzzz. All rights reserved.
//

#import "EntriesListView.h"
#import "Global.h"


@implementation EntriesListView


- (NSMutableArray*)get_touchEventObservers
{
    DLog();
    
    if(!_touchEventObservers)
        _touchEventObservers = [[NSMutableArray alloc] init];
    return _touchEventObservers;
}

- (void) addTouchEventObserver:(NSObject<TouchEventObserverDelegate>*)target
{
    DLog();
    
    NSMutableArray* observers = [self get_touchEventObservers];
    if(![observers containsObject:target])
        [observers addObject:target];
}

- (void) removeTouchEventObserver:(NSObject<TouchEventObserverDelegate>*)target
{
    DLog();
    
    NSMutableArray* observers = [self get_touchEventObservers];
    if([observers containsObject:target])
        [observers removeObject:target];
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    DLog();
    
    [super touchesShouldBegin:touches withEvent:event inContentView:view];
    
    NSMutableArray* observers = [self get_touchEventObservers];
    for(NSObject<TouchEventObserverDelegate>* observer in observers)
        [observer touchesBegan:touches withEvent:event inContentView:view];
    return YES;
}
/*

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{    
    NSMutableArray* observers = [self get_touchEventObservers];
    for(NSObject<TouchEventObserverDelegate>* observer in observers)
        [observer touchesBegan:touches withEvent:event inContentView:nil];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableArray* observers = [self get_touchEventObservers];
    for(NSObject<TouchEventObserverDelegate>* observer in observers)
        [observer touchesBegan:touches withEvent:event inContentView:nil];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [_touchEventObservers release];
    [super dealloc];
}


@end
