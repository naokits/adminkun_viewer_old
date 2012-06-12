//
//  NKTools.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/29.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "NKTools.h"
#import "Base64EncDec.h"

@implementation NKTools
- (NSString *)applicationDocumentsDirectory {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}

- (BOOL)makeEncodedImage {
  // 画像からBASE64を作る　テスト用
  NSBundle* mainBundle=[NSBundle mainBundle];
  NSString* path =[mainBundle pathForResource:@"title" ofType:@"gif"];
  NSData* data = [[NSData alloc] initWithContentsOfFile:path];
  NSLog(@"%@", [data stringEncodedWithBase64]);
  if (data == nil || [data bytes] == 0) {
    [data release];
    return NO;
  } else {
    [data release];
    return YES;
  }
}


/**
 初期データベースをDocumentsディレクトリーにコピーする
 */
- (void)copyInitialDatabase {
  // BM_START(copy_db_file);
  BOOL success = [self makeInitialDBFile];
  if (success) {
    LOG(@"DBファイルのコピー成功");
  } else {
    LOG(@"すでにDBファイルが存在する、または失敗");
  }
  // BM_END(copy_db_file);
}


/**
 DBファイルがドキュメントフォルダに存在しない場合、初期DBをメインバンドルからコピーする。
 return:
   YES コピーした
   NO: こぴーしなかった
 **/
- (BOOL)makeInitialDBFile {
  BOOL success;
  NSData* data;
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSString* dbPath = @"MrAdminViewer.sqlite";
  
  // DocumentsディレクトリにDBファイルが存在するか調べる
  // NSString* aHomeDir = NSHomeDirectory();
  // NSString* tmpDir = NSTemporaryDirectory();
  NSString* documentsDir = [self applicationDocumentsDirectory];
  NSString* targetPath = [documentsDir stringByAppendingPathComponent:dbPath];
  LOG(@"### Target path is %@", targetPath);
  success = [fileManager fileExistsAtPath:targetPath isDirectory:NO];
  if (success) {
    NSLog(@"### Database file already exist in Documents directory.");
    // [data release];
    return NO;
  }

  
  // コピー元ディレクトリとファイルパスの取得
  NSBundle* mainBundle=[NSBundle mainBundle];
  NSString* sourcePath =[mainBundle pathForResource:@"MrAdminViewer" ofType:@"sqlite"];
  LOG(@"### Database source path is %@", sourcePath);
  
  // コピー元のDBファイルが存在すれば読む
  success = [fileManager fileExistsAtPath:sourcePath isDirectory:NO];
  if (success) {
    data = [[[NSData alloc] initWithContentsOfFile:sourcePath] autorelease];
    NSLog(@"### Original database file size is %d", [data bytes]);
  } else {
    NSLog(@"### Not found original database file.");
    // [data release];
    return NO;
  }
  
  // コピー先にDBファイルが存在しない場合のみ実行
  [fileManager changeCurrentDirectoryPath:documentsDir];
  success = [data writeToFile:targetPath atomically:YES];
  if (success) {
    LOG(@"### Success copy database file.");
    return YES;
  } else {
    NSLog(@"### Falure in copy database file.");
    return NO;
  }
}

- (void)dealloc {
  [super dealloc];
}
@end
