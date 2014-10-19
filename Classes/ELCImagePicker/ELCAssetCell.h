//
//  AssetCell.h
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELCAsset;

@protocol ELCAssetCellDelegate <NSObject>

@optional
- (void)longPressForAsset: (ELCAsset*)asset;

@end

@interface ELCAssetCell : UITableViewCell

@property (nonatomic, weak) id<ELCAssetCellDelegate> cellDelegate;
- (void)setAssets:(NSArray *)assets;

@end
