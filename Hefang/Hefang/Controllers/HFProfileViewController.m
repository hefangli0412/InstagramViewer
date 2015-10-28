//
//  HFProfileViewController.m
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFProfileViewController.h"
#import "HFPhotoController.h"
#import "HFChangableImageCell.h"
#import "HFProfileHeaderView.h"
#import "HFAccountAuthorization.h"
#import "HFProfileLargeImageLayout.h"
#import "HFProfileSmallImageLayout.h"
#import "HFAppDelegate.h"
#import "HFConstants.h"

@interface HFProfileViewController ()
@property (nonatomic) NSArray *posts;
@property (nonatomic) NSDictionary *userData;
@property (nonatomic) BOOL isLarge;
@property (nonatomic, strong) HFProfileLargeImageLayout *largeLayout;
@property (nonatomic, strong) HFProfileSmallImageLayout *smallLayout;
@property (nonatomic, strong) UIView *whitepage;
@property (nonatomic) BOOL hasConnectionError;
@property (nonatomic, weak) UISegmentedControl *segControl;
@end

@implementation HFProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBottomBackgroundColor;
    self.collectionView.backgroundColor = kTopBackgroundColor;

    self.isLarge = NO;
    self.hasConnectionError = NO;

    [self downloadUserInfo];
    [self downloadUserPosts];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeToLargeGalleryView)];
    swipeRight.numberOfTouchesRequired = 1;
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.collectionView addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeToSmallGalleryView)];
    swipeLeft.numberOfTouchesRequired = 1;
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.collectionView addGestureRecognizer:swipeLeft];
    
    self.largeLayout = [[HFProfileLargeImageLayout alloc] init];
    self.smallLayout = [[HFProfileSmallImageLayout alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.hasConnectionError) {
        [self downloadUserInfo];
        [self downloadUserPosts];
    }
}

- (void)changeToLargeGalleryView {
    NSLog(@"swipe right - larger photos");
    
    self.isLarge = YES;
    self.segControl.selectedSegmentIndex = 1;
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView setCollectionViewLayout:self.largeLayout animated:YES completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [weakSelf.collectionView performBatchUpdates:^{
                [weakSelf.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            } completion:nil];
        });
    }];
}

- (void)changeToSmallGalleryView {
    NSLog(@"swipe left - smaller photos");
    
    self.isLarge = NO;
    self.segControl.selectedSegmentIndex = 0;

    [self.collectionView setCollectionViewLayout:self.smallLayout animated:YES completion:^(BOOL finished) {}];
}

- (void)setImageForCell:(HFChangableImageCell*)cell post:(NSDictionary*)post resolution:(HFImageResolution)resolution {
    [HFPhotoController imageForPost:post resolution:resolution completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"image : %@", image);
            [cell.customImageView setImage:image];
        });
    }];
}


- (void)goBackToLoginViewController
{
    HFAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:loginControllerIdentifier]];
}

#pragma mark NetWorking

- (void)downloadUserInfo
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefault objectForKey:@"Insta_accessToken"];
    NSString *userId = [userDefault objectForKey:@"Insta_userId"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/users/%@/?access_token=%@", userId, accessToken];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSString *text = [[NSString alloc] initWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"text: %@", text);
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        
        if (data) {
            self.hasConnectionError = NO;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.userData = [responseDictionary valueForKeyPath:@"data"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.whitepage removeFromSuperview];
                [self.collectionView reloadData];
            });
        } else {
            self.userData = nil;
            self.hasConnectionError = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView addSubview:self.whitepage];
            });
        }
        
    }];
    [task resume];
}

- (void)downloadUserPosts {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefault objectForKey:@"Insta_accessToken"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *userId = [userDefault objectForKey:@"Insta_userId"];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/users/%@/media/recent/?access_token=%@", userId, accessToken];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        if (data) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.posts = [responseDictionary valueForKeyPath:@"data"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        } else {
            self.posts = nil;
        }
        
    }];
    [task resume];
}

#pragma mark User Actions

- (IBAction)segmentedControlClicked:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        if (self.isLarge) {
            [self changeToSmallGalleryView];
        }
    } else {
        if (!self.isLarge) {
            [self changeToLargeGalleryView];
        }
    }
}

- (IBAction)logoutClicked:(UIButton *)sender {
    NSLog(@"logged out.");
    [HFAccountAuthorization logoutInstagramAccountAndCompletion:^{
        // clear http cache
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        
        [self goBackToLoginViewController];
    }];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.posts count];
}

