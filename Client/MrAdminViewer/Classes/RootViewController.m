//
//  RootViewController.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright iphoneworld.jp 2009. All rights reserved.
//

#import "RootViewController.h"
#import "MrAdminController.h"
#import "DetailViewController.h"
#import "MrAdmin.h"
#import "Base64EncDec.h"
#import "NKDefines.h"
#import "MrAdminViewerAppDelegate.h"
#import "WaitingIndicator.h"
#import "AdminkunCell.h"
#import "AboutViewController.h"

@interface RootViewController()
- (int)storedComicNumber:(NSManagedObjectContext *)context;
- (NSInteger)getComicNumber;
- (void)addIndexFromServer;
- (NSMutableArray *)showData:(NSManagedObjectContext *)managedObjectContext;
- (void)hoge;
- (void)ascendingOrder;
- (void)about;
- (void)networkLostAlertWithTitle:(NSString *)title message:(NSString *)message;

- (int)readComicNumber:(NSManagedObjectContext *)context;
@end

@implementation RootViewController
@synthesize fetchedResultsController, managedObjectContext;
@synthesize lang;
@synthesize indicatorView;
@synthesize refreshButton;
- (id) init
{
  LOG_CURRENT_METHOD;
  self = [super init];
  if (self != nil) {
    ascendingOrder = YES;
  }
  return self;
}

#pragma mark -
#pragma mark Handling Memory Warnings

- (void)didReceiveMemoryWarning {
  LOG_CURRENT_METHOD;
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
  LOG_CURRENT_METHOD;
  [lang release];
  [indicatorView release];
  [refreshButton release];
	[fetchedResultsController release];
	[managedObjectContext release];
  [super dealloc];
}

#pragma mark -
#pragma mark Managing the View

/**
 インスタンス生成直後に呼ばれる
 */
- (void)viewDidLoad {
  LOG_CURRENT_METHOD;
  [super viewDidLoad];
  self.lang = @"ja";
  self.title = NSLocalizedString(@"Comic List", @"連載一覧");
  
  // 昇順、降順切替ボタン
  UIBarButtonItem* ascendingOrderButton;
  ascendingOrderButton = [[UIBarButtonItem alloc] 
                        initWithTitle:NSLocalizedString(@"Ascend", @"旧着順") 
                        style:UIBarButtonItemStylePlain 
                        target:self 
                        action:@selector(ascendingOrder)];
  self.navigationItem.leftBarButtonItem = ascendingOrderButton;
  [ascendingOrderButton release];
  
  // Aboutボタン
  UIBarButtonItem* settingButton;
  settingButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:@selector(about)];
  self.navigationItem.rightBarButtonItem = settingButton;
  [settingButton release];

  // CoreDataからデータ読み出し
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
    NSLog(@"### Error occrred while fetch data from DataStore!");
	}
  
  // TODO: remoteHostStatusだと常にNotReachableになる理由を調査する
  //if ([[Reachability sharedReachability] remoteHostStatus] == NotReachable) {
  if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
    LOG(@"未接続");
  } else {
    LOG(@"接続中");
    [self addIndexFromServer];
  }
  
  [self readComicNumber:managedObjectContext];
}

- (void)viewDidUnload {
  LOG_CURRENT_METHOD;
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Category for NavigationBarButton

/**
 インジケータを表示し、コンテンツを生成する。
 CoreDataにデータ画像データが無い場合は@ITから取得する。
 FIXME: 適切なカテゴリ名に変更する
 */
- (void)hoge {
  // インジケータを表示する
  [refreshButton setEnabled:NO];

  indicatorView = [[[WaitingIndicator alloc] initWithFrame:[[self view] bounds]] autorelease];
  [self.view addSubview:indicatorView];
  [indicatorView start];

  // インジケータ表示中に別スレッドでコミックデータを取得し、HTMLを生成する
  [NSThread detachNewThreadSelector:@selector(addIndexFromServer) toTarget:self withObject:nil];
}

/**
 表示順（昇順、降順）を変更する
 */
- (void)ascendingOrder {
  LOG_CURRENT_METHOD;
  if (ascendingOrder == YES) {
    ascendingOrder = NO;
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Ascend", @"旧着順");
  } else {
    ascendingOrder = YES;
    self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Descend", @"新着順");
  }
  fetchedResultsController = nil;
  NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
    NSLog(@"### Error occrred while fetch data from DataStore!");
	}
  [self.tableView reloadData];
}

/**
 サポート
 */
