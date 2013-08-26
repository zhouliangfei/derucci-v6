//
//  FlowCoverView.m
//  FlowCoverView
//
//  Created by mac on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIPerspectView.h"
#import <QuartzCore/QuartzCore.h>
//..........................................UIFlipViewCell......................................
@implementation UIPerspectViewCell
@synthesize reuseIdentifier = identifier;
@synthesize angle;
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
@interface UIPerspectView (){
    NSMutableDictionary *visiableCells; 
    NSMutableArray *reusableTableCells;
    int numberCell;
}
@end

@implementation UIPerspectView
@synthesize dataSource;
@synthesize visibles;
@synthesize marginTop;
@synthesize angle;
@dynamic delegate;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        angle = -20;
        visibles = 3;
        visiableCells = [[NSMutableDictionary alloc] init];
        reusableTableCells = [[NSMutableArray alloc] init];
        [self setAlwaysBounceVertical:YES];
    }
    return self;
}
-(void)dealloc{
    [reusableTableCells release];
    [visiableCells release];
    [super dealloc];
}
-(void)reloadData{
    for (UIView *layer in [visiableCells allValues]){
        [layer removeFromSuperview];
    }
    
    for (UIView *layer in reusableTableCells){
        [layer removeFromSuperview];
    }
    
    numberCell = 0;
    [visiableCells removeAllObjects];
    [reusableTableCells removeAllObjects];
    
    [self layoutSubviews];
}
-(void)layoutSubviews{
    if (numberCell==0) {
        numberCell = [dataSource numberOfCellInPerspectView:self];
        [self setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height+(numberCell-1)*self.bounds.size.height)];
    }
    if (numberCell > 0) {
        int min = roundf(self.contentOffset.y / self.bounds.size.height);
        int max = min + visibles;
        NSMutableSet *visibleIndices = [NSMutableSet set];
        for (int j=min-1;j<max;j++){
            [visibleIndices addObject:[NSNumber numberWithInt:j]];
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
            UIPerspectViewCell *cell = [visiableCells objectForKey:key];
            if (cell == nil){
                int absKey = [key intValue];
                while (absKey < 0) {
                    absKey += numberCell;
                }
                cell = [dataSource perspectView:self cellAtIndex:absKey%numberCell];
                if (cell){
                    if (self != cell.superview) {
                        [self addSubview:cell];
                    }
                    [visiableCells setObject:cell forKey:key];
                    [reusableTableCells removeObject:cell];
                    if ([self.delegate respondsToSelector:@selector(perspectView:sizeAtIndex:)]) {
                        CGSize size = [self.delegate perspectView:self sizeAtIndex:absKey%numberCell];
                        [cell setFrame:CGRectMake(0, 0, size.width, size.height)];
                    }
                }
            }
            if (cell) {
                CGFloat curOffset = [key intValue]*self.bounds.size.height-self.contentOffset.y;
                if (curOffset < 0) {
                    [cell setAlpha:1.0+curOffset/self.bounds.size.height];
                }else {
                    [cell setAlpha:1.0-curOffset/(self.bounds.size.height*(visibles-0.5))];
                }
                
                [cell setCenter:CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5+marginTop+self.contentOffset.y)];
                [cell.layer setTransform:[self makeTransformWithAngle:cell.angle positionZ:curOffset]];
            }
        }
        //
        NSArray *sort = [[visibleIndices allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2){   
            return [obj1 compare:obj2];
        }];
        for (id val in sort) {
            UIView *cell = [visiableCells objectForKey:val];
            if (cell) {
                [self insertSubview:cell atIndex:0];
            }
        }
    }
}
-(UIPerspectViewCell*)dequeueReusableCellWithIdentifier:(NSString*)value{
    for (UIPerspectViewCell *cell in reusableTableCells){
        if ([value isEqualToString:cell.reuseIdentifier]){
            return cell;
        }
    }
    return nil;
}
-(NSInteger)indexForCell:(UIPerspectViewCell*)cell{
    for (NSNumber *key in [visiableCells allKeys]){
        if ([visiableCells objectForKey:key]==cell){
            return [key integerValue];
        }
    }
    return NSNotFound;
}
//
-(CATransform3D)makeTransformWithAngle:(float)value positionZ:(float)positionZ{
    CGFloat sa = (value-angle) * M_PI / 180.0;
    CGFloat wa = angle * M_PI / 180.0;
    
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f / 1200.f;
    
    CATransform3D srv = CATransform3DMakeRotation(sa, 1.0f, 0.0f, 0.0f);
	CATransform3D wtv = CATransform3DConcat(srv,CATransform3DMakeTranslation(0, 0, -positionZ));
    CATransform3D wrv = CATransform3DConcat(wtv,CATransform3DMakeRotation(wa, 1.0f, 0.0f, 0.0f));
    return CATransform3DConcat(wrv,scale);
}
@end
