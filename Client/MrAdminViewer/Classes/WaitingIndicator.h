//
//  WaitingIndicator.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/08/12.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WaitingIndicator : UIView {
  UIActivityIndicatorView* indicatorView;
  UILabel* indicatorMessage;
}
@property (nonatomic, retain) UIActivityIndicatorView* indicatorView;
@property (nonatomic, retain) UILabel* indicatorMessage;
- (void)start;
- (void)stop;
@end
