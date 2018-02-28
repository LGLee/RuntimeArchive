//
//  ViewController.m
//  RuntimeArchive
//
//  Created by lingo on 2018/2/28.
//  Copyright © 2018年 livefor. All rights reserved.
//

#import "ViewController.h"
#import "UserAccount.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UserAccount *user = [[UserAccount instance] user];
    self.accountTF.text = user.account;
    self.passwordTF.text = user.password;
}
- (IBAction)saveBtn:(id)sender {
    //请求网络异步回来
    UserAccount *user = [UserAccount instance];
    user.account = self.accountTF.text;
    user.password = self.passwordTF.text;
    BOOL b = [user save];
    NSLog(@"%d",b);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
