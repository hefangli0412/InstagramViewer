//
//  HFPhotoController.h
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HFConstants.h"

@interface HFPhotoController : NSObject

+ (void)imageForPost:(NSDictionary *)post resolution:(HFImageResolution)resolution completion:(void(^)(UIImage *image))completion;
+ (void)profilePictureFromURL:(NSString *)urlString completion:(void(^)(UIImage *image))completion;

@end
