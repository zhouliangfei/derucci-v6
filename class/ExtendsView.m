//
//  ExtendsView.m
//  derucci-v6
//
//  Created by mac on 13-8-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "ExtendsView.h"

@implementation ExtendsView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        animationImage = [[NSMutableArray alloc] init];
        [self setContentMode:UIViewContentModeScaleAspectFit];
    }
    return self;
}

-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [animationImage release];
    [super dealloc];
}
//
-(void)setAnimationImages:(NSArray *)animationImages{
    BOOL isEqual = NO;
    if (animationImages && animationImages.count==animationImage.count) {
        for (int i=0; i<animationImages.count; i++) {
            isEqual = [[animationImages objectAtIndex:i] isEqual:[animationImage objectAtIndex:i]];
            if (NO==isEqual) {
                break;
            }
        }
    }
    
    if (NO==isEqual) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [animationImage removeAllObjects];
        if (animationImages) {
            for (id val in animationImages) {
                [animationImage addObject:val];
            }
            current = 0;
            [self nextImage:nil];
        }else {
            [self setImage:nil];
        }
    }
}
-(NSArray *)animationImages{
    return animationImage;
}
-(void)nextImage:(id)sender{
    [self setImage:[UIImage imageWithDocument:[animationImage objectAtIndex:current]]];
    [self.layer addAnimation:[CATransition animation] forKey:nil];
    if (animationImage.count > 1) {
        [self performSelector:@selector(nextImage:) withObject:nil afterDelay:5];
        
        current++;
        current%=animationImage.count;
    }
}
@end
