//
//  VSMusicCell.m
//  VSCards
//
//  Created by Steven Chien on 2/2/15.
//  Copyright (c) 2015 stevenchien. All rights reserved.
//

#import "VSMusicCell.h"

@implementation VSMusicCell
@synthesize link;

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
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 4, 0, [UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 8)];
    [button addTarget:self action:@selector(tappedOnButton) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Link to Video" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor blackColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:button];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)tappedOnButton
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
}

@end
