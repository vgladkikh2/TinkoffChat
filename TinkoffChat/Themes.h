//
//  Themes.h
//  TinkoffChat
//
//  Created by me on 14/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Themes : NSObject {
    UIColor* _theme1;
    UIColor* _theme2;
    UIColor* _theme3;
}

@property (strong, nonatomic) UIColor * theme1;
@property (strong, nonatomic) UIColor * theme2;
@property (strong, nonatomic) UIColor * theme3;
-(void)setTheme1:(UIColor * _Nonnull)theme1;
-(UIColor *)theme1;
-(void)setTheme2:(UIColor * _Nonnull)theme2;
-(UIColor *)theme2;
-(void)setTheme3:(UIColor * _Nonnull)theme3;
-(UIColor *)theme3;
@end

NS_ASSUME_NONNULL_END
