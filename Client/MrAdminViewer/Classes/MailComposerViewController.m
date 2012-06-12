//
//  MailComposerViewController.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/22.
//  Copyright (C) 2009 Naoki Tsutsui. All Rights Reserved.
//

/*
 Abstract: Manages the MailComposer view. 
 Launches an email composition interface inside the application if the iPhone OS is 3.0 or greater. 
 Launches the Mail application on the device if the iPhone OS version is lower than 3.0. 
 */

#import "MailComposerViewController.h"

@implementation MailComposerViewController
@synthesize resultMessage;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"メール送信";

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


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{

	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"アドミンくんビューワに関して"];

	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"naoki.tsutsui@gmail.com"]; 
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

	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			resultMessage.text = @"メール送信をキャンセルしました。";
			break;
		case MFMailComposeResultSaved:
			resultMessage.text = @"メールを保存しました。";
			break;
		case MFMailComposeResultSent:
			resultMessage.text = @"メールが送信されました。";
			break;
		case MFMailComposeResultFailed:
			resultMessage.text = @"メール送信が失敗しました。インターネット環境をご確認後、再度お送りください。";
			break;
		default:
			resultMessage.text = @"メールが送信されませんでした。";
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
#pragma mark Unload views

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{

	[super dealloc];
}

@end

