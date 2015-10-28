//
//  HFProfileLargeImageLayout.m
//  Hefang
//
//  Created by Hefang Li on 10/27/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFProfileLargeImageLayout.h"

@implementation HFProfileLargeImageLayout

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
    self.minimumLineSpacing = 0.5f;
    
    self.headerReferenceSize = CGSizeMake(screenWidth, 270);
}

@end
