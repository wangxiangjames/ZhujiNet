//
//  UpdatePhoneController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/4/5.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "UpdatePhoneController.h"
#import "AppDelegate.h"
#import "KeyChainManager.h"

@interface UpdatePhoneController ()<UITextFieldDelegate> {
    AppDelegate     *_app;
    UITextField     *_telField;
    UITextField     *_picField;
    UITextField     *_smsField;
    UIButton        *_btnSubmit;
    UIButton        *_btnSms;
    UIImageView     *_ivRandnum;
    NSString        *_mask;
    NSString        *_url;
}


@end

@implementation UpdatePhoneController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    
    if (self.isBindPage) {
        self.title = @"绑定手机号码";
        _url=URL_bind_mobile;
    }
    else{
        self.title = @"更换手机号码";
        _url=URL_edit_mobile;
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    _mask=[KeyChainManager getUUID];
    NSLog(@"cjw:%@",_mask);
    
    UILabel* telLable=[[UILabel alloc]init];
    telLable.text=@"新手机号码";
    telLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:telLable];
    
    UILabel* picLable=[[UILabel alloc]init];
    picLable.text=@"图形验证码";
    picLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:picLable];
    
    UILabel* smsLable=[[UILabel alloc]init];
    smsLable.text=@"短信验证码";
    smsLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:smsLable];
    
    _telField = [[UITextField alloc] init];
    _telField.placeholder = @"请输入新手机号码";
    _telField.font=[UIFont systemFontOfSize:16];
    _telField.keyboardType=UIKeyboardTypeNumberPad;
    _telField.inputAccessoryView = [self addToolbar];
    [self.view addSubview:_telField];
    
    _picField = [[UITextField alloc] init];
    _picField.placeholder = @"请输入图形验证码";
    _picField.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:_picField];
    
    _smsField = [[UITextField alloc] init];
    _smsField.placeholder = @"请输入手机短信验证码";
    _smsField.font=[UIFont systemFontOfSize:16];
    _smsField.keyboardType=UIKeyboardTypeNumberPad;
    _smsField.inputAccessoryView = [self addToolbar];
    [self.view addSubview:_smsField];
    
    _btnSubmit = [[UIButton alloc] init];
    _btnSubmit.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    _btnSubmit.layer.masksToBounds = YES;
    _btnSubmit.layer.cornerRadius = 5.f;
    _btnSubmit.enabled=NO;
    if (self.isBindPage){
        [_btnSubmit setTitle:@"绑定" forState:UIControlStateNormal];
    }
    else{
        [_btnSubmit setTitle:@"更新" forState:UIControlStateNormal];
    }
    [_btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * bgImage1 = [UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(1, 1)];
    UIImage * bgImage2 = [UIImage imageWithColor:[UIColor colorWithHexString:@"#dd0000"] size:CGSizeMake(1, 1)];
    [_btnSubmit setBackgroundImage:bgImage1 forState:UIControlStateNormal];
    [_btnSubmit setBackgroundImage:bgImage2 forState:UIControlStateHighlighted];
    [_btnSubmit addTarget:self action:@selector(btnSumbitClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSubmit];
    
    _btnSms= [[UIButton alloc] init];
    _btnSms.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
    _btnSms.layer.masksToBounds = YES;
    _btnSms.layer.cornerRadius = 5.f;
    [_btnSms setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_btnSms setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * bgImage3 = [UIImage imageWithColor:[UIColor colorWithHexString:@"#00cc00"] size:CGSizeMake(1, 1)];
    UIImage * bgImage4 = [UIImage imageWithColor:[UIColor colorWithHexString:@"#00aa00"] size:CGSizeMake(1, 1)];
    [_btnSms setBackgroundImage:bgImage3 forState:UIControlStateNormal];
    [_btnSms setBackgroundImage:bgImage4 forState:UIControlStateHighlighted];
    [_btnSms addTarget:self action:@selector(btnSmsClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSms];
    
    _ivRandnum=[[UIImageView alloc]init];
    [_ivRandnum sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?mask=%@&rand=%@",URL_imgcode,_mask,[CjwFun currentTimeStr]]]];
    _ivRandnum.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapAction:)];
    [_ivRandnum addGestureRecognizer:tap];
    [self.view addSubview:_ivRandnum];
    
    UIView *line1=[[UIView alloc]init];
    line1.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line1];
    
    UIView *line2=[[UIView alloc]init];
    line2.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line2];
    
    UIView *line3=[[UIView alloc]init];
    line3.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line3];
    
    UIView *line4=[[UIView alloc]init];
    line4.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line4];
    
    NSInteger top=30;
    if (self.isBindPage) {
        [self createNavView];
        top=Height_NavBar+30;
    }
    
    [telLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(top);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_telField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(telLable.mas_right).offset(5);
        make.top.mas_equalTo(telLable.mas_top);
        make.width.mas_equalTo(self.view).offset(-130);
        make.height.mas_equalTo(40);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(telLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [picLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(line1.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_ivRandnum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(picLable.mas_top);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(40);
    }];
    
    [_picField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(picLable.mas_right).offset(5);
        make.top.mas_equalTo(picLable.mas_top);
        make.right.mas_equalTo(_ivRandnum.mas_left);
        make.height.mas_equalTo(40);
    }];
    
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(picLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [smsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(line3.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_btnSms mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.top.mas_equalTo(smsLable.mas_top).offset(3);
        make.width.mas_equalTo(85);
        make.height.mas_equalTo(35);
    }];
    
    [_smsField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(smsLable.mas_right).offset(5);
        make.top.mas_equalTo(smsLable.mas_top);
        make.right.mas_equalTo(_btnSms.mas_left);
        make.height.mas_equalTo(40);
    }];
    
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(smsLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [_btnSubmit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(line4.mas_bottom).offset(20);
        make.right.mas_equalTo(self.view).offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    [_telField becomeFirstResponder];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)createNavView{
    UIView *viewBg=[[UIView alloc] init];
    viewBg.backgroundColor=[UIColor colorWithHexString:@"#df3031"];
    [self.view addSubview:viewBg];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [self.view addSubview:line];
    
    UIButton* btnOk=[[UIButton alloc]init];
    //[btnOk setTitle:@"保存" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    //[btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOk];
    
    UILabel* title=[[UILabel alloc]init];
    title.text=@"绑定手机号码";
    title.textAlignment=NSTextAlignmentCenter;
    title.textColor=[UIColor whiteColor];
    title.font=[UIFont systemFontOfSize:19];
    [self.view addSubview:title];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"关闭" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    //----------------------------------------
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, Height_NavBar));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(120, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title);
        make.right.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title);
        make.left.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
}

