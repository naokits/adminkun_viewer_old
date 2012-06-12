//
//  MrAdmin.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/08/23.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface MrAdmin :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * bodyImageUrl;
@property (nonatomic, retain) NSString * indexOverview;
@property (nonatomic, retain) NSNumber * readFlag;
@property (nonatomic, retain) NSString * indexImageUrl;
@property (nonatomic, retain) NSString * bodyUrl;
@property (nonatomic, retain) NSNumber * serialNumber;
@property (nonatomic, retain) NSString * indexImage;
@property (nonatomic, retain) NSString * indexTitle;
@property (nonatomic, retain) NSString * bodyImage;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * lang;

@end



