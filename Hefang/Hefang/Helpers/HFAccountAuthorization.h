//
//  SIGAuthorizeInstagramAccount.h
//  shopitgram
//
//  Created by Hefang Li on 9/29/14.
//
//

#import <Foundation/Foundation.h>

@interface HFAccountAuthorization : NSObject

+ (void)authorizeInstagramAccountAndCompletion:(void(^)())completion;
+ (BOOL)userAuthorized;
+ (void)logoutInstagramAccountAndCompletion:(void(^)())completion;

@end