- (void)about {
  AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
	[self.navigationController pushViewController:aboutViewController animated:YES];
	[aboutViewController release];  
}

/**
 サーバに保存されている記事数を返す
 */
- (NSInteger)getComicNumber {
  LOG_CURRENT_METHOD;
  MrAdminController* mradminController = [[[MrAdminController alloc] init] autorelease];
  int comicSize = [[mradminController getComicCount:@"ja"] intValue];
  return comicSize;
}

#pragma mark -
#pragma mark Responding to View Event

/**
 表示直前に処理される
 */
- (void)viewWillAppear:(BOOL)animated {
  LOG_CURRENT_METHOD;
  [super viewWillAppear:animated];
  
  [self.tableView reloadData];
  
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  LOG_CURRENT_METHOD;
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  LOG_CURRENT_METHOD;
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

/**
 記事一覧表示
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG_CURRENT_METHOD;
  
  /*
   static NSString *CellIdentifier = @"Cell";
   
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   if (cell == nil) {
   cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   }
   
   // Configure the cell.
   NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
   cell.textLabel.text = [[managedObject valueForKey:@"indexTitle"] description];
   
   return cell;
   */
  
  static NSString *CellID = @"AdminkunCell";
  
  AdminkunCell* cell;
  cell = (AdminkunCell*)[tableView 
                         dequeueReusableCellWithIdentifier:CellID];
  if (cell == nil) {
    LOG(@"Cell created");
    NSArray* nibObjects = [[NSBundle mainBundle] 
                           loadNibNamed:@"AdminkunCell" 
                           owner:nil 
                           options:nil];
    
    for (id currentObject in nibObjects) {
      if ([currentObject isKindOfClass:[AdminkunCell class]]) {
        cell = (AdminkunCell *)currentObject;
      }
    }
    
    // セルの背景をクリアする
    for (UIView *view in cell.contentView.subviews) {
			view.backgroundColor = [UIColor clearColor];
		}
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  }
  

  NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
  [cell.title setText:[managedObject valueForKey:@"indexTitle"]];
  [cell.overview setText:[managedObject valueForKey:@"indexOverview"]];
  
  NSString* base64Image = [managedObject valueForKey:@"indexImage"];
  NSData* data = [NSData dataWithBase64String:base64Image];
  UIImage* image = [[[UIImage alloc] initWithData:data] autorelease];
  [[cell imageView] setImage:image];
  

  // 既読の記事は白の背景色で表示する
  NSNumber* result = [managedObject valueForKey:@"readFlag"];
  NSNumber* judge = [NSNumber numberWithInt:1];
  if ([result compare:judge] == NSOrderedSame) {
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
  } else {
    cell.backgroundView.backgroundColor = [[[UIColor alloc] 
                                            initWithRed:0.2 
                                            green:0.2 
                                            blue:0.2 
                                            alpha:0.2]     
                                           autorelease];

  }
  return cell;
}

/**
 セルが選択されたときの処理
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG_CURRENT_METHOD;

  // 既読フラグをセットし保存する
  // TODO: マジックナンバーは後で修正すること
  NSNumber* flagNumber = [NSNumber numberWithInt:1];
  MrAdmin* selectedAdmin = (MrAdmin *)[self.fetchedResultsController objectAtIndexPath:indexPath];
  [selectedAdmin setValue:flagNumber forKey:@"readFlag"];
  NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
  
  // Save the context.
  NSError *error;
  if (![context save:&error]) {
    NSLog(@"*** Error occurred while save flag value: %@", error);
  } else {
    LOG(@"*** complete save flag value");
  }

  
  
  
  if ([selectedAdmin.bodyImage length] == 0 && 
      [[Reachability sharedReachability] remoteHostStatus] == NotReachable) {
    NSString* title = NSLocalizedString(@"Mr.Admin Viewer", @"アドミンくんビューワ");
    NSString* message = NSLocalizedString(@"No Internet connection", @"インターネットが利用できません");
    [self networkLostAlertWithTitle:title message:message];
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
  } else {

    DetailViewController *detailViewController;
    detailViewController = [[DetailViewController alloc] 
                            initWithNibName:@"DetailViewController" bundle:nil];
  
    // Pass the selected comic to the new view controller.
    detailViewController.admin = selectedAdmin;

    // Push the detail view controller
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
  }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/**
 記事一覧から削除を可能にする（今回は使用しない）
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG_CURRENT_METHOD;
    
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }   
}


/**
 記事一覧で表示される項目の移動を可能にする（今回は使用しない）
 */
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
  LOG_CURRENT_METHOD;
  // The table view should not be re-orderable.
  return NO;
}



