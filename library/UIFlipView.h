//
//  FlowCoverView.h
//  FlowCoverView
//
//  Created by mac on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIFlipView;
@class UIFlipViewCell;

//............................................
@protocol UIFlipViewDataSource<NSObject>
@required
-(NSInteger)numberOfCellInFlipView:(UIFlipView *)flipView;
-(UIFlipViewCell*)flipView:(UIFlipView *)flipView cellAtIndex:(NSInteger)index;
@end

@protocol UIFlipViewDelegate<NSObject,UIScrollViewDelegate>
@optional
-(CGFloat)flipView:(UIFlipView *)flipView sizeAtIndex:(NSInteger)index;
-(CGPoint)contentOffsetInFlipView:(UIFlipView *)flipView;
@end

//............................................
@interface UIFlipViewCell : UIControl
@property(nonatomic,readonly) NSString *reuseIdentifier;
-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;
@end

//............................................
enum {
    UIFlipOrientationLandscape,
    UIFlipOrientationPortrait
};
typedef NSInteger UIFlipOrientation;

@interface UIFlipView : UIScrollView
@property(nonatomic,assign) id <UIFlipViewDataSource> dataSource;
@property(nonatomic,assign) id <UIFlipViewDelegate> delegate;
@property(nonatomic,assign) UIFlipOrientation orientation;
@property(nonatomic,assign) UIColor *separatorColor;
@property(nonatomic,assign) CGFloat clearance;

-(UIFlipViewCell*)dequeueReusableCellWithIdentifier:(NSString*)value;
-(UIFlipViewCell*)cellForIndex:(NSInteger)index;
-(NSInteger)indexForCell:(UIFlipViewCell*)cell;
-(void)reloadData;
@end
