//
//  AdminkunCell.h
//  MrAdminViewer
//
//  Created by Naoki TSUTSUI on 09/09/18.
//  Copyright 2009 iphoneworld.jp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AdminkunCell : UITableViewCell {
  IBOutlet UILabel *title_;
  IBOutlet UILabel *overview_;
  IBOutlet UILabel *date_;
  IBOutlet UIImageView *imageView_;
  IBOutlet UIView *viewForBackground_;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *overview;
@property (nonatomic, retain) IBOutlet UILabel *date;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIView *viewForBackground;
@end
