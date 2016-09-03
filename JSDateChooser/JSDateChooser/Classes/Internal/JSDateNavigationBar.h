//
//  JSDateNavigationBar.h
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JSDateNavigationBarCommand) {
    JSDateNavigationBarCommandNoCommand = 0,
    JSDateNavigationBarCommandPrevious,
    JSDateNavigationBarCommandNext
};

@interface JSDateNavigationBar : UIControl

@property (readonly) UILabel *textLabel;
@property (readonly) JSDateNavigationBarCommand lastCommand;

@end
