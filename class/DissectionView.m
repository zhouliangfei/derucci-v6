//
//  DissectionView.m
//  Sofa
//
//  Created by ccloveaa on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "GUIExt.h"
#import "DissectionView.h"



#define A_ANIMATION_COUNT   101
#define B_ANIMATION_COUNT   28
#define AB_360_COUNT        37
#define A_DETAIL_COUNT      26
#define MAIN_FRAME_COUNT (B_ANIMATION_COUNT + AB_360_COUNT + AB_360_COUNT)

#define SLEEPPP if( isUseSleep ) [NSThread sleepForTimeInterval:0.03]

#define CGRectMakeFromDirectory(_dict) CGRectMake([[_dict objectForKey:@"x"] intValue],[[_dict objectForKey:@"y"] intValue],[[_dict objectForKey:@"w"] intValue],[[_dict objectForKey:@"h"] intValue])
#define CGRectMakeFromDirectory2(_dict) CGRectMake([[_dict objectForKey:@"x"] intValue]*2,[[_dict objectForKey:@"y"] intValue]*2,[[_dict objectForKey:@"w"] intValue]*2,[[_dict objectForKey:@"h"] intValue]*2)
#define STR_RM_P50(sttt) [sttt stringByReplacingOccurrencesOfString:@"_p50" withString:@""]


@implementation DissectionView

- (void)showSubView:(UIView*)aView index:(int)index
{
    unsigned int count = [[aView subviews] count];
    
    for (int i=0; i<count; i++) {
        UIView *v = [[aView subviews] objectAtIndex:i];
        if (i == index) {
            v.hidden = FALSE;
        } else {
            v.hidden = TRUE;
        }
    }
}
    
/*- (void)showLoadingView
{
    if (!loadingView) {
        loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadingView.frame = CGRectMake(512-15, 384+5, 30, 30);
        [loadingView startAnimating];
        [self addSubview:loadingView];
        self.userInteractionEnabled = NO;
    } 
}

- (void)hideLoadingView
{
    if (loadingView) {
        [loadingView stopAnimating];
        [loadingView removeFromSuperview];
        [loadingView release];
        self.userInteractionEnabled = YES;
        loadingView = NULL;
    }
}*/

#pragma mark main view

- (void)goA360
{
    if (indexMain>(AB_360_COUNT*1.5 + B_ANIMATION_COUNT)) {
        indexAcc = 1;
    } else {
        indexAcc = -1;
    }
    
    status = STATUS_GO_A;
}
- (void)goB360
{
    if (indexMain>AB_360_COUNT/2) {
        indexAcc = 1;
    } else {
        indexAcc = -1;
    }
    
    status = STATUS_GO_B;
}

- (void)loadDetailImage:(NSString*)s index:(int)index
{
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    
    //NSMutableArray *tmpArray = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *fname = NULL;
    
    isUseFullSize = FALSE;
    
    if (isUseFullSize) {
        fname = [NSString stringWithFormat:@"feature/V6/JP_%@_C%d.txt",s,(index+1)];
    } else {
        fname = [NSString stringWithFormat:@"feature/V6/JP_%@_C%d_p50.txt",s,(index+1)];
    }
    
    
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:fname] encoding:NSUTF8StringEncoding error:nil];
    NSArray *tmpArray = [string JSONValue];
    
    for (unsigned int i=0; i<[tmpArray count]; i++) {
        
        NSDictionary *d = [tmpArray objectAtIndex:i];
        
        if (isUseFullSize) 
        {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:detailView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[detailView addSubview: tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory(d) fname:[d objectForKey:@"name"]]];
        } else {
            if (i==([tmpArray count]-1)) {
                tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:detailView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
                //[detailView addSubview: tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:STR_RM_P50([d objectForKey:@"name"])]];
            } else {
                tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory2(d) parent:detailView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
                //[detailView addSubview: tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:[d objectForKey:@"name"]]];
            }
        }
        
        tmpImage.hidden = TRUE;
    }
    
    
    
    [p release];

}

