//
//  HFLoginViewController.m
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFLoginViewController.h"
#import "HFAccountAuthorization.h"
#import "HFAppDelegate.h"
#import "HFConstants.h"

@interface HFLoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property HFAppDelegate *appDelegate;
@end

@implementation HFLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBottomBackgroundColor;
    self.topView.backgroundColor = kTopBackgroundColor;
    
    self.appDelegate = [UIApplication sharedApplication].delegate;

    if (!self.appDelegate.firstTime) return;
    
    [HFAccountAuthorization authorizeInstagramAccountAndCompletion:^{
        if ([HFAccountAuthorization userAuthorized]) {
            NSLog(@"logged in");
            self.appDelegate.firstTime = NO;
            [self resetRootController];
        }
    }];
}

- (IBAction)loginClicked:(UIButton *)sender {
    [HFAccountAuthorization authorizeInstagramAccountAndCompletion:^{
        if ([HFAccountAuthorization userAuthorized]) {
            NSLog(@"logged in");
            [self resetRootController];
        }
    }];
}

- (void)resetRootController
{
    [self.appDelegate.window setRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:rootControllerIdentifier]];
}

@end
