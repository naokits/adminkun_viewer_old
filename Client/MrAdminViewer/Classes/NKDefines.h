//
//  NKDefines.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/29.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

//#define DEBUG

// 時間計測に使用
#define BM_START(name) NSDate *name##_start = [NSDate new]
#define BM_END(name)   NSDate *name##_end = [NSDate new];\
NSLog(@"%s interval: %f", #name, [name##_end timeIntervalSinceDate:name##_start]);\
[name##_start release];[name##_end release]


// デバッグ用マクロ
#ifdef DEBUG
#  define LOG(...) NSLog(__VA_ARGS__)
#  define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#  define LOG(...) ;
#  define LOG_CURRENT_METHOD ;
#endif

// マクロを以下の様に変更するにすると、ファイル名（行番号）で出力される
//#   define TRACE(fmt, ...) NSLog((@"%s(%d) " fmt), __FILE__, __LINE__, ##__VA_ARGS__);



#ifdef DEBUG
#   define TRACE(fmt, ...) NSLog((@"%s(%d) " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define TRACE(...)
#endif

/*
プロジェクトの設定を開く。構成でDebugを選択
左下のボタンを押してユーザー定義の設定を追加
GCC_PREPROCESSOR_DEFINITIONSを追加し、DEBUGを設定する
*/
