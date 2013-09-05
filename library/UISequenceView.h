//
//  TurnPhoto.h
//  KUKA
//
//  Created by liangfei zhou on 12-2-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UISequenceView;
@protocol UISequenceViewDelegate <NSObject>
@optional
-(void)playToFinish:(UISequenceView*)sequenceView;
@end

//**************************************************************
@interface UISequenceViewCell : UIView
@property(nonatomic,retain) NSString *path;
@property(nonatomic,readonly) UIImageView *imageView;
-(UIImage*)cacheAtFrame:(uint)frame image:(UIImage*)image;
-(UIImage*)cacheAtFrame:(uint)frame;
-(void)clearCache;
@end

//**************************************************************
@interface UISequenceView : UIView
@property(nonatomic,assign) BOOL loop;
@property(nonatomic,assign) NSInteger totalFrame;
@property(nonatomic,assign) NSInteger currentFrame;
@property(nonatomic,readonly) UIView *pointLayer;
@property(nonatomic,assign) id <UISequenceViewDelegate> delegate;

-(id)childAtIndex:(uint)index;
-(void)addPoint:(UIView*)point u:(NSString*)u v:(NSString*)v;
-(void)playTo:(int)value;
@end
