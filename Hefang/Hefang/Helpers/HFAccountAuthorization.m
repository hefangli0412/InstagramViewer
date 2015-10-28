//
//  SIGAuthorizeInstagramAccount.m
//  shopitgram
//
//  Created by Hefang Li on 9/29/14.
//
//

#import "HFAccountAuthorization.h"
#import <SimpleAuth/SimpleAuth.h>

@implementation HFAccountAuthorization

+ (void)authorizeInstagramAccountAndCompletion:(void(^)())completion
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    __block NSString *accessToken = [userDefault objectForKey:@"Insta_accessToken"];
    
    if (accessToken != nil) {
        completion();
        return;
    }
    
    [SimpleAuth authorize:@"instagram"
                  options:@{@"scope": @[@"likes",@"comments",@"relationships"]}
               completion:^(id responseObject, NSError *error) {
                   if (error != NULL || responseObject == NULL) {
                       NSLog(@"Instagram login error: %@", error);
                       completion();
                       return;
                   }
                   NSString *userId = responseObject[@"uid"];
                   accessToken = responseObject[@"credentials"][@"token"];
                   [userDefault setObject:accessToken forKey:@"Insta_accessToken"];
                   [userDefault setObject:userId forKey:@"Insta_userId"];
                   [userDefault synchronize];
                   
//                 NSLog(@"response: %@", responseObject);
                   completion();
               }];
}

+ (void)logoutInstagramAccountAndCompletion:(void(^)())completion {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"Insta_accessToken"];
    [userDefault removeObjectForKey:@"Insta_userId"];
    [userDefault synchronize];
    
    completion();
}

+ (BOOL)userAuthorized
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefault objectForKey:@"Insta_accessToken"];
    
    return (accessToken != nil);
}

@end