#pragma mark -
#pragma mark DataStore Operaion


/**
 登録済データ数の数を返す
 */
- (int)storedComicNumber:(NSManagedObjectContext *)context {
  LOG_CURRENT_METHOD;
  NSMutableArray* results = nil;
  if (context == nil) {
    return 0;
  }
  
  NSFetchRequest* request;
  request = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity;
  entity = [NSEntityDescription entityForName:@"MrAdmin" inManagedObjectContext:context];
  [request setEntity:entity];
  
  NSPredicate *predicate;
  predicate = [NSPredicate predicateWithFormat:@"lang == %@", self.lang];
  [request setPredicate:predicate];
  
  // 値の大きい順に降順ソート
  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serialNumber" ascending: NO];
  
  NSArray *sortDescriptors;
  sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
  [request setSortDescriptors: sortDescriptors]; 
  [sortDescriptor release]; 
  [sortDescriptors release];
  
  NSError *error = nil;
  results = [[context executeFetchRequest:request error:&error] mutableCopy]; 
  if(results == nil) { 
    NSLog(@"### Error occurred while fetching data number!");
    NSLog(@"### %@", [error description]);
  } else { 
    [results autorelease]; 
  }
  
  int currentNumber = 0;
  if ([results count] == 0) {
    
  } else {
    MrAdmin* adminkun = (MrAdmin *)[results objectAtIndex:0];
    currentNumber = [[adminkun serialNumber] intValue];
  }
  // 次の数字は同じ出なければならない
  LOG(@"### Data number of stored local: %d", [results count]);
  LOG(@"### Last number of stored local: %d", currentNumber);
  [request release];
  return currentNumber;
}


/**
 データの挿入
 */
- (void)addIndexFromServer {
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  LOG_CURRENT_METHOD;
  
  int storedLocal = [self storedComicNumber:managedObjectContext];
  // TODO: サーバ側の数がローカル側の数より大きくなるケースが発生したら対応する。
  // int storedServer = [self getComicNumber];
  int downloadMax = 10;
  LOG(@"----------------------------------");
  LOG(@"### local stored number: %d", storedLocal);
  //LOG(@"### server stored number: %d", storedServer);
  LOG(@"----------------------------------");
  
  // Create a new instance of the entity managed by the fetched results controller.
  NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
  NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
  
  // If appropriate, configure the new managed object.
  MrAdminController* controller = [[[MrAdminController alloc] init] autorelease];
  for (int i=storedLocal+1; i<=(storedLocal + downloadMax); i++) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDictionary* comic = [controller fetchComic:self.lang number:i];
    // データの取得が失敗した場合の処理
    if (comic == nil) {
      [indicatorView stop];
      [indicatorView removeFromSuperview];
      [refreshButton setEnabled:YES];
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
      [pool release];
      return;
    }
    NSString* statusCode = (NSString *)[comic objectForKey:@"status_code"];
    LOG(@"statusCode:%@", statusCode);
    if ([statusCode compare:@"000"] != NSOrderedSame) { // 000は正常ステータス
      LOG(@"*** No more index data.");
      [indicatorView stop];
      [indicatorView removeFromSuperview];
      [refreshButton setEnabled:YES];
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
      return;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // LOG(@"*** description %@", [comic description]);
    
    NSManagedObject *insert = [NSEntityDescription 
                               insertNewObjectForEntityForName:[entity name] 
                               inManagedObjectContext:context];
    int tmpNumber = [[comic objectForKey:@"serial_number"] intValue];
    NSNumber* serialNumber = [NSNumber numberWithInt:tmpNumber];
    [insert setValue:serialNumber forKey:@"serialNumber"];
    [insert setValue:[comic objectForKey:@"index_title"] forKey:@"indexTitle"];
    [insert setValue:[comic objectForKey:@"index_overview"] forKey:@"indexOverview"];
    [insert setValue:[comic objectForKey:@"index_image_url"] forKey:@"indexImageUrl"];
    [insert setValue:[comic objectForKey:@"body_url"] forKey:@"bodyUrl"];
    [insert setValue:[comic objectForKey:@"body_image_url"] forKey:@"bodyImageUrl"];
    [insert setValue:[comic objectForKey:@"lang"] forKey:@"lang"];
    [insert setValue:[NSDate date] forKey:@"timeStamp"];
    
    // インデックスページのサムネール画像
    NSURL *url = [NSURL URLWithString:[comic objectForKey:@"index_image_url"]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* encodedImageWidhBase64;
    if ([data bytes] == 0) {
      NSLog(@"*** Not found Vol.%d image file.", i);
      [indicatorView stop];
      [indicatorView removeFromSuperview];
      [refreshButton setEnabled:YES];
      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
      [pool release];
      return;
    } else {
      //LOG(@"index image size is %d", [data bytes]);
      encodedImageWidhBase64 = [data stringEncodedWithBase64];
      [insert setValue:encodedImageWidhBase64 forKey:@"indexImage"];
    }
    // Save the context.
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"*** Error occurred while save data: %@", error);
    } else {
      LOG(@"*** complete save context");
    }
    [self.tableView reloadData];
  }
  // Stop indicator and remove view
  [indicatorView stop];
  [indicatorView removeFromSuperview];
  
  [pool release];
  [refreshButton setEnabled:YES];
}


