//
//  AboutViewController.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/21.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
  UIButton* whatsnewButton;
  UIButton* contactButton;
  UIButton* gotoAdminkunButton;
}
@property (nonatomic, retain) IBOutlet UIButton* whatsnewButton;
@property (nonatomic, retain) IBOutlet UIButton* contactButton;
@property (nonatomic, retain) IBOutlet UIButton* gotoAdminkunButton;
- (IBAction)whatsnewAction:(id)sender;
- (IBAction)contactAction:(id)sender;
- (IBAction)gotoAdminkunAction:(id)sender;
@end
