//
//  MrAdminViewerAppDelegate.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright iphoneworld.jp 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface MrAdminViewerAppDelegate : NSObject <UIApplicationDelegate> {
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;	    
  NSPersistentStoreCoordinator *persistentStoreCoordinator;

  UIWindow *window;
  UINavigationController *navigationController;
  
  NetworkStatus remoteHostStatus;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
//@property (nonatomic, retain) RootViewController *rootViewController;
@property NetworkStatus remoteHostStatus;
+ (MrAdminViewerAppDelegate *)sharedMrAdminApp;
//- (IBAction)saveAction:sender;
- (void)updateStatus; // For Reachability
//- (void)deleteData:(NSManagedObject *)object;
@end