-(void)actionCancel:(id)sender{
    /*[UIView animateWithDuration:0.5f animations:^{
        _app.window.alpha = 0;
        _app.window.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        exit(0);
    }];*/
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:@"未绑定手机号码会退出登录，确定退出吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSLog(@"action = %@", action);
                                                              self->_app.userLoginStatus=login_status_reout;
                                                              self->_app.user.uid=0;
                                                              [self->_app.user logout];
                                                              [self dismissViewControllerAnimated:YES completion:nil];
                                                              //[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"action = %@", action);
                                                         }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------
-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_telField resignFirstResponder];
    [_picField resignFirstResponder];
    [_smsField resignFirstResponder];
}

- (void)imageViewTapAction:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"test");
    [_ivRandnum sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?mask=%@&rand=%@",URL_imgcode,_mask,[CjwFun currentTimeStr]]]];
}

- (void)btnSmsClick:(UIButton*)sender
{
    NSString* tel=_telField.text;
    if(tel.length == 0){
        [CjwFun showAlertMessage:@"手机号码不能为空！" currViewController:self];
        return;
    }
    if(![CjwFun checkTelNumber:tel]){
        [CjwFun showAlertMessage:@"错误的手机号码！" currViewController:self];
        return;
    }
    
    if (!self.isBindPage){
        if([_app.user.mobile isEqualToString:tel]){
            [CjwFun showAlertMessage:@"原手机号码无需更换" currViewController:self];
            return;
        }
    }
    
    NSString* picnum=_picField.text;
    if(picnum.length==0){
        [CjwFun showAlertMessage:@"您还未输入图形验证码！" currViewController:self];
        return;
    }
    _btnSms.enabled=NO;
    
    id param=@{@"mobile":tel,@"imgcode":picnum,@"mask":_mask,@"changemobile":@"1"};
    [_app.net request:URL_sms param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  NSLog(@"cjw:%@",dict);
                  if([dict[@"code"] integerValue]==0){
                      [self timeChanged:sender];
                      _btnSubmit.enabled=YES;
                      [MBProgressHUD showSuccess:@"短信已发送，请注意查收！" toView:self.view];
                  }
                  else{
                      _btnSms.enabled=YES;
                      [CjwFun showAlertMessage:dict[@"msg"] currViewController:self];
                      [_ivRandnum sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?mask=%@&rand=%@",URL_imgcode,_mask,[CjwFun currentTimeStr]]]];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  _btnSms.enabled=YES;
              }];
}

- (UIToolbar *)addToolbar {
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.tintColor = [UIColor blackColor];
    numberToolbar.backgroundColor = [UIColor lightGrayColor];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(viewTapped:)],
                           //[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    return numberToolbar;
}

