//
//  TurnPhoto.m
//  KUKA
//
//  Created by liangfei zhou on 12-2-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "GUI.h"
#import "UISequenceView.h"
#import <QuartzCore/QuartzCore.h>

//**************************************************************
@interface UISequenceViewCell(){
    NSMutableDictionary *frameCache;
}
@property(nonatomic,retain) NSString *file;
@end
//
@implementation UISequenceViewCell
@synthesize imageView;
@synthesize path;
@synthesize file;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        frameCache = [[NSMutableDictionary alloc] init];
        //
        imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:imageView];
    }
    return self;
}
-(void)dealloc{
    [file release];
    [path release];
    [imageView release];
    [frameCache release];
    [super dealloc];
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [imageView setFrame:self.bounds];
}
-(UIImage*)cacheAtFrame:(uint)frame image:(UIImage*)image{
    id key = [NSNumber numberWithInt:frame];
    UIImageView *tempImage = [frameCache objectForKey:key];
    if (nil == tempImage) {
        tempImage = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
        [tempImage setHidden:YES];
        [self addSubview:tempImage];
        [frameCache setObject:tempImage forKey:key];
    }
    if (image) {
        [tempImage setImage:image];
    }
    [self setFile:nil];
    return [tempImage image];
}
-(UIImage*)cacheAtFrame:(uint)frame{
    return [self cacheAtFrame:frame image:nil];
}
-(void)clearCache{
    for (UIView *view in [frameCache allValues]) {
        [view removeFromSuperview];
    }
    [self setPath:nil];
    [self setFile:nil];
    [imageView setImage:nil];
    [frameCache removeAllObjects];
}
@end

//**************************************************************
@interface UISequenceView(){
    BOOL isTouche;
    NSMutableArray *pointData;
    //
    int playSteep;
    int playEndFrame;
    int playBeginFrame;
    int playCurrentFrame;
}
@end

@implementation UISequenceView
@synthesize currentFrame;
@synthesize totalFrame;
@synthesize pointLayer;
@synthesize delegate;
@synthesize loop;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        totalFrame = 1;
        pointData = [[NSMutableArray alloc] init];
        pointLayer = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:pointLayer];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        totalFrame = 1;
        pointData = [[NSMutableArray alloc] init];
        pointLayer = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:pointLayer];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    for (UIView *view in self.subviews){
        if (view==pointLayer || [view isKindOfClass:[UISequenceViewCell class]]){
            [view setFrame:self.bounds];
        }
    }
}

-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [pointData release];
    [pointLayer release];
    [super dealloc];
}
//动画
-(void)playTo:(int)value{
    if(totalFrame > 0){
        playEndFrame = value % totalFrame;
        playBeginFrame = self.currentFrame;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        //
        if (self.totalFrame>1 && playEndFrame != playBeginFrame) {
            if (self.loop) {
                if (abs(playEndFrame-playBeginFrame)*2 > self.totalFrame) {
                    if (playEndFrame > playBeginFrame) {
                        playEndFrame -= self.totalFrame;
                    }else {
                        playEndFrame += self.totalFrame;
                    }
                }
            }
            playSteep = (playEndFrame > playBeginFrame ? 1 : -1);
            [self playTimerInterval];
        }else {
            [delegate playToFinish:self];
        }
    }
}

-(void)playTimerInterval{
    playBeginFrame += playSteep;
    self.currentFrame = playBeginFrame;
    
    if (playBeginFrame!=playEndFrame){
        isTouche=YES;
        [self performSelector:@selector(playTimerInterval) withObject:nil afterDelay:0.024];
    }else {
        isTouche=NO;
        [delegate playToFinish:self];
    }
    [self layoutSubviews];
}
//
-(void)addPoint:(UIView*)point u:(NSString*)u v:(NSString*)v{
    NSArray *tu = [u componentsSeparatedByString:@","];
    NSArray *tv = [v componentsSeparatedByString:@","];
    [pointData addObject:[NSArray arrayWithObjects:point,tu,tv, nil]];
    [pointLayer addSubview:point];

    float tw = self.frame.size.width;
    float th = self.frame.size.height;
    id tx = [tu objectAtIndex:currentFrame];
    id ty = [tv objectAtIndex:currentFrame];
    if ([tx isEqualToString:@"NaN"] || [ty isEqualToString:@"NaN"]){
        [point setHidden:YES];
    }else {
        [point setHidden:NO];
        [point setCenter:CGPointMake([tx floatValue] * tw,[ty floatValue] * th)];
    }
}

-(id)childAtIndex:(uint)index{
    if (index>0) {
        UISequenceViewCell *layerObj = (UISequenceViewCell*)[self viewWithTag:index];
        if (nil == layerObj) {
            layerObj = [[[UISequenceViewCell alloc] initWithFrame:self.bounds] autorelease];
            [layerObj setTag:index];
        }else{
            [layerObj setFrame:self.bounds];
        }
        [layerObj setUserInteractionEnabled:NO];
        [self insertSubview:layerObj atIndex:index];
        return layerObj;
    }
    return nil;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //
    if (!pointLayer.hidden) {
        float tw = self.frame.size.width;
        float th = self.frame.size.height;
        for (NSArray *temp in pointData){
            UIView *point = [temp objectAtIndex:0];
            NSArray *localX = [temp objectAtIndex:1];
            NSArray *localY = [temp objectAtIndex:2];
            id tx = [localX objectAtIndex:currentFrame];
            id ty = [localY objectAtIndex:currentFrame];
            if ([tx isEqualToString:@"NaN"] || [ty isEqualToString:@"NaN"]){
                [point setHidden:YES];
            }else{
                [point setHidden:NO];
                [point setCenter:CGPointMake([tx floatValue] * tw,[ty floatValue] * th)];
            }
        }
    }
    //
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UISequenceViewCell class]]){
            UISequenceViewCell *layerObj = (UISequenceViewCell*)view;
            if (isTouche){
                [layerObj.imageView setImage:[layerObj cacheAtFrame:currentFrame]];
            }else{
                if (layerObj.path){
                    NSString *path = [NSString stringWithFormat:layerObj.path,currentFrame];
                    if (![path isEqualToString:layerObj.file]){
                        [layerObj.layer addAnimation:[CATransition animation] forKey:nil];
                        [layerObj.imageView setImage:[UIImage imageWithContentsOfFile:path]];
                        [layerObj setFile:path];
                    }
                }
            }
        }
    }
}
-(void)setCurrentFrame:(int)value{
    if (totalFrame > 0){
        if (loop) {
            currentFrame = value % totalFrame;
            if (currentFrame < 0) currentFrame += totalFrame;
        }else{
            currentFrame = fmax(fmin(value,totalFrame-1),0); 
        }
    }
}
//拖动事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    isTouche = YES;
    [self.pointLayer setHidden:isTouche];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint pre = [touch locationInView:self];
    CGPoint nex = [touch previousLocationInView:self];
    int mx = pre.x-nex.x;
    int my = pre.y-nex.y;
    if (mx!=0 && mx*mx>my*my){
        if (mx>0) {
            self.currentFrame++;
        }else {
            self.currentFrame--;
        }
        [self layoutSubviews];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    isTouche = NO;
    [self.pointLayer setHidden:isTouche];
    [self layoutSubviews];
}
@end
