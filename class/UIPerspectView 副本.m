//
//  FlowCoverView.m
//  FlowCoverView
//
//  Created by mac on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UIPerspectView.h"
#import <QuartzCore/QuartzCore.h>
//透视效果
CATransform3D CATransform3DMakePerspective(CGPoint center, float positionZ){
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f / positionZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ){
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

//..........................................UIFlipViewCell......................................
@implementation UIPerspectViewCell
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
@interface UIPerspectView (){
    NSMutableDictionary *visiableCells; 
    NSMutableArray *reusableTableCells;
    //
    int numberCell;
    float offset;
    float angle;
}

@end

@implementation UIPerspectView
@synthesize dataSource;
@synthesize clearance;
@synthesize delegate;
@synthesize visibles;
@synthesize marginTop;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        angle = -25;
        visibles = 3;
        visiableCells = [[NSMutableDictionary alloc] init];
        reusableTableCells = [[NSMutableArray alloc] init];
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
        [self setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height+(numberCell-1)*clearance)];
    }
    
    if (numberCell > 0) {
        int min = roundf(offset / clearance);
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
        //修正
        /*float temp = self.contentOffset.y;
        if (self.decelerating) {
            if (abs(offset+temp)<20.0) {
                int ind = MAX(0,MIN(roundf(temp/clearance),numberCell));
                [self setContentOffset:CGPointMake(self.contentOffset.x, ind * clearance) animated:YES];
            }else {
               offset = temp;
            }
        }else {
            offset = temp;
        }*/
        offset = self.contentOffset.y;
        //
        for (NSNumber *key in visibleIndices){
            UIView *cell = [visiableCells objectForKey:key];
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
                    if ([delegate respondsToSelector:@selector(perspectView:sizeAtIndex:)]) {
                        CGSize size = [delegate perspectView:self sizeAtIndex:absKey%numberCell];
                        [cell setFrame:CGRectMake(0, 0, size.width, size.height)];
                    }
                }
            }
            if (cell) {
                [cell setCenter:CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5+marginTop+self.contentOffset.y)];
                
                CGFloat curOffset = [key intValue]*clearance-offset;
                if (curOffset < 0) {
                    float ratio = curOffset/clearance;
                    [cell setAlpha:1.0+ratio];
                    [cell.layer setTransform:[self makeTransformWithAngle:angle+(90.0+angle)*ratio positionZ:curOffset]];
                }else {
                    [cell setAlpha:1.0-curOffset/(clearance*visibles)];
                    [cell.layer setTransform:[self makeTransformWithAngle:angle positionZ:curOffset]];
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
    CGFloat ang = value * M_PI / 180.0;
	CATransform3D rot = CATransform3DMakeTranslation(0, 0, -positionZ);
    CATransform3D tra = CATransform3DConcat(rot,CATransform3DMakeRotation(ang, 1.0f, 0.0f, 0.0f));
    return CATransform3DPerspect(tra,CGPointMake(0, 0),1200);
}
@end
