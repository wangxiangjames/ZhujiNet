//
//  SelectDataController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/9/1.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "SelectDataController.h"
#import "CjwSheetView.h"

@interface SelectDataController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate>{
    CjwSheetView    *_sheet;
    UIDatePicker    *_datePicker;
    NSArray         *_arrayArea;
    
    UITextView      *_textView;
    UILabel         *_placeHolderLabel;
}

@end

@implementation SelectDataController

- (void)viewWillAppear:(BOOL)animated{
    if(self.type==select_data_area){
        [_sheet addContentView:[self createAreaView]];
        [_sheet showInView:self.view];
    }
    
    if(self.type==select_data_date){
        [_sheet addContentView:[self createDateView]];
        [_sheet showInView:self.view];
    }
    
    if(self.type==select_data_sex){
        [_sheet addContentView:[self createSexView]];
        [_sheet showInView:self.view];
    }
    
    if(self.type==select_data_report){
        [self createReportView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sheet = [[CjwSheetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak typeof(self) weakSelf = self;
    _sheet.blockCloseViewAction=^(){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    };
    
    if(self.type==select_data_sign){
        [self createSignView];
    }
}

-(void)actionOK:(id)sender{
    if(self.type==select_data_date){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.szResult=[dateFormatter stringFromDate:[_datePicker date]];
    }
    
    if(self.type==select_data_sex){
        self.szResult=[sender tag]==10?@"男":@"女";
    }
    
    if(self.type==select_data_sign || self.type==select_data_report){
        self.szResult=_textView.text;
    }
    
    if (self.blockResultAction) {
        self.blockResultAction(self.szResult);
    }
    [_sheet closeView];
}

-(void)actionCancel:(id)sender{
    [_sheet closeView];
}

-(void)createSignView{
    UIView *viewBg=[[UIView alloc] init];
    viewBg.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    [self.view addSubview:viewBg];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [self.view addSubview:line];
    
    UIButton* btnOk=[[UIButton alloc]init];
    [btnOk setTitle:@"保存" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOk];
    
    UILabel* title=[[UILabel alloc]init];
    title.text=@"个性签名";
    title.textAlignment=NSTextAlignmentCenter;
    title.textColor=[UIColor colorWithHexString:@"222222"];
    title.font=[UIFont systemFontOfSize:19];
    [self.view addSubview:title];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];

    UIView *textBg=[[UIView alloc]init];
    textBg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:textBg];
    
    //先创建个方便多行输入的textView
    _textView =[[UITextView alloc]init];
    _textView.font=[UIFont systemFontOfSize:18];
    _textView.delegate = self;
    _textView.text=self.inputData;
    //[_textView setUserInteractionEnabled:NO];
    
    //再创建个可以放置默认字的lable
    _placeHolderLabel = [[UILabel alloc]init];
    _placeHolderLabel.numberOfLines=0;
    _placeHolderLabel.font=[UIFont systemFontOfSize:18];
    if (_textView.text.length==0) {
        _placeHolderLabel.text = @"好想大声对世界说……";
    }
    _placeHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
    _placeHolderLabel.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview :_textView];
    [_textView addSubview:_placeHolderLabel];
    //_textView.contentInset= UIEdgeInsetsMake(0, 10, 0, 10);
    
    //----------------------------------------
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(120, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.right.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.left.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom).offset(14);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(150);
    }];
    
    [_placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView).offset(-2);
        make.left.equalTo(_textView).offset(6);
        make.size.mas_equalTo(CGSizeMake(200, 40));
    }];
    
    [textBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(_textView);
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    [_textView becomeFirstResponder];
}

-(void)createReportView{
    UIView *viewBg=[[UIView alloc] init];
    viewBg.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    [self.view addSubview:viewBg];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [self.view addSubview:line];
    
    UIButton* btnOk=[[UIButton alloc]init];
    [btnOk setTitle:@"提交" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOk];
    
    UILabel* title=[[UILabel alloc]init];
    title.text=@"不良信息举报";
    title.textAlignment=NSTextAlignmentCenter;
    title.textColor=[UIColor colorWithHexString:@"222222"];
    title.font=[UIFont systemFontOfSize:19];
    [self.view addSubview:title];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    UIView *textBg=[[UIView alloc]init];
    textBg.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:textBg];
    
    //先创建个方便多行输入的textView
    _textView =[[UITextView alloc]init];
    _textView.font=[UIFont systemFontOfSize:18];
    _textView.delegate = self;
    _textView.text=self.inputData;
    //[_textView setUserInteractionEnabled:NO];
    
    //再创建个可以放置默认字的lable
    _placeHolderLabel = [[UILabel alloc]init];
    _placeHolderLabel.numberOfLines=0;
    _placeHolderLabel.font=[UIFont systemFontOfSize:18];
    _placeHolderLabel.text = @"请具体说明问题，我们将尽快处理";
    
    _placeHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
    _placeHolderLabel.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview :_textView];
    [_textView addSubview:_placeHolderLabel];
    //_textView.contentInset= UIEdgeInsetsMake(0, 10, 0, 10);
    
    //----------------------------------------
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(120, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.right.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.left.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.height.mas_equalTo(150);
    }];
    
    [_placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView).offset(-2);
        make.left.equalTo(_textView).offset(6);
        make.width.equalTo(self.view);
        make.height.equalTo(@40);
    }];
    
    [textBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textView);
        make.right.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(_textView);
    }];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    [_textView becomeFirstResponder];
}