- (HFChangableImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HFChangableImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kChangableGalleryCellIdentifier forIndexPath:indexPath];
    cell.customImageView.image = nil;
    if (self.isLarge) {
        [self setImageForCell:cell post:self.posts[indexPath.row] resolution:HFStandardResolution];
    } else {
        [self setImageForCell:cell post:self.posts[indexPath.row] resolution:HFLowResolution];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HFProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kProfileHeaderCellIdentifier forIndexPath:indexPath];
    
    self.segControl = headerView.segmentedControl;
    
    [self addBorderToLabel:headerView.postsCount];
    [self addBorderToLabel:headerView.followersCount];
    [self addBorderToLabel:headerView.followingCount];
    [self customizeLabel:headerView.username];
    [self addBorderToButton:headerView.logoutButton];
    
    if (self.userData != nil) {
        // paragraph style
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 4.0f;
        
        // larger font
        UIFont *largerFont = [UIFont fontWithName:@"Helvetica" size:22.0f];
        
        // smaller font
        UIFont *smallerFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
        
        // username font
        UIFont *usernameFont = [UIFont fontWithName:@"ArialHebrew" size:18.0f];
        
        NSMutableAttributedString * usernameString = [[NSMutableAttributedString alloc] initWithString:self.userData[@"username"]];
        NSInteger len = usernameString.length;
        [usernameString addAttribute:NSFontAttributeName value:usernameFont range:NSMakeRange(0, len)];
        headerView.username.attributedText = usernameString;

        NSMutableAttributedString * postsCountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nPOSTS", self.userData[@"counts"][@"media"]]];
        len = postsCountString.length;
        [postsCountString addAttribute:NSFontAttributeName value:largerFont range:NSMakeRange(0, len - 5)];
        [postsCountString addAttribute:NSFontAttributeName value:smallerFont range:NSMakeRange(len - 5, 5)];
        [postsCountString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, len)];
        headerView.postsCount.attributedText = postsCountString;
        
        NSMutableAttributedString * followersCountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWERS", self.userData[@"counts"][@"followed_by"]]];
        len = followersCountString.length;
        [followersCountString addAttribute:NSFontAttributeName value:largerFont range:NSMakeRange(0, len - 9)];
        [followersCountString addAttribute:NSFontAttributeName value:smallerFont range:NSMakeRange(len - 9, 9)];
        [followersCountString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, len)];
        headerView.followersCount.attributedText = followersCountString;
        
        NSMutableAttributedString * followingCountString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\nFOLLOWING", self.userData[@"counts"][@"follows"]]];
        len = followingCountString.length;
        [followingCountString addAttribute:NSFontAttributeName value:largerFont range:NSMakeRange(0, len - 9)];
        [followingCountString addAttribute:NSFontAttributeName value:smallerFont range:NSMakeRange(len - 9, 9)];
        [followingCountString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, len)];
        headerView.followingCount.attributedText = followingCountString;
        
        [HFPhotoController profilePictureFromURL:self.userData[@"profile_picture"] completion:^(UIImage *image) {
            UIImageView *imageView = headerView.userPhoto;
            imageView.layer.cornerRadius = imageView.frame.size.height /2;
            imageView.layer.masksToBounds = YES;
            imageView.image = image;
        }];
    }
    
    return headerView;
}

#pragma mark UI Adjustment

- (void)addBorderToLabel:(UILabel *)label {
    label.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    label.layer.borderWidth = 1.0f;
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
}

- (void)customizeLabel:(UILabel *)label {
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
}

- (void)addBorderToButton:(UIButton *)button {
    button.layer.cornerRadius = 5.0f;
    button.layer.masksToBounds = YES;
    
    button.backgroundColor = [UIColor whiteColor];
    button.tintColor = [UIColor darkGrayColor];
}

#pragma mark Helpers

- (UIView *)whitepage {
    if (!_whitepage) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        // username font
        UIFont *messageFont = [UIFont fontWithName:@"Georgia" size:18.0f];
        
        _whitepage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, screenSize.width - 40, screenSize.height - 100)];
        [_whitepage setBackgroundColor:[UIColor whiteColor]];
        
        NSMutableAttributedString * message = [[NSMutableAttributedString alloc] initWithString:@"Connection Error"];
        NSInteger len = message.length;
        [message addAttribute:NSFontAttributeName value:messageFont range:NSMakeRange(0, len)];
        [message addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0,len)];
        label.attributedText = message;
        label.textAlignment = NSTextAlignmentCenter;
        
        [_whitepage addSubview:label];
    }
    return _whitepage;
}


@end
