//
//  MailComposerViewController.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/22.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface MailComposerViewController : UIViewController <MFMailComposeViewControllerDelegate> {
  UILabel* resultMessage;
}
@property (nonatomic, retain) IBOutlet UILabel* resultMessage;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
@end