- (void)detailButtonClicked:(UIButton*)b
{
    
    NSLog(@"detailButtonClicked");
    static unsigned int detailIndeies[] = {17,15,34,26,2,12,10,  11,8,32,28,17,4,22};
    
    NSString *s;
    int ttt;
    
    if (indexMain < AB_360_COUNT) {
        s = @"A";
        
        indexTarget = detailIndeies[b.tag] ;
        ttt = b.tag;
    } else  {
        s = @"B";
        
        indexTarget = detailIndeies[b.tag + 7] + AB_360_COUNT + B_ANIMATION_COUNT;
        ttt = b.tag;
    }
    
    buttonView.hidden = TRUE;
    
    if (!detailView) {
        detailView = [[UIView alloc] initWithFrame:self.frame];
        [self addSubview:detailView];
    } 
    
    if(detailView)
    {
        while ([[detailView subviews] count]) {
            [[[detailView subviews] objectAtIndex:0] removeFromSuperview];
        }
    }
    
    
    [self loadDetailImage:s index:ttt];
    
    
    if (indexMain > indexTarget) {
        if ((indexMain-indexTarget) > AB_360_COUNT/2) {
            indexAcc = 1;
        } else {
            indexAcc =-1;
        }
        
        
    } else if (indexMain < indexTarget) {
        if ((indexTarget-indexMain) > AB_360_COUNT/2) {
            indexAcc =-1;
        } else {
            indexAcc = 1;
        }
    }
        
    status = STATUS_DETAIL;
    
    
    
}

- (void)loadMainViewButton
{
    
    /*NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    
    buttonViewLocations = [[NSMutableArray alloc] init];
    
        
    buttonView.hidden = TRUE;
    NSString *fname = NULL;
    
    for (unsigned int i =0; i<8; i++) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init] ;
        fname = [NSString stringWithFormat:@"JP_A_Point%d.txt",(i+1)];
        if (i==7) {
            [buttonView addSubview:[GLOBAL createButton:CGRectMake(0, 0, 0, 0) normal:@"JP_A_Point8_btn.png" target:self action:@selector(goB360) tag:i]];
        } else {
            [buttonView addSubview:[GLOBAL createButton:CGRectMake(0, 0, 0, 0) normal:@"JP_A_Point1_btn.png" target:self action:@selector(detailButtonClicked:) tag:i]];
        }
        [Utilities initWithFile:fname array:tmpArray];
        [buttonViewLocations addObject:tmpArray];
        [tmpArray release];
        SLEEPPP;
    }
    
    for (unsigned int i =0; i<7; i++) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init] ;
        fname = [NSString stringWithFormat:@"JP_B_Point%d.txt",(i+1)];
        [Utilities initWithFile:fname array:tmpArray];
        [buttonViewLocations addObject:tmpArray];
        [tmpArray release];
        SLEEPPP;
    }
    
    [p release];*/
    
}

- (void)loadMainViewImages
{
    mainView.hidden = TRUE;
    
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    
    NSString *fname = NULL;
    
    //if(0){
    if (isUseFullSize) {
        fname = @"feature/V6/JP_A360.txt";
    } else {
        fname = @"feature/V6/JP_A360_p50.txt";
    }
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //[Utilities initWithFile:fname array:array];
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:fname] encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [string JSONValue];
    
    for (unsigned int i=0; i<[array count]; i++) {
        
        NSDictionary *d = [array objectAtIndex:i];
        
        if (isUseFullSize) {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory(d) fname:[d objectForKey:@"name"]]];
        } else {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory2(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:[d objectForKey:@"name"]]];
        }
        tmpImage.hidden = TRUE;    
        SLEEPPP;
    }
    
    if(0){
    //if (isUseFullSize) {
        fname = @"feature/V6/JP_B.txt";
    } else {
        fname = @"feature/V6/JP_B_p50.txt";
    }
    
    //[array removeAllObjects];
    
    //[Utilities initWithFile:fname array:array];
    string = [NSString stringWithContentsOfFile:[Utils pathForDocument:fname] encoding:NSUTF8StringEncoding error:nil];
    array = [string JSONValue];
    
    for (unsigned int i=0; i<[array count]; i++) {
        
        NSDictionary *d = [array objectAtIndex:i];
        if(0){
        //if (isUseFullSize) {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory(d) fname:[d objectForKey:@"name"]]];
        } else 
        {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory2(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:[d objectForKey:@"name"]]];
        }
        tmpImage.hidden = TRUE;
        SLEEPPP;
    }
    

    
    if (isUseFullSize) {
        fname = @"feature/V6/JP_B360.txt";
    } else {
        fname = @"feature/V6/JP_B360_p50.txt";
    }
    
    //[array removeAllObjects];
    
    //[Utilities initWithFile:fname array:array];
    string = [NSString stringWithContentsOfFile:[Utils pathForDocument:fname] encoding:NSUTF8StringEncoding error:nil];
    array = [string JSONValue];
    
    for (unsigned int i=0; i<[array count]; i++) {
        
        NSDictionary *d = [array objectAtIndex:i];
        
        if (isUseFullSize) {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory(d) fname:[d objectForKey:@"name"]]];
        } else 
        {
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory2(d) parent:mainView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[mainView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:[d objectForKey:@"name"]]];
        }
        
        tmpImage.hidden = TRUE;    
        SLEEPPP;
        
    }

    //[array removeAllObjects];
    //[array release];
    
    [p release];
    NSLog(@"loadMainViewImages done");
    
    
    isMainViewLoaded = TRUE;
    mainView.hidden = TRUE;
    //
    indexStart = 0;
    status = STATUS_A360;
    
}

