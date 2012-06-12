//
//  MrAdminViewerAppDelegate.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright iphoneworld.jp 2009. All rights reserved.
//

#import "MrAdminViewerAppDelegate.h"
#import "RootViewController.h"
#import "MrAdminController.h"
#import "NKDefines.h"
#import "NKTools.h"
#import "Reachability.h"
#import "JSON.h"

@interface MrAdminViewerAppDelegate()
//- (void)networkLostAlert:(NSError *)error;
- (NSString *)hostName;
//- (void)copyInitialDatabase;
//- (BOOL)makeInitialDBFile;
@end

@implementation MrAdminViewerAppDelegate
@synthesize window;
@synthesize navigationController;
@synthesize remoteHostStatus;

+ (MrAdminViewerAppDelegate *)sharedMrAdminApp {
	return [[UIApplication sharedApplication] delegate];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  LOG_CURRENT_METHOD;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  [managedObjectContext release];
  [managedObjectModel release];
  [persistentStoreCoordinator release];
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

/**
 アプリケーションの起動直後
 */
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
  LOG_CURRENT_METHOD;
  LOG(@"Device ID:%@", [[UIDevice currentDevice] uniqueIdentifier]);
  LOG(@"DIR=%@", [self applicationDocumentsDirectory]);
  
  // prepare for use Reachability
	[[Reachability sharedReachability] setHostName:[self hostName]];
  [[Reachability sharedReachability] setNetworkStatusNotificationsEnabled:YES];
  [self updateStatus];
  NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
  [notify addObserver:self 
             selector:@selector(reachabilityChanged:) 
                 name:@"kNetworkReachabilityChangedNotification" 
               object:nil];
  
  NKTools* tool = [[[NKTools alloc] init] autorelease];
  [tool copyInitialDatabase];
  
  RootViewController* rootViewController;
  rootViewController = (RootViewController *)[navigationController topViewController];

  // Caution!! if not exist DB file, created it automatic.
	rootViewController.managedObjectContext = self.managedObjectContext;
	
	[window addSubview:[navigationController view]];
  [window makeKeyAndVisible];
  
//  [tool release];
}



/**
 applicationWillTerminate: 
 saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
  LOG_CURRENT_METHOD;
  NSError *error;
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle error.
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			//exit(-1);  // Fail
    } 
  }
}


#pragma mark -
#pragma mark Network

/**
 ネットワーク状況に変化が起きた時に呼ばれる
 */
- (void)reachabilityChanged:(NSNotification *)note {
  LOG_CURRENT_METHOD;
  [self updateStatus];
}

/**

 */
- (void)updateStatus {
  LOG_CURRENT_METHOD;
  // TODO: 次の動作の違いを調べる
	[[Reachability sharedReachability] remoteHostStatus]; // これを実行しておくこと
  self.remoteHostStatus = [[Reachability sharedReachability] internetConnectionStatus];
  
  if (self.remoteHostStatus == NotReachable) {
    NSLog(@"### Cannot Connect To Remote Host.");
    // NSError* error;
    // [self networkLostAlert:error];
  } else if (self.remoteHostStatus == ReachableViaCarrierDataNetwork) {
    LOG(@"### Reachable Via Carrier Data Network.");
  } else if (self.remoteHostStatus == ReachableViaWiFiNetwork) {
    LOG(@"### Reachable Via WiFi Network.");
  }
}


- (NSString *)hostName {
  LOG_CURRENT_METHOD;
	// Don't include a scheme. 'http://' will break the reachability checking.
	// Change this value to test the reachability of a different host.
  return @"adminkun00.appspot.com";
	// return @"nkts.local";
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
//- (IBAction)saveAction:(id)sender {
//	
//  NSError *error;
//  if (![[self managedObjectContext] save:&error]) {
//		// Handle error
//		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
//  }
//}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
  LOG_CURRENT_METHOD;

  if (managedObjectContext != nil) {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    // TODO: autoreleaseを使っても良いか確認する
    managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];
  }
  return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
  LOG_CURRENT_METHOD;
  if (managedObjectModel != nil) {
    return managedObjectModel;
  }
  managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
  return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  LOG_CURRENT_METHOD;

  if (persistentStoreCoordinator != nil) {
    return persistentStoreCoordinator;
  }
	
  NSURL *storeUrl = [NSURL fileURLWithPath:
                     [[self applicationDocumentsDirectory] 
                      stringByAppendingPathComponent:@"MrAdminViewer.sqlite"]];
	
	NSError *error;
  persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
                                initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                                configuration:nil 
                                                          URL:storeUrl 
                                                      options:nil 
                                                        error:&error]) {
    // Handle error
    NSLog(@"*** Error occured while processing 'persistentStoreCoordinator'.");
  }    
  return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
  LOG_CURRENT_METHOD;
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                       NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
}
@end

