//
//  AdminkunCell.m
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/18.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import "AdminkunCell.h"


@implementation AdminkunCell
@synthesize title = title_;
@synthesize overview = overview_;
@synthesize date = date_;
@synthesize imageView = imageView_;
@synthesize viewForBackground = viewForBackground_;

- (void)dealloc {
  [title_ release];
  [overview_ release];
  [date_ release];
  [imageView_ release];
  [viewForBackground_ release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    // Initialization code
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  // Configure the view for the selected state
}

@end