-(void)textViewDidChange:(UITextView*)textView
{
    if([_textView.text length] == 0){
        if(self.type==select_data_report){
            _placeHolderLabel.text = @"请具体说明问题，我们将尽快处理";
        }
        else{
            _placeHolderLabel.text = @"好想大声对世界说……";
        }
    }else{
        _placeHolderLabel.text = @"";
    }
}

//--------------------------------------------------------

-(UIView*)createSexView{
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 108+Height_NavBar)];
    [self.view addSubview:viewBg];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line];
    
    UIButton* btnMale=[[UIButton alloc]init];
    btnMale.tag=10;
    [btnMale setTitle:@"男" forState:UIControlStateNormal];
    [btnMale setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnMale.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnMale addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnMale];

    UIView *line2=[[UIView alloc] init];
    line2.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line2];
    
    UIButton* btnFemale=[[UIButton alloc]init];
    btnFemale.tag=11;
    [btnFemale setTitle:@"女" forState:UIControlStateNormal];
    [btnFemale setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnFemale.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnFemale addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnFemale];
    
    //----------------------------------------
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewBg);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, Height_NavBar));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 6));
    }];
    
    [btnFemale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];

    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnFemale.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [btnMale mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnFemale.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];
    
    return viewBg;
}

//--------------------------------------------------------

-(UIView *)createDateView{
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.4)];
    [self.view addSubview:viewBg];
    
    UIView *viewTitlebar=[[UIView alloc] init];
    viewTitlebar.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.1];
    [viewBg addSubview:viewTitlebar];
    
    UIButton* btnOk=[[UIButton alloc]init];
    [btnOk setTitle:@"确定" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnOk];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate *date = [dateFormatter dateFromString:@"2010-08-04 16:01:03"];
    if (!self.inputData) {
        self.inputData=[dateFormatter stringFromDate:[NSDate date]];
    }
    
    NSDate *date=[dateFormatter dateFromString:self.inputData];
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker setDate:date animated:YES];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];    //设置为中
    _datePicker.locale = locale;
    [viewBg addSubview:_datePicker];
    
    //----------------------------------------
    [viewTitlebar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(viewBg);
        make.top.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(viewBg).offset(-28);
        make.centerY.equalTo(viewTitlebar);
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(viewBg).offset(28);
        make.centerY.equalTo(viewTitlebar);
    }];
    
    [_datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewBg);
        make.top.equalTo(viewTitlebar.mas_bottom);
        make.bottom.equalTo(viewBg);
        make.right.equalTo(viewBg);
    }];
    return viewBg;
}

//--------------------------------------------------------

-(UIView*)createAreaView{
    _arrayArea = [NSArray arrayWithObjects:@"暨阳街道",@"浣东街道",@"陶朱街道",@"大唐镇",@"次坞镇",@"店口镇",@"阮市镇",@"江藻镇",@"枫桥镇",@"赵家镇",@"马剑镇",@"草塔镇",@"牌头镇",@"同山镇",@"安华镇",@"街亭镇",@"璜山镇",@"里浦镇",@"直埠镇",@"五泄镇",@"岭北镇",@"陈宅镇",@"王家井镇",@"应店街镇",@"山下湖镇",@"东白湖镇",@"东和乡", nil];
    
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.4)];
    [self.view addSubview:viewBg];
    
    UIView *viewTitlebar=[[UIView alloc] init];
    viewTitlebar.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.1];
    [viewBg addSubview:viewTitlebar];
    
    UIButton* btnOk=[[UIButton alloc]init];
    [btnOk setTitle:@"确定" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnOk];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    UIPickerView  *areaPicketView=[[UIPickerView alloc] init];
    areaPicketView.dataSource = self;
    areaPicketView.delegate = self;
    [viewBg addSubview:areaPicketView];
    
    NSInteger value = [_arrayArea indexOfObject: self.inputData];
    if(value != NSNotFound){
        [areaPicketView selectRow: value inComponent:0 animated:NO];
    }
    //----------------------------------------
    [viewTitlebar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(viewBg);
        make.top.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(viewBg).offset(-28);
        make.centerY.equalTo(viewTitlebar);
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(viewBg).offset(28);
        make.centerY.equalTo(viewTitlebar);
    }];
    
    [areaPicketView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewBg);
        make.top.equalTo(viewTitlebar.mas_bottom);
        make.bottom.equalTo(viewBg);
        make.right.equalTo(viewBg);
    }];
    return viewBg;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 1; // 返回1表明该控件只包含1列
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _arrayArea.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_arrayArea objectAtIndex:row];
}

// 当用户选中UIPickerViewDataSource中指定列和列表项时激发该方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component{
    self.szResult=[_arrayArea objectAtIndex:row];
    
    // 使用一个UIAlertView来显示用户选中的列表项
    /*UIAlertView* alert = [[UIAlertView alloc]
                          initWithTitle:@"提示"
                          message:[NSString stringWithFormat:@"你选中的图书是：%@", [_arrayArea objectAtIndex:row]]
                          delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    [alert show];*/
}

//--------------------------------------------------------

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
