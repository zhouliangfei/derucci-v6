//
//  TurnPhoto.m
//  KUKA
//
//  Created by liangfei zhou on 12-2-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "UISequenceView.h"

@implementation UISequenceViewCell

@synthesize cache;

@synthesize path;

@synthesize file;

@synthesize index;

@dynamic image;

-(id)initWithIndex:(uint)value
{
    self = [super initWithFrame:CGRectZero];
    
    if (self) 
    {
        index = value;
        
        cache = [[NSMutableArray alloc] init];
        
        imageView = [[UIImageView alloc] init];
        
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self addSubview:imageView];
    }
    
    return self;
}

//
-(void)setImage:(UIImage *)image
{
    imageView.image = image;
}

//
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [imageView setFrame:self.bounds];
}

-(void)dealloc
{
    [file release];
    
    [path release];
    
    [cache release];
    
    [imageView release];

    [super dealloc];
}

@end

//
@interface UISequenceView()
{
    NSMutableArray *pointData;
    //
    int playSteep;
    int playEndFrame;
    int playBeginFrame;
    int playCurrentFrame;
}

- (void)displayPoint;

- (void)displayImage;

@end

//
#import <QuartzCore/QuartzCore.h>

@implementation UISequenceView
@synthesize currentFrame;
@synthesize totalFrame;
@synthesize layerCount;
@synthesize pointLayer;
@synthesize quality;
@synthesize delegate;
@synthesize loop;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) 
    {
        pointData = [[NSMutableArray alloc] init];
        
        pointLayer = [[UIView alloc] initWithFrame:self.bounds];
        
        [self addSubview:pointLayer];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) 
    {
        pointData = [[NSMutableArray alloc] init];
        
        pointLayer = [[UIView alloc] initWithFrame:self.bounds];
        
        [self addSubview:pointLayer];
    }
    
    return self;
}

-(void)setLayerCount:(NSInteger)value
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [pointData removeAllObjects];
    for (id item in pointLayer.subviews)
    {
        [item removeFromSuperview];
    }

    for (UISequenceViewCell *layerObj in self.subviews)
    {
        if ([layerObj isKindOfClass:[UISequenceViewCell class]])
        {
            [layerObj removeFromSuperview];
        }
    }
    
    loop = false;
    totalFrame = 0;
    currentFrame = 0;
    quality = UISequenceViewQualityHigh;
    
    layerCount = value;
    for (uint i=0; i<layerCount; i++){
        UISequenceViewCell *layerObj = [[UISequenceViewCell alloc] initWithIndex:i];
        [self insertSubview:layerObj atIndex:i];        
        [layerObj setFrame:self.bounds];        
        [layerObj release];
    }
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    for (UIView *view in self.subviews)
    {
        [view setFrame:self.bounds];
    }    
    [self displayPoint];
}

-(void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [pointData release];
    [pointLayer release];
    [super dealloc];
}
//
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
            [self setQuality:UISequenceViewQualityLow];
            [self playTimerInterval];
        }else {
            [delegate playToFinish:self];
        }
    }
}

-(void)playTimerInterval
{
    playBeginFrame += playSteep;
    self.currentFrame = playBeginFrame;
    
    if (playBeginFrame!=playEndFrame){
        [self performSelector:@selector(playTimerInterval) withObject:nil afterDelay:0.024];
    }else {
        [delegate playToFinish:self];
    }
}
//
-(void)addPoint:(UIView*)point u:(NSString*)u v:(NSString*)v
{
    NSArray *tu = [u componentsSeparatedByString:@","];
    
    NSArray *tv = [v componentsSeparatedByString:@","];

    [pointData addObject:[NSArray arrayWithObjects:point,tu,tv, nil]];
    
    [pointLayer addSubview:point];
    
    //
    float tw = self.frame.size.width;
    
    float th = self.frame.size.height;
    
    id tx = [tu objectAtIndex:currentFrame];
    
    id ty = [tv objectAtIndex:currentFrame];
    
    if ([tx isEqualToString:@"NaN"] || [ty isEqualToString:@"NaN"])
    {
        [point setHidden:YES];
    }
    else 
    {
        [point setHidden:NO];
        
        [point setCenter:CGPointMake([tx floatValue] * tw,[ty floatValue] * th)];
    }
}

-(void)updata:(int)layer low:(NSString *)low high:(NSString*)high;
{
    if (totalFrame > 0) {
        for (UISequenceViewCell *layerObj in self.subviews)
        {
            if ([layerObj isKindOfClass:[UISequenceViewCell class]] && layerObj.index == layer)
            {
                layerObj.file = nil;
                
                layerObj.path = high;
                
                [layerObj.cache removeAllObjects];
                
                if (low){
                    for (uint ind=0; ind<totalFrame; ind++) {
                        NSString *path = [NSString stringWithFormat:low,ind];
                        UIImage *image = [UIImage imageWithContentsOfFile:path];
                        
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                        [layerObj.cache addObject:imageView];
                        [imageView release];
                    }
                }
                
                [self.layer addAnimation:[CATransition animation] forKey:nil];
                [self displayImage];
                
                return;
            }
        }
    }
}

-(void)setCurrentFrame:(int)value
{
    if (totalFrame > 0)
    {
        if (loop) 
        {
            while (value < 0) 
            {
                value += totalFrame;
            }
            
            currentFrame = value % totalFrame;
        }
        else 
        {
            currentFrame = fmax(fmin(value,totalFrame-1),0); 
        }
        
        [self displayPoint];
        [self displayImage];
    }
}

-(void)setQuality:(UISequenceViewQuality)value
{
    if (totalFrame > 0)
    {
        quality = value;
        [self displayImage];
    }
}

-(void)displayPoint
{
    float tw = self.frame.size.width;
    
    float th = self.frame.size.height;
    
    for (NSArray *temp in pointData)
    {
        UIImageView *point = [temp objectAtIndex:0];
        
        NSArray *localX = [temp objectAtIndex:1];
        
        NSArray *localY = [temp objectAtIndex:2];
        
        id tx = [localX objectAtIndex:currentFrame];
        
        id ty = [localY objectAtIndex:currentFrame];
        
        if ([tx isEqualToString:@"NaN"] || [ty isEqualToString:@"NaN"])
        {
            [point setHidden:YES];
        }
        else 
        {
            [point setHidden:NO];
            
            [point setCenter:CGPointMake([tx floatValue] * tw,[ty floatValue] * th)];
        }
    }
}

-(void)displayImage
{
    for (UISequenceViewCell *layerObj in self.subviews)
    {
        if ([layerObj isKindOfClass:[UISequenceViewCell class]])
        {
            if (UISequenceViewQualityLow == quality)
            {
                if ([layerObj.cache count] > currentFrame)
                {
                    UIImageView *imageView = [layerObj.cache objectAtIndex:currentFrame];
                    
                    layerObj.image = imageView.image;
                    
                    layerObj.file = nil;
                }
            }
            else 
            {
                if (layerObj.path)
                {
                    NSString *path = [NSString stringWithFormat:layerObj.path,currentFrame];
                    
                    if (![path isEqualToString:layerObj.file])
                    {
                        layerObj.file = path;
                        
                        layerObj.image = [UIImage imageWithContentsOfFile:path];
                    }
                }
            }
        }
    }
}

@end