- (void)initMainView
{
    isMainViewLoaded = false;
    
    mainView = [[UIView alloc] initWithFrame:self.frame];
    
    [self addSubview:mainView];
    mainView.hidden = TRUE;
    
    buttonView = [[UIView alloc] initWithFrame:self.frame];
    
    [self addSubview:buttonView];

    //[self loadMainViewButton];
    
    if (isUseThread) {
        [NSThread detachNewThreadSelector:@selector(loadMainViewButton) toTarget:self withObject:nil];
    } else {
        [self loadMainViewButton];
    }
    
    
    if (isUseThread) {
        [NSThread detachNewThreadSelector:@selector(loadMainViewImages) toTarget:self withObject:nil];
    } else {
        [self loadMainViewImages];
    }
    
}

#pragma mark start view
- (void)loadStartAnimationImages
{
    
    NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
    
    NSString *fname = NULL;
    
    //BOOL isUseFullSize = TRUE;
    if(0){
    //if (isUseFullSize) {
        fname = @"feature/V6/JP_A.txt";
    } else {
        fname = @"feature/V6/JP_A_p50.txt";
    }
    
    //NSMutableArray *array = [[NSMutableArray alloc] init];
    
    //[Utilities initWithFile:fname array:array];
    NSString *string = [NSString stringWithContentsOfFile:[Utils pathForDocument:fname] encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [string JSONValue];
    
    for (unsigned int i=0; i<[array count]; i++) {
        
        NSDictionary *d = [array objectAtIndex:[array count]-1-i];
        
        if(0){
        //if (isUseFullSize) {
           
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory(d) parent:startView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[startView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory(d) fname:[d objectForKey:@"name"]]];
        } else 
        {
             NSLog(@"%@",[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]);
            tmpImage=[GUI imageWithFrame:CGRectMakeFromDirectory2(d) parent:startView document:[NSString stringWithFormat:@"feature/V6/%@",[d objectForKey:@"name"]]];
            //[startView addSubview:tmpImage = [GLOBAL createImage:CGRectMakeFromDirectory2(d) fname:[d objectForKey:@"name"]]];
        }
        tmpImage.hidden = TRUE;
        SLEEPPP;
    }
    
    ///[array removeAllObjects];
    //[array release];
    
    [p release];
        
    NSLog(@"isStartViewLoaded done");
    status = STATUS_START;
    isStartViewLoaded = TRUE;
    startView.hidden = NO;
    [self performSelectorOnMainThread:@selector(startAnimation) withObject:nil waitUntilDone:NO];
}


- (void)initStartView
{
    [GUI loadingForView:self visible:YES];
    //[self showLoadingView];
    isStartViewLoaded = false;
    startView = [[UIView alloc] initWithFrame:self.frame];
    startView.hidden = TRUE;
    if (isUseThread) {
        [NSThread detachNewThreadSelector:@selector(loadStartAnimationImages) toTarget:self withObject:nil];
    } else {
        [self loadStartAnimationImages];
    }
    
    [self addSubview:startView];
    
}

- (void)goMain
{
    //[self stopAnimation];
   // GO(@"HomeView");
}

- (void)load
{
    return;
    //btnJiepao.hidden = TRUE;
    
    [self showSubView:startView index:1000];
    [self showSubView:mainView index:1000];
    
    status = STATUS_START;
    
}

