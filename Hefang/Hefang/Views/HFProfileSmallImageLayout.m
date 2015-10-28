//
//  HFProfileLayout.m
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#import "HFProfileSmallImageLayout.h"

@implementation HFProfileSmallImageLayout

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
    CGFloat itemWith = (screenWidth - 1) / 3;
    self.itemSize = CGSizeMake(itemWith, itemWith);
    self.minimumLineSpacing = 0.5f;
    self.minimumInteritemSpacing = 0.5f;
    
    self.headerReferenceSize = CGSizeMake(screenWidth, 260);
}

@end
