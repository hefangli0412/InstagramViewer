//
//  HFProfileHeaderView.h
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HFProfileHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *postsCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
