//
//  ZJResetPasswordController.m
//  ZjzxApp
//
//  Created by chenjinwei on 2017/4/5.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "ResetPasswordController.h"

@interface ResetPasswordController (){
    AppDelegate     *_app;
    
    UITextField     *_telField;
    UITextField     *_pswField;
    UIButton        *_loginButton;
}

@end

@implementation ResetPasswordController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.title = @"重置密码";
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    UILabel *phoneView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    phoneView.backgroundColor = [UIColor clearColor];
    phoneView.text = @"请输入旧密码:";
    phoneView.textAlignment = NSTextAlignmentCenter;
    phoneView.font = [UIFont boldSystemFontOfSize:15.f];
    phoneView.textColor = [UIColor colorWithHexString:@"#5e5e5e"];
    
    _telField = [[UITextField alloc] init];
    _telField.translatesAutoresizingMaskIntoConstraints=NO;
    _telField.secureTextEntry = YES;
    _telField.backgroundColor = [UIColor whiteColor];
    _telField.tintColor = [UIColor colorWithHexString:@"#DD2731"];
    _telField.placeholder = @"旧密码:";
    _telField.textAlignment = NSTextAlignmentLeft;
    _telField.textColor = [UIColor colorWithHexString:@"#5e5e5e"];
    _telField.borderStyle = UITextBorderStyleNone;
    _telField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _telField.keyboardType = UIKeyboardTypeNumberPad;
    _telField.returnKeyType = UIReturnKeyDone;
    _telField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _telField.autocorrectionType = UITextAutocorrectionTypeNo;
    _telField.leftView = phoneView;
    _telField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_telField];
    
    UILabel *pswView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    pswView.backgroundColor = [UIColor clearColor];
    pswView.text = @"设定新的密码:";
    pswView.textAlignment = NSTextAlignmentCenter;
    pswView.font = [UIFont boldSystemFontOfSize:15.f];
    pswView.textColor = [UIColor colorWithHexString:@"#5e5e5e"];
    
    _pswField = [[UITextField alloc] init];
    _pswField.translatesAutoresizingMaskIntoConstraints=NO;
    _pswField.secureTextEntry = YES;
    _pswField.backgroundColor = [UIColor whiteColor];
    _pswField.tintColor = [UIColor colorWithHexString:@"#DD2731"];
    _pswField.placeholder = @"新密码";
    _pswField.textAlignment = NSTextAlignmentLeft;
    _pswField.borderStyle = UITextBorderStyleNone;
    _pswField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _pswField.keyboardType = UIKeyboardTypeNumberPad;
    _pswField.returnKeyType = UIReturnKeyDone;
    _pswField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _pswField.autocorrectionType = UITextAutocorrectionTypeNo;
    _pswField.leftView = pswView;
    _pswField.leftViewMode = UITextFieldViewModeAlways;
    _pswField.rightViewMode = UITextFieldViewModeAlways;
    _pswField.textColor = [UIColor colorWithHexString:@"#5e5e5e"];
    [self.view addSubview:_pswField];
    
    _loginButton = [[UIButton alloc] init];
    _loginButton.translatesAutoresizingMaskIntoConstraints=NO;
    [_loginButton setTitle:@"提交" forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#DD2731"] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 5.f;
    [self.view addSubview:_loginButton];
    
    NSArray *constraints1=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_telField]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(_telField)];
    
    NSArray *constraints2=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_pswField]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(_pswField)];
    
    NSArray *constraints3=[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_loginButton]-10-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(_loginButton)];
    
    NSArray *constraints4=[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_telField(==45)]-1-[_pswField(==45)]-10-[_loginButton(==45)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:NSDictionaryOfVariableBindings(_telField,_pswField,_loginButton)];
    [self.view addConstraints:constraints1];
    [self.view addConstraints:constraints2];
    [self.view addConstraints:constraints3];
    [self.view addConstraints:constraints4];
}

-(void)setNavigation{
    UIButton *navBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBack setFrame:CGRectMake(0, 0, 28, 28)];
    [navBack setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [navBack addTarget:self action:@selector(onNavBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBack];
}

- (void)onNavBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loginButtonClick:(UIButton*)sender
{
    if (_telField.text.length == 0) {
        [MBProgressHUD showError:@"请输入旧密码"];
        return;
    }
    
    if (_pswField.text.length == 0) {
        [MBProgressHUD showError:@"请输入新密码"];
        return;
    }
    
    [self.view endEditing:YES];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"changepwd",@"type",
                                     _telField.text,@"oldpwd",
                                     _pswField.text,@"newpwd",
                                     nil];
    [MBProgressHUD showMessage:@"请稍候"];
    _app = [AppDelegate getApp];
    [_app.net request:self url:URL_userinfo_update param:paramDic];
    
}

- (void)requestCallback:(id)response status:(id)status{
    NSLog(@"%@",response);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([[status objectForKey:@"stat"] isEqual:@0]){
        NSDictionary *dict = (NSDictionary *)response;
        if ([dict[@"code"] isEqual:@0]) {
            [MBProgressHUD showSuccess:@"修改成功"];
            [AppDelegate getApp].user.password=_pswField.text;
            [User autoLogin];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [MBProgressHUD showError:dict[@"msg"]];
        }
    }
    else{
        NSLog(@"%@",response);
        [MBProgressHUD showError:@"失败"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
