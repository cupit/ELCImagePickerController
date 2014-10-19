//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCConsole.h"
#import "ELCOverlayImageView.h"

@interface ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTapped:)];
        longRecognizer.minimumPressDuration = 0.4;
        [self addGestureRecognizer:longRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
    }
    return self;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
    for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
    }
    for (ELCOverlayImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
    }
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {
        
        ELCAsset *asset = [_rowAssets objectAtIndex:i];
        
        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.asset.thumbnail];
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:asset.asset.thumbnail]];
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            ELCOverlayImageView *overlayView = [[ELCOverlayImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    CGRect frame = CGRectMake(startX, 2, 75, 75);
    
    for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            if (asset.selected) {
                asset.index = [[ELCConsole mainConsole] currIndex];
                [overlayView setIndex:asset.index+1];
                [[ELCConsole mainConsole] addIndex:asset.index];
            }
            else
            {
                [[ELCConsole mainConsole] removeIndex:asset.index];
            }
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}


- (void)cellLongTapped:(UITapGestureRecognizer *)longRecognizer
{
    if (longRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [longRecognizer locationInView:self];
        int c = (int32_t)self.rowAssets.count;
        CGFloat totalWidth = c * 75 + (c - 1) * 4;
        CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
        
        CGRect frame = CGRectMake(startX, 2, 75, 75);
        
        for (int i = 0; i < [_rowAssets count]; ++i) {
            if (CGRectContainsPoint(frame, point)) {
                ELCAsset *asset = [_rowAssets objectAtIndex:i];
                
                if ([self.cellDelegate respondsToSelector: @selector(longPressForAsset:)])
                {
                    [self.cellDelegate longPressForAsset: asset];
                }
                
                break;
            }
            
            frame.origin.x = frame.origin.x + frame.size.width + 4;
        }
    }
}


- (void)layoutSubviews
{
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX = (self.bounds.size.width - totalWidth) / 2;
    
    CGRect frame = CGRectMake(startX, 2, 75, 75);
    
    for (int i = 0; i < [_rowAssets count]; ++i) {
        UIImageView *imageView = [_imageViewArray objectAtIndex:i];
        [imageView setFrame:frame];
        [self addSubview:imageView];
        
        ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
        
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}


@end
