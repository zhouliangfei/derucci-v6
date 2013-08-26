//
//  featureViewController.h
//  derucci-v6
//
//  Created by mac on 13-8-15.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UISequenceView.h"

@interface FeatureViewController : UIViewController<UISequenceViewDelegate>
@property(nonatomic,retain) NSDictionary *source;
@end
