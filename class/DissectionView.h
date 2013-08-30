//
//  DissectionView.h
//  Sofa
//
//  Created by ccloveaa on 5/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
    STATUS_NONE             = 8,
    STATUS_START            = 0,
    STATUS_A360             = 1,
    STATUS_B360             = 2,
    STATUS_GO_B             = 3,
    STATUS_GO_A             = 4,
    STATUS_DETAIL           = 5,
    STATUS_DETAILBACK       = 6,
    
}DISS_STATUS;

@interface DissectionView : UIView {
    
    //进场动画
    
    UIView *startView;
    UIView *mainView;
    UIView *buttonView;

    NSMutableArray *buttonViewLocations;
    
    UIView *detailView;
    
    BOOL isStartViewLoaded;
    BOOL isMainViewLoaded;
    BOOL isDetailViewLoaded;
    
    unsigned int indexStart;
    unsigned int indexMain;
    unsigned int indexMainOffset;
    unsigned int indexDetail;
    
    unsigned int indexTarget;
    int indexAcc;
    
    DISS_STATUS status;
    
    UIActivityIndicatorView *loadingView;
    
    BOOL isUseFullSize;// = TRUE;
    BOOL isUseThread;
    
    BOOL isUseSleep;
    
    UIImageView *tmpImage;
    NSTimer *animationTimer;
}
- (void) stopAnimation;
@end


