//
//  VSCardsCell.m
//  VSCards
//
//  Created by Steven Chien on 2/2/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "VSPlacesCell.h"

@implementation VSPlacesCell
@synthesize categoryLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect r;
        r = self.superview.frame;
        self.frame = r;
        [self setupCell];
    }
    return self;
}

- (void)setupCell
{
    self.categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 8)];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryLabel.textColor = [UIColor blackColor];
    [self addSubview:self.categoryLabel];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
