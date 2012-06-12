//
//  AboutViewController.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/21.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "AboutViewController.h"
//#import "MailComposerViewController.h"
#import "NKDefines.h"

@interface AboutViewController()
- (void)mailAlertWithMessaeg:(NSString *)message;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;
@end


@implementation AboutViewController
@synthesize whatsnewButton;
@synthesize contactButton;
@synthesize gotoAdminkunButton;

- (IBAction)whatsnewAction:(id)sender {

  // 現在の言語環境を取得
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
  NSString *currentLanguage = [languages objectAtIndex:0];
  LOG(@"### Current Language：%@", currentLanguage);
  
  NSString* url;
  if ([currentLanguage compare:@"ja"] == NSOrderedSame) {
    url = @"http://adminkun00.appspot.com/support/";
    // url = @"http://nkts.local/~naokits/Demo/"; // for debug
  } else {
    url = @"http://adminkun00.appspot.com/support_en/";
  }
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)contactAction:(id)sender {
/*
  NSLog(@"contactAction");
  MailComposerViewController* mailComposerViewController = [[MailComposerViewController alloc] initWithNibName:@"MailComposerViewController" bundle:nil];
	[self.navigationController pushViewController:mailComposerViewController animated:YES];
	[mailComposerViewController release];
*/
  
  // This sample can run on devices running iPhone OS 2.0 or later  
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
	// So, we must verify the existence of the above class and provide a workaround for devices running 
	// earlier versions of the iPhone OS. 
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
			[self displayComposerSheet];
		} else {
			[self launchMailAppOnDevice];
		}
	} else {
		[self launchMailAppOnDevice];
	}
  
}

- (IBAction)gotoAdminkunAction:(id)sender {
  NSLog(@"gotoAdminkunAction");
  NSString* url = @"http://www.atmarkit.co.jp/fwin2k/itpropower/admin-kun/index/";
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [whatsnewButton release];
  [contactButton release];
  [gotoAdminkunButton release];
  [super dealloc];
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
  
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
  NSString* subject = NSLocalizedString(@"About Mr.Admin Viewer", @"アドミンくんビューワについて");
	[picker setSubject:subject];
  
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"naokits.support@gmail.com"]; 
  //	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
  //	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
	[picker setToRecipients:toRecipients];
  //	[picker setCcRecipients:ccRecipients];	
  //	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
  //	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
  //  NSData *myData = [NSData dataWithContentsOfFile:path];
  //	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
	// Fill out the email body text
  //	NSString *emailBody = @"It is raining in sunny California!";
  //	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
  [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
  NSString* message;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
      message = NSLocalizedString(@"Result: canceled", @"メール送信をキャンセルしました。");
      [self mailAlertWithMessaeg:message];
			break;
		case MFMailComposeResultSaved:
      message = NSLocalizedString(@"Result: saved", @"メールを保存しました。");
      [self mailAlertWithMessaeg:message];
			break;
		case MFMailComposeResultSent:
      message = NSLocalizedString(@"Result: sent", @"メールが送信されました。");
      [self mailAlertWithMessaeg:message];
			break;
		case MFMailComposeResultFailed:
      message = NSLocalizedString(@"Result: failed", @"メール送信が失敗しました。インターネット環境をご確認後、再度お送りください。");
      [self mailAlertWithMessaeg:message];
			break;
		default:
      message = NSLocalizedString(@"Result: not sent", @"メールが送信されませんでした。");
      [self mailAlertWithMessaeg:message];
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
	NSString *body = @"&body=It is raining in sunny California!";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark -
#pragma mark Alert

/**
 ネットワーク（Wifi）が使用できない事を知らせるアラート
 */
- (void)mailAlertWithMessaeg:(NSString *)message {
  LOG_CURRENT_METHOD;
  NSString* title = NSLocalizedString(@"Mr.Admin Viewer",  @"アドミンくんビューワ");
  UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message 
                                                 delegate:self 
                                        cancelButtonTitle:NSLocalizedString(@"OK", nil) 
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

@end
