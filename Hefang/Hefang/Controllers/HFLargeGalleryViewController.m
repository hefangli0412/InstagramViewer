//
//  HFLargeGalleryViewController.m
//  Hefang
//
//  Created by Hefang Li on 10/27/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFLargeGalleryViewController.h"
#import "HFLargeImageCell.h"
#import "HFPhotoController.h"
#import "HFConstants.h"

@interface HFLargeGalleryViewController ()
@property (nonatomic, strong) UIView *whitepage;
@property (nonatomic) BOOL hasConnectionError;
@property (nonatomic, strong) NSArray *posts;
@end

@implementation HFLargeGalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBottomBackgroundColor;
    self.collectionView.backgroundColor = kTopBackgroundColor;
    
    self.hasConnectionError = NO;

    [self reloadPosts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.hasConnectionError) {
        [self reloadPosts];
    }
}

- (void)reloadPosts {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefault objectForKey:@"Insta_accessToken"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", accessToken];
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        if (data) {
            self.hasConnectionError = NO;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.posts = [responseDictionary valueForKeyPath:@"data"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.whitepage removeFromSuperview];
                [self.collectionView reloadData];
            });
        } else {
            self.posts = nil;
            self.hasConnectionError = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView addSubview:self.whitepage];
            });
        }
    }];
    [task resume];
}

- (void)setImageForCell:(HFLargeImageCell*)cell post:(NSDictionary*)post resolution:(HFImageResolution)resolution {
    [HFPhotoController imageForPost:post resolution:resolution completion:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"image : %@", image);
            [cell.customImageView setImage:image];
        });
    }];
}

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

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.posts count];
}

- (HFLargeImageCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HFLargeImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLargeGalleryCellIdentifier forIndexPath:indexPath];
    
    [self setImageForCell:cell post:self.posts[indexPath.row] resolution:HFStandardResolution];
    
    return cell;
}

@end
