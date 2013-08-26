//
//  FlowCoverView.m
//  FlowCoverView
//
//  Created by mac on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIFlipView.h"
#import <QuartzCore/QuartzCore.h>

//..........................................UIFlipViewCell......................................
@implementation UIFlipViewCell
@synthesize reuseIdentifier = identifier;
-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        identifier = [reuseIdentifier retain];
    }
    return self;
}
-(void)dealloc{
    [identifier release];
    [super dealloc];
}
@end

//............................................UIGalleryView......................................
@interface UIFlipView (){
    NSMutableDictionary *visiableCells; 
    NSMutableArray *reusableTableCells;
    NSMutableArray *position;
    float offset;
}
@end

@implementation UIFlipView
@synthesize dataSource;
@synthesize orientation;
@synthesize clearance;
@synthesize separatorColor;
@dynamic delegate;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        position = [[NSMutableArray alloc] init];
        visiableCells = [[NSMutableDictionary alloc] init];
        reusableTableCells = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc{
    [reusableTableCells release];
    [visiableCells release];
    [position release];
    [super dealloc];
}
-(void)reloadData{
    for (UIView *layer in self.subviews){
        [layer removeFromSuperview];
    }
    [position removeAllObjects];
    [visiableCells removeAllObjects];
    [reusableTableCells removeAllObjects];
    [self layoutSubviews];
}
-(void)layoutSubviews{
    if (position.count==0) {
        offset = 0.0;
        CGFloat origin = 0.0;
        Boolean dynamic = [self.delegate respondsToSelector:@selector(flipView:sizeAtIndex:)];
        CGFloat absWidth = self.bounds.size.width-self.contentInset.left-self.contentInset.right;
        CGFloat absHeight = self.bounds.size.height-self.contentInset.top-self.contentInset.bottom;
        //
        CGRect frame;
        NSInteger count = [dataSource numberOfCellInFlipView:self];
        for (NSInteger j=0; j<count; j++){
            if (j > 0){
                offset += clearance;
            }
            if (UIFlipOrientationLandscape == orientation) {
                if (dynamic) {
                    frame = CGRectMake(origin+offset, 0.0, [self.delegate flipView:self sizeAtIndex:j], absHeight);
                }else {
                    frame = CGRectMake(origin+offset, 0.0, absWidth, absHeight);
                }
                origin += frame.size.width;
                //分割线
                if (separatorColor && j<count-1) {
                    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(origin+offset+clearance/2.0, 0, 1, self.bounds.size.height)];
                    [separator setBackgroundColor:separatorColor];
                    [self addSubview:separator];
                    [separator release];
                }
            }else {
                if (dynamic) {
                    frame = CGRectMake(0.0, origin+offset, absWidth, [self.delegate flipView:self sizeAtIndex:j]);
                }else {
                    frame = CGRectMake(0.0, origin+offset, absWidth, absHeight);
                }
                origin += frame.size.height;
                //分割线
                if (separatorColor && j<count-1) {
                    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, origin+offset+clearance/2.0, self.bounds.size.width, 1)];
                    [separator setBackgroundColor:separatorColor];
                    [self addSubview:separator];
                    [separator release];
                }
            }
            [position addObject:[NSValue valueWithCGRect:frame]];
        }
        //
        if (UIFlipOrientationLandscape == orientation) {
            [self setAlwaysBounceVertical:NO];
            [self setAlwaysBounceHorizontal:YES];
            [self setContentSize:CGSizeMake(origin+fmaxf(offset, 0.0), absHeight)];
        }else {
            [self setAlwaysBounceHorizontal:NO];
            [self setAlwaysBounceVertical:YES];
            [self setContentSize:CGSizeMake(absWidth, origin+fmaxf(offset, 0.0))];
        }
        if ([self.delegate respondsToSelector:@selector(contentOffsetInFlipView:)]) {
            [self setContentOffset:[self.delegate contentOffsetInFlipView:self]];
        }
        offset = fminf(offset, 0.0);
    }
    
    float allOffset = 0.0;
    if (position.count > 0) {
        if (UIFlipOrientationLandscape == orientation) {
            if (self.contentSize.width!=self.bounds.size.width) {
                allOffset = offset*self.contentOffset.x/(self.contentSize.width-self.bounds.size.width);
            }
        }else {
            if (self.contentSize.height-self.bounds.size.height) {
                allOffset = offset*self.contentOffset.y/(self.contentSize.height-self.bounds.size.height);
            }
        }
        //
        NSMutableSet *visibleIndices = [NSMutableSet set];
        for (int j=0;j<[position count];j++){
            CGRect frame = [[position objectAtIndex:j] CGRectValue];
            if (UIFlipOrientationLandscape == orientation) {
                frame.origin.x -= allOffset;
            }else {
                frame.origin.y -= allOffset;
            }
            if ((CGRectContainsRect(frame, self.bounds) || CGRectIntersectsRect(frame, self.bounds))){
                [visibleIndices addObject:[NSNumber numberWithInteger:j]];
            }
        }
        //
        for (NSNumber *key in [visiableCells allKeys]){
            if (NO == [visibleIndices containsObject:key]){
                UIView *cell = [visiableCells objectForKey:key];
                [reusableTableCells addObject:cell];
                [visiableCells removeObjectForKey:key];
                if (self == cell.superview) {
                    [cell removeFromSuperview];
                }
            }
        }
        //
        for (NSNumber *key in visibleIndices){
            UIView *cell = [visiableCells objectForKey:key];
            if (cell == nil){
                cell = [dataSource flipView:self cellAtIndex:[key intValue]];
                if (cell){
                    if (self != cell.superview) {
                        [self addSubview:cell];
                    }
                    [visiableCells setObject:cell forKey:key];
                    [reusableTableCells removeObject:cell];
                }
            }
            if (cell) {
                CGRect frame = [[position objectAtIndex:[key intValue]] CGRectValue];
                if (UIFlipOrientationLandscape == orientation) {
                    frame.origin.x -= allOffset;
                }else {
                    frame.origin.y -= allOffset;
                }
                [cell setFrame:frame];
            }
        }
    }
}
-(UIFlipViewCell*)dequeueReusableCellWithIdentifier:(NSString*)value{
    for (UIFlipViewCell *cell in reusableTableCells){
        if ([value isEqualToString:cell.reuseIdentifier]){
            return cell;
        }
    }
    return nil;
}
-(UIFlipViewCell*)cellForIndex:(NSInteger)index{
    for (NSNumber *key in [visiableCells allKeys]){
        if ([key intValue]==index){
            return [visiableCells objectForKey:key];
        }
    }
    return nil;
}
-(NSInteger)indexForCell:(UIFlipViewCell*)cell{
    for (NSNumber *key in [visiableCells allKeys]){
        if ([visiableCells objectForKey:key]==cell){
            return [key integerValue];
        }
    }
    return NSNotFound;
}
@end
