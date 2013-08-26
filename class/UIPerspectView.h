//
//  FlowCoverView.h
//  FlowCoverView
//
//  Created by mac on 13-1-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIPerspectView;
@class UIPerspectViewCell;

//............................................
@protocol UIPerspectViewDataSource<NSObject>
@required
-(NSInteger)numberOfCellInPerspectView:(UIPerspectView *)perspectView;
-(UIPerspectViewCell*)perspectView:(UIPerspectView *)perspectView cellAtIndex:(NSInteger)index;
@end

@protocol UIPerspectViewDelegate<NSObject,UIScrollViewDelegate>
@optional
-(CGSize)perspectView:(UIPerspectView *)perspectView sizeAtIndex:(NSInteger)index;
@end

//............................................
@interface UIPerspectViewCell : UIControl
@property(nonatomic,assign) CGFloat angle;
@property(nonatomic,readonly) NSString *reuseIdentifier;
-(id)initWithReuseIdentifier:(NSString*)reuseIdentifier;
@end

//............................................

@interface UIPerspectView : UIScrollView
@property(nonatomic,assign) id <UIPerspectViewDataSource> dataSource;
@property(nonatomic,assign) id <UIPerspectViewDelegate> delegate;
@property(nonatomic,assign) NSInteger visibles;
@property(nonatomic,assign) CGFloat angle;
@property(nonatomic,assign) CGFloat marginTop;

-(UIPerspectViewCell*)dequeueReusableCellWithIdentifier:(NSString*)value;
-(NSInteger)indexForCell:(UIPerspectViewCell*)cell;
-(void)reloadData;
@end
