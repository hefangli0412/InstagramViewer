//
//  HFPhotoController.m
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFPhotoController.h"
#import <SAMCache/SAMCache.h>

@implementation HFPhotoController

+ (void)imageForPost:(NSDictionary *)post resolution:(HFImageResolution)resolution completion:(void(^)(UIImage *image))completion {
    if (post == nil || completion == nil) {
        return;
    }
    
    NSString *key = [[NSString alloc] initWithFormat:@"%@-%d", post[@"id"], (int)resolution];
    NSLog(@"key: %@", key);
    
    UIImage *image = [[SAMCache sharedCache] imageForKey:key];
    if (image) {
        NSLog(@"image size: %f * %f", image.size.height, image.size.width);
        completion(image);
        return;
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[HFPhotoController getImageURL:post resolution:resolution]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [[SAMCache sharedCache] setImage:image forKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }];
    [task resume];
}

+ (NSURL *)getImageURL:(NSDictionary *)post resolution:(HFImageResolution)resolution {
    switch (resolution) {
        case HFStandardResolution:
            NSLog(@"width: %@", post[@"images"][@"standard_resolution"][@"width"]);
            NSLog(@"height: %@", post[@"images"][@"standard_resolution"][@"height"]);
            return [[NSURL alloc] initWithString:post[@"images"][@"standard_resolution"][@"url"]];
            break;
            
        case HFLowResolution:
            NSLog(@"width: %@", post[@"images"][@"low_resolution"][@"width"]);
            NSLog(@"height: %@", post[@"images"][@"low_resolution"][@"height"]);
            return [[NSURL alloc] initWithString:post[@"images"][@"low_resolution"][@"url"]];
            break;
            
        default:
            return [[NSURL alloc] initWithString:post[@"images"][@"thumbnail"][@"url"]];
            break;
    }
}

+ (void)profilePictureFromURL:(NSString *)urlString completion:(void(^)(UIImage *image))completion
{
    if (urlString == nil || completion == nil) {
        return;
    }
    
    NSString *key = [[NSString alloc] initWithFormat:@"profilePicture-%@", urlString];
    UIImage *image = [[SAMCache sharedCache] imageForKey:key];
    if (image) {
        completion(image);
        return;
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        UIImage *image = [[UIImage alloc] initWithData:data];
        [[SAMCache sharedCache] setImage:image forKey:key];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }];
    [task resume];
}

@end