- (void)dealloc
{
    if (startView) {
        while ([[startView subviews] count]) {
            [(UIView*)[[startView subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [startView removeFromSuperview];
        [startView release];
        startView = NULL;
    }
    
    
    if (mainView) {
        
        while ([[mainView subviews] count]) {
            [(UIView*)[[mainView subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [mainView removeFromSuperview];
        [mainView release];
        mainView = NULL;
    }
    
    
    if (buttonView) {
        
        while ([[buttonView subviews] count]) {
            [(UIView*)[[buttonView subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [buttonView removeFromSuperview];
        [buttonView release];
        buttonView = NULL;
    }
    
    if (detailView) {
        while ([[detailView subviews] count]) {
            [(UIView*)[[detailView subviews] objectAtIndex:0] removeFromSuperview];
        }
        
        [detailView removeFromSuperview];
        [detailView release];
        detailView = NULL;
    }

    if (buttonViewLocations) {
        [buttonViewLocations removeAllObjects];
        [buttonViewLocations release];
        buttonViewLocations = NULL;
    }
    
    [super dealloc];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        indexStart = 0;
        indexMain = 0;
        indexMainOffset = 28 + 37;
        indexDetail = 0;
        
        mainView = NULL;
        startView = NULL;
        buttonView = NULL;
        detailView = NULL;
        
        isUseFullSize = TRUE;// = TRUE
        isUseThread = TRUE;
        isUseSleep = TRUE;
        
        
        status = STATUS_NONE;
        
        [self initStartView];
        
    }
    return self;
}
- (void)initIpadView
{}

- (void) startAnimation 
{
    [GUI loadingForView:self visible:NO];
    [self initMainView];
    [self stopAnimation];
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.024 target:self selector:@selector(animationLooper:) userInfo:nil repeats:YES] retain];
}

- (void) stopAnimation{
    if (animationTimer) {
        [animationTimer invalidate];
        [animationTimer release],animationTimer = nil;
    }
}

- (void) animationLooper:(NSTimer *)timer
{
    if (status==STATUS_START) {
        [startView setHidden:NO];
        if (indexStart != A_ANIMATION_COUNT) {
            [self showSubView:startView index:indexStart];
            indexStart++;
        } else if (indexStart == A_ANIMATION_COUNT) {
            if (status==STATUS_START) {
                status=STATUS_NONE;
                [GUI loadingForView:self visible:YES];
                [GUI imageWithFrame:CGRectMake(376, 662, 271, 25) parent:self source:@"source/feature_tip_360.png"];
                [GUI lableWithFrame:CGRectMake(0, 644, 1024, 11) parent:self text:@"左右拖动查看产品360度" font:[UIFont systemFontOfSize:12] color:[UIColor colorWithHex:0xaa9e7bff] align:1];
            }
        }
    }
    if (status==STATUS_A360) {
        if (startView) {
            while ([[startView subviews] count]) {
                [((UIView*)[[startView subviews] objectAtIndex:0] ) removeFromSuperview];
            }
            [startView removeFromSuperview];
            [startView release],startView = NULL;
            [GUI loadingForView:self visible:NO];
        }
        
        mainView.hidden = FALSE;
        for (unsigned int i=0; i<[[mainView subviews] count]; i++) {
            if (i==indexMain) {
                ((UIView*)[[mainView subviews] objectAtIndex:i]).hidden = FALSE;
            } else {
                ((UIView*)[[mainView subviews] objectAtIndex:i]).hidden = TRUE;
            }
        }
    }

    
}




- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        
        if ([t tapCount]==3) {
            //[self goA360];
        }
        
        if ([t tapCount]==2) {
            if (status == STATUS_DETAIL) {
                status = STATUS_DETAILBACK;    
            } else if (status == STATUS_B360) {
                [self goA360];
            }
            
            
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    

    for (UITouch *t in touches) {
        
        unsigned int indexTmp = 0;
        if (status == STATUS_B360) {
            indexTmp = indexMain - AB_360_COUNT - B_ANIMATION_COUNT;
        } else if (status == STATUS_A360) {
            indexTmp = indexMain;
        }
        
        
        if ([t locationInView:self].x < [t previousLocationInView:self].x) {
            
            indexTmp ++;
            if (indexTmp==AB_360_COUNT) {
                indexTmp = 0;
            }
        }
        
        if ([t locationInView:self].x > [t previousLocationInView:self].x) {
            if (indexTmp==0) {
                indexTmp = AB_360_COUNT -1;
            } else {
                indexTmp --;
            }
        }
        
        if (status == STATUS_A360) {
            indexMain = indexTmp;
        }
        if (status == STATUS_B360) {
            indexMain = indexTmp + indexMainOffset;
        }
    }
}

@end
