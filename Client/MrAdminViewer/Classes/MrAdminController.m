//
//  MrAdminController.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "MrAdminController.h"
#import "JSON.h"
#import "NKDefines.h"
#import "Reachability.h"

@implementation MrAdminController
@synthesize jsonItem;

@synthesize fetchedResultsController, managedObjectContext;

- (id) init
{
  self = [super init];
  if (self != nil) {
    self.jsonItem = nil;
  }
  return self;
}

/******************************************************************************
 * サーバ側データベースに登録されている件数を返す
 ******************************************************************************/
- (NSNumber *)getComicCount:(NSString*)lang {
  LOG_CURRENT_METHOD;
  NSString* url = @"http://adminkun00.appspot.com/current_number";
  NSString* urlString;
  urlString = [NSString stringWithFormat:@"%@?lang=%@", url, lang];
  LOG(@"url -> %@", urlString);
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
  self.jsonItem = [jsonData JSONValue]; 
  [jsonData release];
  NSInteger result = [[self.jsonItem objectForKey:@"current_number"] intValue];
  NSLog(@"結果：%d", result);

  if (result == 999) {
    NSLog(@"### ERROR NO LANG PARAMS");
    return 0;
  } else {
    LOG(@"サーバに登録済の記事数 %d", result);
    return [NSNumber numberWithInt:result];
  }
}

/******************************************************************************
 * サーバ側データベースに登録されているコミック情報を全件取得して返す
 
 ******************************************************************************/
/*
- (NSDictionary*)fetchComicList:(LanguageType)lang {
  LOG_CURRENT_METHOD;

  NSString* urlString;
  urlString = [NSString stringWithFormat:@"%@%@/adminkun", kBaseURL, kComicListURI];
  LOG(@"url -> %@", urlString);
  
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
  
  self.jsonItem = [jsonData JSONValue]; 
  LOG(@"取得済みのコミック数：%d", [self.jsonItem count]);
  
  if (jsonData == nil) {
    NSLog(@"コミック情報（JSON）の取得失敗");
  } else {
    // NSLog(@"JSONデータの取得成功");
    //    for (id item in self.jsonItem) {
    //      NSString* text;
    //      text = [item objectForKey:@"index_title"];
    //      NSLog(@"title -> %@", text);
    //    }
  }
  return self.jsonItem;
}
*/

/******************************************************************************
 * サーバ側データベースに登録されているコミック情報を1件取得して返す
 * param:
 *   start 取得開始連載番号
 *   end   取得数
 ******************************************************************************/
- (NSDictionary*)fetchComic:(NSString*)lang number:(NSInteger)number {
  LOG_CURRENT_METHOD;
  //self.remoteHostStatus = [[Reachability sharedReachability] remoteHostStatus];
  //self.remoteHostStatus = [[Reachability sharedReachability] internetConnectionStatus];
  //NSLog(@"ネットの状況：%d", [[Reachability sharedReachability] remoteHostStatus]);

  NSString* urlString;
  if (lang == @"ja") {
    urlString = [NSString stringWithFormat:@"http://adminkun00.appspot.com/get?serial_number=%d&lang=ja", number];
  } else {
    urlString = [NSString stringWithFormat:@"http://localhost:8083/get?serial_number=%d&lang=en", number];
  }
  LOG(@"url -> %@", urlString);
  NSURL *jsonURL = [NSURL URLWithString:urlString];
//  NSString *jsonData = [[[NSString alloc] initWithContentsOfURL:jsonURL] autorelease];
  NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];

  
  if (jsonData == nil) {
    NSLog(@"コミック情報（JSON）の取得失敗");
    self.jsonItem = nil;
  } else {
    self.jsonItem = [jsonData JSONValue]; 
    // NSLog(@"JSONValueの値：%@", [self.jsonItem description]);
    // NSLog(@"JSONデータの取得成功");
    //    for (id item in self.jsonItem) {
    //      NSString* text;
    //      text = [item objectForKey:@"index_title"];
    //      NSLog(@"title -> %@", text);
    //    }
  }
  [jsonData release];
  return self.jsonItem;
}


/*
- (NSDictionary*)fetchComicList:(LanguageType)lang start:(NSInteger)start count:(NSInteger)count {
  LOG_CURRENT_METHOD;
  
  NSString* urlString;
  if (lang == kJapanese) {
    urlString = [NSString stringWithFormat:@"%@%@%@/%d/%d", kBaseURL, kComicListURI, kGroupJapanese, start, count];
  } else {
    urlString = [NSString stringWithFormat:@"%@%@%@/%d/%d", kBaseURL, kComicListURI, kGroupEnglish, start, count];
  }
  LOG(@"url -> %@", urlString);
  
  NSURL *jsonURL = [NSURL URLWithString:urlString];
  NSString *jsonData = [[NSString alloc] initWithContentsOfURL:jsonURL];
  
  self.jsonItem = [jsonData JSONValue]; 
  NSLog(@"取得済みのコミック数：%d", [self.jsonItem count]);
  NSLog(@"JSONValueの後の値：%@", [self.jsonItem description]);
  
  if (jsonData == nil) {
    NSLog(@"コミック情報（JSON）の取得失敗");
  } else {
    // NSLog(@"JSONデータの取得成功");
    //    for (id item in self.jsonItem) {
    //      NSString* text;
    //      text = [item objectForKey:@"index_title"];
    //      NSLog(@"title -> %@", text);
    //    }
  }
  return self.jsonItem;
}
*/
@end
