//
//  Access.m
//  derucci-v6
//
//  Created by mac on 13-8-7.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#import "SQL.h"
#import "Utils.h"
#import "Config.h"
#import "Access.h"

@implementation Access
+(id)ExtendsImages{
    static NSMutableArray *ExtendsImagesAccess;
    @synchronized(self){
        if (nil==ExtendsImagesAccess) {
            ExtendsImagesAccess = [[NSMutableArray alloc] init];
            //
            NSString *sql = [NSString stringWithFormat:@"SELECT photo FROM brandstorypicture WHERE deleted=0 ORDER BY dispIndex"];
            NSArray *tmp = [[SQL shareInstance] fetch:sql];
            for (id dic in tmp) {
                [ExtendsImagesAccess addObject:[dic objectForKey:@"photo"]];
            }
        }
    }
    return ExtendsImagesAccess;
}
//登录
+(id)loginWithUserName:(NSString*)userName passWord:(NSString*)passWord{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM users WHERE username='%@' AND password LIKE '%%%@%%' LIMIT 0,1",userName,[Utils md5:passWord]];
    id sales = [[SQL shareInstance] fetch:sql];
    if (sales){
        NSString *timeStr = [[sales lastObject] objectForKey:@"worktime"];
        if (timeStr.length > 0){
            NSDate *workTime = [timeStr dateFromFormatter:@"yyyy-MM-dd HH:mm:ss"];
            //有效期内
            if ([workTime timeIntervalSinceNow] > -86400.0*30.0){
                return [sales lastObject];
            }
        }
    }
    //
    NSString *hash = [NSString stringWithFormat:@"%@:%@",[Utils macAddress],[[NSBundle mainBundle] bundleIdentifier]];
    id webdata = [Utils getURL:[REMOTEURL stringByAppendingFormat:RemoteLogin,userName,[Utils md5:passWord],[Utils md5:hash]]];
    
    if ([webdata isKindOfClass:[NSError class]]){
        return webdata;
    }else{
        id temp = [webdata JSONValue];
        id message = [temp objectForKey:@"message"];
        
        if (message != [NSNull null]){
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:NSNotFound userInfo:userInfo];
        }else{
            sales = [temp objectForKey:@"users"];
            if (sales != [NSNull null]){
                [sales setObject:[[NSDate date] stringFromFormatter:@"yyyy-MM-dd HH:mm:ss"] forKey:@"worktime"];
                [sales setObject:[[sales objectForKey:@"area"] objectForKey:@"id"] forKey:@"area_id"];
                [sales setObject:[[sales objectForKey:@"shop"] objectForKey:@"id"] forKey:@"shop_id"];
                [sales setObject:[[sales objectForKey:@"region"] objectForKey:@"id"] forKey:@"region_id"];
                [sales removeObjectForKey:@"area"];
                [sales removeObjectForKey:@"shop"];
                [sales removeObjectForKey:@"region"];
                id temp = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:sales] forKey:@"users"];
                //插入数据
                NSArray *sqlDat = [Utils intoSqlWithDictionary:temp];
                for (id cmd in sqlDat){
                    [[SQL shareInstance] query:cmd];
                }
                //取数据
                sql = [NSString stringWithFormat:@"SELECT * FROM users WHERE id=%@",[sales objectForKey:@"id"]];
                NSArray *value = [[SQL shareInstance] fetch:sql];
                if (value){
                    return [value lastObject];
                }
            }
        } 
    }
    return nil;
}
//home
+(id)getPhotoWithModel:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT photo FROM modelPicture WHERE "\
                     "deleted=0 AND model=%@",value];
    return [[SQL shareInstance] fetch:sql];
}
//电子书
+(id)getBrandstoryWithCategory:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT id,name,photo,file,fileType FROM brandstory WHERE "\
                     "deleted=0 AND category=%@",value];
    return [[SQL shareInstance] fetch:sql];
}

