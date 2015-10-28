//
//  HFConstants.m
//  Hefang
//
//  Created by Hefang Li on 10/26/15.
//  Copyright © 2015 Hefang Li. All rights reserved.
//

#ifndef HFContants_h
#define HFContants_h

#define loginControllerIdentifier @"HFLoginViewController"
#define rootControllerIdentifier @"HFRootTabViewController"

#define kLargeGalleryCellIdentifier @"HFLargeImageCell"
#define kSmallGalleryCellIdentifier @"HFSmallImageCell"
#define kChangableGalleryCellIdentifier @"HFChangableImageCell"
#define kProfileHeaderCellIdentifier @"HFProfileHeaderCell"

#define kBottomBackgroundColor [UIColor darkGrayColor]
#define kTopBackgroundColor [[UIColor blackColor]colorWithAlphaComponent:0.6]

typedef enum {
    HFStandardResolution = 0,
    HFLowResolution,
    HFThumbtailResolution
} HFImageResolution;

#endif


