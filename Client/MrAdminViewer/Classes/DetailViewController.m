//
//  DetailViewController.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/24.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "DetailViewController.h"
#import "MrAdmin.h"
#import "Base64EncDec.h"
#import "NKDefines.h"
#import "WaitingIndicator.h"
#import "Reachability.h"


@interface DetailViewController()
- (BOOL)fetchComicImageFromAtmarkIt;
- (NSString *)generateHTMLString;
- (void)fetchComicImage;
- (void)networkLostAlert:(NSError *)error;
- (BOOL)judgeCopyrightSiteWithRequest:(NSURLRequest *)request keyword:(NSString *)keyword;
- (void)MoveSiteAlert;
- (void)addSegmentedImageButton;
@end

@implementation DetailViewController
@synthesize detailView;
@synthesize indicatorView;
@synthesize admin;
@synthesize ownerSiteURL;
@synthesize segmentControl;


- (void)dealloc {
  LOG_CURRENT_METHOD;
  [segmentControl release];
  [detailView setDelegate:nil];
  [indicatorView release];
  [admin release];
  [detailView release];
  [ownerSiteURL release];
  [super dealloc];
}

- (void)segmentAction:(id)sender {
  NSLog(@"セグメントがタップされた");
  // 押されたボタンのINDEXを取得
	int index = segmentControl.selectedSegmentIndex;
	
	if(index == 0) {
    NSLog(@"oneがタップされた");
	} else {
    NSLog(@"twoがタップされた");
	}
}


/**
 viewをローディング後に追加のセットアップを行う（xibからの起動)
 */
- (void)viewDidLoad {
  LOG_CURRENT_METHOD;
  [super viewDidLoad];
  
  // 記事のタイトルから「第○話」だけを切り出す
  NSArray *titleItems = [admin.indexTitle componentsSeparatedByString:@"　"];
  self.title = [titleItems objectAtIndex:0];
  self.navigationItem.hidesBackButton = YES;

  // UIWebViewDelegateを自分自身に設定
  [detailView setDelegate:self];
  
  [self addSegmentedImageButton];
}


- (void)addSegmentedImageButton {
  // セグメントコントローラを右ボタンとして追加
  NSArray *imageItems = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"arrow_sans_up_32.png"],
                         [UIImage imageNamed:@"arrow_sans_down_32.png"],
                         nil];
  segmentControl = [[UISegmentedControl alloc] initWithItems:imageItems];
  
  segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentControl.momentary = YES; // 通常ボタンとして使用する
  [segmentControl addTarget:self action:@selector(segmentAction:) 
           forControlEvents:UIControlEventValueChanged];
  
  UIBarButtonItem *item;
  item = [[[UIBarButtonItem alloc] initWithCustomView:segmentControl] autorelease];
  self.navigationItem.rightBarButtonItem = item;
}

/**
 Viewを表示する直前に実行する
 */
- (void)viewWillAppear:(BOOL)animated {
  LOG_CURRENT_METHOD;
  LOG(@"### Size of Image data:%d", [admin.bodyImage length]);
  LOG(@"### Serial number：%d", [admin serialNumber]);
  // インジケータを表示する
  indicatorView = [[WaitingIndicator alloc] initWithFrame:[self.view bounds]];
  [self.view addSubview:indicatorView];
  [indicatorView start];
}

/**
 Viewが表示された直後に呼ばれる
 */
- (void)viewDidAppear:(BOOL)animated {
  LOG_CURRENT_METHOD;
  [super viewDidAppear:animated];
  
  // インジケータ表示中に別スレッドでコミックデータを取得し、HTMLを生成する
  [NSThread detachNewThreadSelector:@selector(fetchComicImage) toTarget:self withObject:nil];
}

/**
 アドミン君のコミックデータ取得とHTML生成
 */
- (void)fetchComicImage {
  // スレッドの入り口でメモリプールを管理
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  LOG_CURRENT_METHOD;
  // BM_START(__get_commic_data);
  BOOL success;
  self.hidesBottomBarWhenPushed = YES;

  // 画像サイズが0以上は正常にデータストアに格納済みとする
  // Downlod comic image file if not stored DataStore.
  if ([admin.bodyImage length] == 0) {
    success = [self fetchComicImageFromAtmarkIt];
    // successがNOの場合は、ファイルが取得できなかったか、ネットワークが切断されている
    if (!success) {
      [self.navigationController popViewControllerAnimated:YES];
//      NSError* error;
//      [self networkLostAlert:error];
      [pool release];
      return;
    }
  } else {
    LOG(@"### Fetch body image data from DataStore.");
  }
  // BM_END(__get_commic_data);
  
  // Generate HTML
  NSString* html = [self generateHTMLString];
  [detailView loadHTMLString:html baseURL:nil];
  
  // Stop indicator and remove view
  [indicatorView stop];
  [indicatorView removeFromSuperview];
  self.navigationItem.hidesBackButton = NO;
  [pool release];
}

/**
 @ITよりコミック本文の画像を取得する
 */
- (BOOL)fetchComicImageFromAtmarkIt {
  LOG_CURRENT_METHOD;
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
  LOG(@"### Fetch image data from @IT.");
  NSURL *url;
  NSData* data;
  NSString* encodedImageWidhBase64;

  url = [NSURL URLWithString:[admin bodyImageUrl]];
  // ネットワークに接続できない場合は、即座にnilが返る
  data = [NSData dataWithContentsOfURL:url];
  
  LOG(@"### Body image size is %d", [data bytes]);
//  if ([data bytes] == 0) {
  if (data == nil) {
    NSLog(@"### Not found image file of comic or disconnected network!");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    return NO;
  } else {
    // Base64にエンコードしてデータストアに格納する
    encodedImageWidhBase64 = [data stringEncodedWithBase64];
    [admin setValue:encodedImageWidhBase64 forKey:@"bodyImage"];
    NSError* error;
    // データストアに保存
    if (![[admin managedObjectContext] save:&error]) {
      NSLog(@"### Error Occurs while save Image data into DataStore!!!");
    }
  }
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  return YES;
}


