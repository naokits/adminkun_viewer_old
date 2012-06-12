//
//  RootViewController.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/22.
//  Copyright iphoneworld.jp 2009. All rights reserved.
//
@class WaitingIndicator;
@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
  NSString* lang;
  WaitingIndicator* indicatorView; 
  UIBarButtonItem* refreshButton;
  BOOL ascendingOrder;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, copy) NSString* lang;
@property (nonatomic, retain) WaitingIndicator* indicatorView;
@property (nonatomic, retain) UIBarButtonItem* refreshButton;
@end
