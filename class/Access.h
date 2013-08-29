//
//  Access.h
//  derucci-v6
//
//  Created by mac on 13-8-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Access : NSObject
+(id)ExtendsImages;
//登录
+(id)loginWithUserName:(NSString*)userName passWord:(NSString*)passWord;
//home
+(id)getPhotoWithModel:(NSNumber*)value;
//电子书
+(id)getBrandstoryWithCategory:(NSNumber*)value;
+(id)getBrandstoryPictureWithId:(NSNumber*)value;
//产品中心
+(id)getProductTypesWithParent:(NSNumber*)value;
+(id)getProductsWithType:(NSNumber*)value room:(NSString*)room key:(NSString*)key;
+(id)getProductOverviewWithId:(NSNumber*)value;
+(id)getProductColorsWithId:(NSNumber*)value;
+(id)getProductPhotoGalleryWithId:(NSNumber*)value;
//样板间
+(id)getRoomTypes;
+(id)getRoomsWithId:(NSNumber*)value;

+(id)getWallsWithRoomId:(NSNumber*)value;
+(id)getFloorsWithRoomId:(NSNumber*)value wallId:(NSNumber*)wallId;
+(id)getPathWithRoomId:(NSNumber*)roomId wallId:(NSNumber*)wallId floorId:(NSNumber*)floorId;

+(id)getProductsWithRoomId:(NSNumber*)value;
+(id)getColorsWithProductId:(NSNumber*)value;
+(id)getPathWithProductId:(NSNumber*)productId colorId:(NSNumber*)colorId;
@end
