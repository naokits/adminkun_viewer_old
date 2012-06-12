//
//  MrAdminController.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kBaseURL = @"http://nkts.local:3000";
static NSString *const kComicListURI = @"/get_menu";
static NSString *const kComicCountURI = @"/count";
static NSString *const kGroupJapanese = @"/adminkun";
static NSString *const kGroupEnglish = @"/mradmin";

typedef enum _LanguageType {
  kJapanese,
  kEnglish
} LanguageType;


@interface MrAdminController : NSObject {
  NSDictionary* jsonItem;

  NSFetchedResultsController *fetchedResultsController;
  NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, retain) NSDictionary* jsonItem;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (NSDictionary*)fetchComic:(NSString*)lang number:(NSInteger)number;
//- (NSDictionary*)fetchComicList:(LanguageType)lang;
//- (NSDictionary*)fetchComicList:(LanguageType)lang start:(NSInteger)start count:(NSInteger)count;
- (NSNumber *)getComicCount:(NSString*)lang;

@end

