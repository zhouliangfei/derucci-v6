//
//  featureViewController.m
//  derucci-v6
//
//  Created by mac on 13-8-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "Access.h"
#import "NavigateView.h"
#import "FeatureViewController.h"

//...............................................
@interface HotsViewLine : UIView{
    CGPoint lineBegin;
    CGPoint lineEnd;
    CGSize titleSize;
    UIFont *titleFont;
}
@property(nonatomic,assign) CGFloat fontSize;
@property(nonatomic,retain) NSString *title;
@end

@implementation HotsViewLine
@synthesize title;
@dynamic fontSize;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setOpaque:NO];
    }
    return self;
}
-(void)dealloc{
    [titleFont release];
    [title release];
    [super dealloc];
}
-(void)setFontSize:(CGFloat)fontSize{
    if (titleFont) {
        [titleFont release],titleFont=nil;
    }
    titleFont = [[UIFont boldSystemFontOfSize:fontSize] retain];
    titleSize = [title sizeWithFont:titleFont constrainedToSize:CGSizeMake(INT_MAX, fontSize)];
}
-(void)drawLine:(CGPoint)begin end:(CGPoint)end{
    lineEnd = end;
    lineBegin = begin;
    [self setNeedsDisplay];
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    //
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);  
    CGContextSetLineWidth(context, 2.0);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, lineBegin.x, lineBegin.y);
    CGContextAddLineToPoint(context, lineEnd.x, lineEnd.y);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextBeginPath(context);
    CGContextAddArc(context, lineEnd.x, lineEnd.y, 5, 0, M_2_PI, 1);
    CGContextDrawPath(context, kCGPathFill);
    
    if (lineEnd.x < self.center.x) {
        [title drawAtPoint:CGPointMake(lineEnd.x-titleSize.width-8, lineEnd.y-titleSize.height/2) withFont:titleFont];
    }else {
        [title drawAtPoint:CGPointMake(lineEnd.x+8, lineEnd.y-titleSize.height/2) withFont:titleFont];
    }
    
    CGContextRestoreGState(context);
}
@end

//...............................................
@interface HotsView : UIButton{
    HotsViewLine *lineView;
}
@property(nonatomic,retain) NSString *title;
@property(nonatomic,assign) CGPoint position;
@end

@implementation HotsView
@synthesize position;
@dynamic title;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        lineView = [[HotsViewLine alloc] initWithFrame:CGRectZero];
    }
    return self;
}
-(void)dealloc{
    if (lineView.superview) {
        [lineView removeFromSuperview];
    }
    [lineView release];
    [super dealloc];
}
-(void)setCenter:(CGPoint)center{
    [super setCenter:center];
    [self showTitle];
}
-(void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    [lineView setHidden:hidden];
}
-(void)setTitle:(NSString *)title{
    [lineView setTitle:title];
    [lineView setFontSize:16];
    [self showTitle];
}
-(void)showTitle{
    if (self.superview) {
        if (self.superview != lineView.superview) {
            [lineView setFrame:self.superview.bounds];
            [self.superview addSubview:lineView];
            [self.superview addSubview:self];
        }
        [lineView drawLine:self.center end:position];
    }
}
@end

//...............................................................
#import "DissectionView.h"
@interface FeatureViewController (){
    UISequenceView *sequenceView;
    //
    DissectionView *dis;
}
@end

@implementation FeatureViewController
@synthesize source = newSource;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [GUI imageWithFrame:CGRectMake(0, 0, 1024, 768) parent:self.view source:@"source/background.png"];
    //[self.view addSubview:(sequenceView=[[UISequenceView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)])];
    //[sequenceView setDelegate:self];
    
    //[GUI imageWithFrame:CGRectMake(376, 662, 271, 25) parent:self.view source:@"source/feature_tip_360.png"];
    //[GUI lableWithFrame:CGRectMake(0, 644, 1024, 11) parent:self.view text:@"左右拖动查看产品360度" font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0xaa9e7bff] align:1];
    
    dis = [[DissectionView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [self.view addSubview:dis];
    [dis release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [sequenceView release],sequenceView=nil;
    [newSource release],newSource=nil;
}

-(void)dealloc{
    [dis stopAnimation];
    //
    [sequenceView release];
    [newSource release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewWillAppear:(BOOL)animated{
    [NavigateView shareInstanceInView:self.view];
    //
    if ([GUIExt extendsView]) {
        [GUIExt extendsView].animationImages=[Access ExtendsImages];
    }
}
//
-(void)setSource:(NSDictionary *)source{
    return;
    id temp = [source retain];
    if (newSource) {
        [newSource release],newSource=nil;
    }
    newSource = temp;
    [self initMainSequence:0];
}
-(void)initMainSequence:(int)frame{
    id sequence = [newSource objectForKey:@"sequence"];
    NSString *low = [Utils pathForDocument:[sequence objectForKey:@"low"]];
    NSString *high = [Utils pathForDocument:[sequence objectForKey:@"high"]];
    NSInteger count = [[sequence objectForKey:@"count"] integerValue];
    
    [sequenceView setLoop:YES];
    [sequenceView setTotalFrame:count];
    //
    [GUI loadingForView:self.view visible:YES];
    UISequenceViewCell *cell = [sequenceView childAtIndex:1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        cell.path = high;
        for (uint ind=0; ind<sequenceView.totalFrame; ind++) {
            NSString *path = [NSString stringWithFormat:low,ind];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell cacheAtFrame:ind image:image];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [GUI loadingForView:self.view visible:NO];
            [sequenceView setCurrentFrame:frame];
        });
    });
    //
    id pointSource = [newSource objectForKey:@"point"];
    if (pointSource){
        int len = [pointSource count];
        for (int i=0; i<len; i++){
            id temp = [pointSource objectAtIndex:i];
            
            HotsView *btn = [[[HotsView alloc] initWithFrame:CGRectMake(0, 0, 37, 36)] autorelease];
            [btn addTarget:self action:@selector(pointTouch:) forControlEvents:UIControlEventTouchUpInside];
            [btn setImage:[UIImage imageWithResource:@"source/feature_btn_doc.png"] forState:UIControlStateNormal];
            [btn setTitle:[temp objectForKey:@"title"]];
            [btn setPosition:CGPointFromString([temp objectForKey:@"position"])];
            [btn setTag:i + 1];
            [sequenceView addPoint:btn u:[temp objectForKey:@"u"] v:[temp objectForKey:@"v"]];
        }
    }
}
@end
