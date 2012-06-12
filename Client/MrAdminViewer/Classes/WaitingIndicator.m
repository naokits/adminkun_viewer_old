//
//  WaitingIndicator.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/08/12.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "WaitingIndicator.h"


@implementation WaitingIndicator
@synthesize indicatorView;
@synthesize indicatorMessage;
/**
 コミック画像受信中のインジケータを表示
 */
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAlpha:0.7];
    
    indicatorView = [[UIActivityIndicatorView alloc] 
                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [self addSubview:indicatorView];
    // [indicatorView setFrame:CGRectMake ((320/2)-20, (480/2)-20, 40, 40)];
    [indicatorView setFrame:CGRectMake (160-20,160-20,40,40)];

    indicatorMessage = [[UILabel alloc] initWithFrame:CGRectMake(120, 200, 270, 30)];
    [indicatorMessage setBackgroundColor:[UIColor clearColor]];
    indicatorMessage.font = [UIFont systemFontOfSize:16.0];
    indicatorMessage.textColor = [UIColor blackColor];
    indicatorMessage.text = NSLocalizedString(@"Loading...", @"読み込み中...");
    [self addSubview:indicatorMessage];
                        
    [indicatorView startAnimating];
    // [indicatorView release];
  }
  return self;
}


- (void)start {
  [indicatorView startAnimating];
}


- (void)stop {
  [indicatorView stopAnimating];
  [indicatorView removeFromSuperview];
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
  [indicatorMessage release];
  [indicatorView release];
  [super dealloc];
}


@end
