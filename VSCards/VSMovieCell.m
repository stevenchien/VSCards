//
//  VSMovieCell.m
//  VSCards
//
//  Created by Steven Chien on 2/2/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "VSMovieCell.h"

@implementation VSMovieCell
@synthesize mainCharImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    self.mainCharImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width)];
    self.mainCharImage.backgroundColor = [UIColor whiteColor];
    self.mainCharImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.mainCharImage];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
