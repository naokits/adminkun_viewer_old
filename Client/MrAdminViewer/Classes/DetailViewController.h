//
//  DetailViewController.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/07/24.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MrAdmin;
@class WaitingIndicator;
@interface DetailViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
  UIWebView* detailView;
  WaitingIndicator* indicatorView; 
  MrAdmin* admin;
  UILabel* titleLabel;
  UILabel* overviewLabel;
  NSString* ownerSiteURL;
  
  UISegmentedControl *segmentControl;
}
@property (nonatomic, retain) IBOutlet UIWebView* detailView;
@property (nonatomic, retain) WaitingIndicator* indicatorView;
@property (nonatomic, retain) MrAdmin* admin;
@property (nonatomic, copy) NSString* ownerSiteURL;
@property (nonatomic, retain) UISegmentedControl *segmentControl;
@end
