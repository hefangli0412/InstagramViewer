//
//  HFLargeGalleryLayout.m
//  Hefang
//
//  Created by Hefang Li on 10/27/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFLargeGalleryLayout.h"

@implementation HFLargeGalleryLayout

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat itemWith = screenWidth;
    self.itemSize = CGSizeMake(itemWith, itemWith);
    self.minimumLineSpacing = 0.5;
    self.minimumInteritemSpacing = 0;
}

@end
