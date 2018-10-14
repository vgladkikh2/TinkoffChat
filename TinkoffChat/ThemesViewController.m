//
//  ThemesViewController.m
//  TinkoffChat
//
//  Created by me on 14/10/2018.
//  Copyright © 2018 gladkikh. All rights reserved.
//

#import "ThemesViewController.h"

@interface ThemesViewController ()

@end

@implementation ThemesViewController

@synthesize delegate;
@synthesize model; // = _model

- (IBAction)buttonTheme1Touched:(id)sender {
    self.view.backgroundColor = self.model.theme1;
    [self.delegate themesViewController:self didSelectTheme:self.model.theme1];
}
- (IBAction)buttonTheme2Touched:(id)sender {
    self.view.backgroundColor = self.model.theme2;
    [self.delegate themesViewController:self didSelectTheme:self.model.theme2];
}
- (IBAction)buttonTheme3Touched:(id)sender {
    self.view.backgroundColor = self.model.theme3;
    [self.delegate themesViewController:self didSelectTheme:self.model.theme3];
}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [[Themes alloc] init];
    self.model.theme1 = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.model.theme2 = [UIColor colorWithRed:0.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.model.theme3 = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

//-(void)dealloc {
//    self.model = nil;
//    [super dealloc];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