#pragma mark -
#pragma mark FetchedResultsController

/**
 すでに読んだデータ数の数を返す
 */
- (int)readComicNumber:(NSManagedObjectContext *)context {
  LOG_CURRENT_METHOD;
  NSMutableArray* results = nil;
  if (context == nil) {
    return 0;
  }
  
  NSFetchRequest* request;
  request = [[NSFetchRequest alloc] init];
  
  NSEntityDescription *entity;
  entity = [NSEntityDescription entityForName:@"MrAdmin" inManagedObjectContext:context];
  [request setEntity:entity];
  
  NSPredicate *predicate;
  predicate = [NSPredicate predicateWithFormat:@"readFlag == %d", NO];
  [request setPredicate:predicate];
  
  // 値の大きい順に降順ソート
  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serialNumber" ascending: NO];
  
  NSArray *sortDescriptors;
  sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
  [request setSortDescriptors: sortDescriptors]; 
  [sortDescriptor release]; 
  [sortDescriptors release];
  
  NSError *error = nil;
  results = [[context executeFetchRequest:request error:&error] mutableCopy]; 
  if(results == nil) { 
    NSLog(@"### Error occurred while fetching data number!");
    NSLog(@"### %@", [error description]);
  } else { 
    [results autorelease]; 
    
    LOG(@"******* %@", [results description]);
  }
  
  int currentNumber = 0;
  if ([results count] == 0) {
    
  } else {
    MrAdmin* adminkun = (MrAdmin *)[results objectAtIndex:0];
    currentNumber = [[adminkun serialNumber] intValue];
  }
  // 次の数字は同じ出なければならない
  LOG(@"### Data number of stored local: %d", [results count]);
  LOG(@"### Last number of stored local: %d", currentNumber);
  [request release];
  return currentNumber;
}


- (NSFetchedResultsController *)fetchedResultsController {
  LOG_CURRENT_METHOD;
  // BM_START(__fetchedResultsController__);
  if (fetchedResultsController != nil) {
    return fetchedResultsController;
  }
    
  /* Set up the fetched results controller. */
  
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest;
  fetchRequest = [[NSFetchRequest alloc] init];

	// Edit the entity name as appropriate.
	NSEntityDescription *entity;
  entity = [NSEntityDescription 
            entityForName:@"MrAdmin" 
            inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
  // Set the batch size to a suitable number.
  // TODO: 適切なバッチサイズを調査する
	[fetchRequest setFetchBatchSize:20];

	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"serialNumber" ascending:ascendingOrder];
	NSArray *sortDescriptors;
  sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
  // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController;
  aFetchedResultsController = [[NSFetchedResultsController alloc] 
                               initWithFetchRequest:fetchRequest 
                               managedObjectContext:managedObjectContext 
                               sectionNameKeyPath:nil cacheName:@"Root"];
  aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
  // BM_END(__fetchedResultsController__);
	return fetchedResultsController;
}    



#pragma mark -
#pragma mark Delegate methods of NSFetchedResultsController

/*
 // NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView reloadData];
 }
 */


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */

/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	[self.tableView beginUpdates];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
//			[self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			// Reloading the section inserts a new row and ensures that titles are updated appropriately.
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}
*/



#pragma mark -

/**
 ネットワーク（Wifi）が使用できない事を知らせるアラート
 */
- (void)networkLostAlertWithTitle:(NSString *)title message:(NSString *)message {
  LOG_CURRENT_METHOD;
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title 
                                                  message:message 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}


/**
 データの表示（主にデバッグ用）
 */
- (NSMutableArray *)showData:(NSManagedObjectContext *)managedObjectContext {
  NSMutableArray* array = [NSMutableArray array];
//  [array release];
  return array;
}
@end