/**
 HTMLを生成する
 */
- (NSString *)generateHTMLString {
  LOG_CURRENT_METHOD;
  // TRACE(@"### GENERATE HTML");
  // BM_START(__generate_html);

  NSError* error;
  NSBundle* mainBundle=[NSBundle mainBundle];
  NSString* path = [mainBundle pathForResource:@"adminkun" ofType:@"html"];
  NSString* webContent = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  NSString* html = [webContent stringByReplacingOccurrencesOfString:@"#{@nk_overview}" withString:admin.indexOverview];

  // タイトル画像（エンコード済みのテキストファイル）
  NSString* sourcePath = [mainBundle pathForResource:@"title_base64" ofType:@"txt"];
  NSString* titlesrc = [[NSString alloc] initWithContentsOfFile:sourcePath];
  html = [html stringByReplacingOccurrencesOfString:@"#{@nk_title_image}" withString:titlesrc];
  
  // 本文の画像
  html = [html stringByReplacingOccurrencesOfString:@"#{@nk_body_image}" withString:admin.bodyImage];
  
  [titlesrc release];
  [webContent release];
  
  LOG(@"### Complete generate HTML");
  // BM_END(__generate_html);
  return html;
}

/**
 Override to allow orientations other than the default portrait orientation.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  LOG_CURRENT_METHOD;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 メモリ不足時の処理
 */
- (void)didReceiveMemoryWarning {
  LOG_CURRENT_METHOD;
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

/**
 メモリ圧迫時でかつ画面が表示されていない場合にこのイベントが発生する。
 viewDidLoadメソッドでインスタンス化している場合は、ここで解放すること。
 */
- (void)viewDidUnload {
  LOG_CURRENT_METHOD;
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/**
 ネットワーク（Wifi）が使用できない事を知らせるアラート
 */
- (void)networkLostAlert:(NSError *)error {
  LOG_CURRENT_METHOD;
  NSString* message = NSLocalizedString(@"No Internet connection",  @"インターネットが利用できません");
  NSString* title = NSLocalizedString(@"Mr.Admin Viewer", @"アドミンくんビューワ");
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}


#pragma mark -
#pragma mark UIWebViewDelegate

/**
 UIWebViewで表示されるリンクをタップされた時の処理
 @return YES: UIWebView内に表示する。 NO: 表示しない
 */
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  LOG_CURRENT_METHOD;
  
  if (navigationType == UIWebViewNavigationTypeLinkClicked || 
      navigationType == UIWebViewNavigationTypeOther) {
    
    if ([self judgeCopyrightSiteWithRequest:request keyword:@"tamamushiya"]) {
      LOG(@"正木茶丸が見つかった");
      ownerSiteURL = @"http://www7a.biglobe.ne.jp/%7Etamamushiya/";
      [self MoveSiteAlert];
      return NO;
    } else if ([self judgeCopyrightSiteWithRequest:request keyword:@"d-advantage"]) {
      LOG(@"アドバンテージが見つかった");
      ownerSiteURL = @"http://www.d-advantage.jp/";
      [self MoveSiteAlert];
      return NO;
    } else if ([self judgeCopyrightSiteWithRequest:request keyword:@"atmarkit"]) {
      LOG(@"@ITが見つかった");
      ownerSiteURL = @"http://www.atmarkit.co.jp/fwin2k/itpropower/admin-kun/index/";
      [self MoveSiteAlert];
      return NO;
    } else if ([self judgeCopyrightSiteWithRequest:request keyword:@"itmedia"]) {
      LOG(@"@アイティメディアが見つかった");
      ownerSiteURL = @"http://corp.itmedia.co.jp/";
      [self MoveSiteAlert];
      return NO;
    } else {
      LOG(@"### Not found target keyword.");
    }
  }
  // アクセス制限はしないので、常にYESを返す
  return YES;
}


/**
 引数で指定するキーワードがURLに含まれる場合は、著作権を有するサイトとし、真を返す。
 それ以外は偽を返す。
 */
- (BOOL)judgeCopyrightSiteWithRequest:(NSURLRequest *)request keyword:(NSString *)keyword {
  LOG_CURRENT_METHOD;
  NSRange range;
  range = [[[request URL] absoluteString] rangeOfString:keyword options:NSCaseInsensitiveSearch];
  if (range.location != NSNotFound) {
    return YES;
  } else {
    return NO;
  }
}


/**
 Safariを起動してサイトを表示するか確認するアラート
 */
- (void)MoveSiteAlert {
  LOG_CURRENT_METHOD;
  NSString* title = NSLocalizedString(@"Mr.Admin Viewer", @"アドミンくんビューワ");
  NSString* message = NSLocalizedString(@"This will open Safari.\nSure?", @"Safariを起動します。\nよろしいですか？");
  UIAlertView *alert = [[UIAlertView alloc] 
                        initWithTitle:title 
                        message:message
                        delegate:self 
                        cancelButtonTitle:NSLocalizedString(@"Cancel", @"キャンセル")
                        otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
  [alert show];
  [alert release];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

/**
 アラートのボタンをタップした時に呼び出される。
 OKをタップするとSafariを起動し、ownerSiteURLで指定されたURLを表示する
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  LOG_CURRENT_METHOD;
  LOG(@"押されたボタン：%d", buttonIndex);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	if(buttonIndex == 0) {
    LOG(@"Pressed Cancel");
	} else {
    LOG(@"Pressed OK");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ownerSiteURL]];
  }
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