+(id)getBrandstoryPictureWithId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT photo,smallPhoto FROM brandstorypicture WHERE "\
                     "deleted=0 AND brandStory_id=%@ ORDER BY dispIndex",value];
    return [[SQL shareInstance] fetch:sql];
}
//产品中心
+(id)getProductTypesWithParent:(NSNumber*)value{
    NSString *sql = @"SELECT * FROM producttype WHERE deleted=0";
    if (value) {
        sql = [sql stringByAppendingFormat:@" AND parent_id=%@",value];
    }
    return [[SQL shareInstance] fetch:sql];
}
+(id)getProductsWithType:(NSNumber*)value room:(NSString*)room key:(NSString*)key{
    NSString *sql = @"SELECT a.*,b.bigPhoto,f.roomTypeId,f.roomTypeName FROM product a,productpicture b "\
    "LEFT JOIN (SELECT DISTINCT b.id,a.id roomTypeId,a.name roomTypeName FROM roomtype a,roomproductmapcolor b,room c,roommapproduct d WHERE "\
    "d.deleted=0 AND d.room_id=c.id AND c.deleted=0 AND c.roomType_id=a.id AND b.deleted=0 AND b.roomMapProduct_id=d.id) f ON a.roomProductMapColor_id=f.id "\
    "WHERE b.deleted=0 AND b.isDefault=1 AND b.product_id=a.id AND a.deleted=0";
    if (value) {
        sql = [sql stringByAppendingFormat:@" AND a.productType_id=%@",value];
    }
    if (room) {
        sql = [sql stringByAppendingFormat:@" AND f.roomTypeId IN(%@)",room];
    }
    if (key) {
        sql = [sql stringByAppendingFormat:@" AND (a.name LIKE '%%%@%%' OR a.model LIKE '%%%@%%' OR a.description LIKE '%%%@%%')",key,key,key];
    }
    return [[SQL shareInstance] fetch:[sql stringByAppendingString:@" ORDER BY a.model"]];
}
+(id)getProductOverviewWithId:(NSNumber*)value{
    NSString *sql = @"SELECT * FROM productsummary WHERE deleted=0";
    if (value) {
        sql = [sql stringByAppendingFormat:@" AND product_id=%@",value];
    }
    sql = [sql stringByAppendingString:@" ORDER BY dispIndex DESC"];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getProductColorsWithId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT b.* FROM productmapcolor a,color b WHERE "\
                     "b.deleted=0 AND b.id=a.color_id AND a.deleted=0 AND a.product_id=%@ LIMIT 0,1",value];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getProductPhotoGalleryWithId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM productpicture WHERE deleted=0 AND isDefault=0 AND product_id=%@",value];
    return [[SQL shareInstance] fetch:sql];
}
//样板间
+(id)getRoomTypes{
    return [[SQL shareInstance] fetch:@"SELECT * FROM roomtype WHERE deleted=0"]; 
}
+(id)getRoomsWithId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM room WHERE deleted=0 AND id=%@",value];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getWallsWithRoomId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT a.isDefault,b.* FROM roommapwallcarpet a,wall b WHERE "\
                     "b.deleted=0 AND b.id=a.wall_id AND a.deleted=0 AND a.room_id=%@ GROUP BY b.id",value];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getFloorsWithRoomId:(NSNumber*)value wallId:(NSNumber*)wallId{
    NSString *sql = [NSString stringWithFormat:@"SELECT a.isDefault,b.* FROM roommapwallcarpet a,carpet b WHERE "\
                     "b.deleted=0 AND b.id=a.carpet_id AND a.deleted=0 AND a.room_id=%@ AND a.wall_id=%@ GROUP BY b.id",value,wallId];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getPathWithRoomId:(NSNumber*)roomId wallId:(NSNumber*)wallId floorId:(NSNumber*)floorId{
    NSString *sql = [NSString stringWithFormat:@"SELECT files FROM roommapwallcarpet WHERE "\
                     "deleted=0 AND room_id=%@ AND wall_id=%@ AND carpet_id=%@",roomId,wallId,floorId];
    NSArray *temp = [[SQL shareInstance] fetch:sql];
    if (temp) {
        return [temp lastObject];
    }
    return nil;
}
+(id)getProductsWithRoomId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT a.isDefault,b.*,a.id,c.bigPhoto FROM roommapproduct a,product b,productpicture c WHERE "\
                     "c.deleted=0 AND c.product_id=b.id AND b.deleted=0 AND b.id=a.product_id AND a.deleted=0 AND a.room_id=%@ GROUP BY b.id",value];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getColorsWithProductId:(NSNumber*)value{
    NSString *sql = [NSString stringWithFormat:@"SELECT a.isDefault,b.* FROM roomproductmapcolor a,color b WHERE "\
                     "b.deleted=0 AND b.id=a.color_id AND a.deleted=0 AND a.roomMapProduct_id=%@ GROUP BY a.id",value];
    return [[SQL shareInstance] fetch:sql];
}
+(id)getPathWithProductId:(NSNumber*)productId colorId:(NSNumber*)colorId{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM roomproductmapcolor WHERE "\
                     "deleted=0 AND roomMapProduct_id=%@ AND color_id=%@",productId,colorId];
    NSArray *temp = [[SQL shareInstance] fetch:sql];
    
    if (temp) {
        return [temp lastObject];
    }
    return nil;
}
@end
