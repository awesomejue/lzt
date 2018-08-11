//
//  ParentsViewController.m
//  lzt
//
//  Created by 黄伟强 on 2017/10/17.
//  Copyright © 2017年 hwq. All rights reserved.
//

#import "ParentsViewController.h"

@interface ParentsViewController ()

@end

@implementation ParentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.navigationBar.translucent = NO;
    
}
-(void)tableHeaderDidTriggerRefresh {
    
}
- (void)endTableHeaderRefesh{
    
}
- (void)hideNavigationBar {
   // self.navigationController.navigationBar.hidden = YES;
     [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)apearNavigationBar {
    //self.navigationController.navigationBar.hidden = false;
     [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)setNaviTitle:(NSString *)title {
    self.navigationItem.title = NSLocalizedString(title, nil);
}
- (void)hideBackButtonText{
    
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:nil];
}
@end
