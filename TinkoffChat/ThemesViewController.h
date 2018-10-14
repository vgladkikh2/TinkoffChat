//
//  ThemesViewController.h
//  TinkoffChat
//
//  Created by me on 14/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Themes.h"

NS_ASSUME_NONNULL_BEGIN

@class ThemesViewController;
@protocol ThemesViewControllerDelegate <NSObject>
- (void)themesViewController: (ThemesViewController *)controller didSelectTheme:(UIColor *)selectedTheme;
@end

@interface ThemesViewController : UIViewController

@property (weak, nonatomic) id<ThemesViewControllerDelegate> delegate;
@property (retain) Themes* model;

@end

NS_ASSUME_NONNULL_END