- (void)btnSumbitClick:(UIButton*)sender
{
    NSString* tel=_telField.text;
    if(tel.length == 0){
        [CjwFun showAlertMessage:@"手机号码不能为空！" currViewController:self];
        return;
    }
    if(![CjwFun checkTelNumber:tel]){
        [CjwFun showAlertMessage:@"错误的手机号码！" currViewController:self];
        return;
    }
    
    if (!self.isBindPage){
        if([_app.user.mobile isEqualToString:tel]){
            [CjwFun showAlertMessage:@"原手机号码无需更换" currViewController:self];
            return;
        }
    }
    
    if(_smsField.text.length == 0){
        [CjwFun showAlertMessage:@"请输入短信验证码！" currViewController:self];
        return;
    }
    
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"请稍候"];
    
    id param=@{@"mobile":tel,@"verifycode":_smsField.text};
    [_app.net request:self url: _url param:param];
}

- (void)requestCallback:(id)response status:(id)status{
    [MBProgressHUD hideHUD];
    
    if([[status objectForKey:@"stat"] isEqual:@0]){
        NSDictionary *dict = (NSDictionary *)response;
        if([status[@"tag"] isEqual:@1]){
            if ([dict[@"code"] isEqual:@0]) {
                [_app.user save:response];
                [self.navigationController popViewControllerAnimated:YES];
                if (self.isBindPage) {
                    [MBProgressHUD showSuccess:@"绑定成功"];
                    self->_app.userLoginStatus=login_status_relogin;
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else{
                    [MBProgressHUD showSuccess:@"更新成功"];
                }
            }
        }
        if([status[@"tag"] isEqual:@0]){
            if ([dict[@"code"] isEqual:@0]) {
                [_app.net request:self url:URL_userinfo param:nil callTag:1];
            }
            else{
                [CjwFun showAlertMessage:dict[@"msg"] currViewController:self];
            }
        }
    }
    else{
        NSLog(@"%@",response);
        [MBProgressHUD showError:@"网络错误"];
    }
}

- (void)timeChanged:(UIButton*)sender
{
    __block int timeout=60; //倒计时时间
    __weak UIButton *blockSender = sender;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        __strong    UIButton *strongSender = blockSender;
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [strongSender setTitle:@"获取验证码" forState:UIControlStateNormal];
                strongSender.enabled = YES;
            });
        }else{
            int seconds = timeout % 61;
            NSString *strTime = [NSString stringWithFormat:@"%d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [strongSender setTitle:[NSString stringWithFormat:@"%@秒",strTime] forState:UIControlStateDisabled];
                strongSender.enabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

#pragma mark

- (void)telTextDidChanged:(UITextField *)textField
{
    // 有高亮，不做处理
    if (textField.markedTextRange) {
        return;
    }
    
    NSString *content = textField.text;
    if (content) {
        NSInteger limitLength = 4;
        
        if (content.length > limitLength) {
            content = [content substringToIndex:limitLength];
            textField.text = content;
        }
        if (textField.text.length == 4 ) {
            _btnSubmit.enabled = YES;
        }
        else{
            _btnSubmit.enabled = NO;
        }
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
