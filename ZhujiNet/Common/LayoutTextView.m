//
//  LayoutTextView.m
//  LayoutTextView
//
//  Created by JiaHaiyang on 16/7/6.
//  Copyright © 2016年 PlutusCat. All rights reserved.
//
#import "LayoutTextView.h"
#import "Common.h"

#define textViewFont [UIFont systemFontOfSize:16]

static CGFloat maxHeight = 80.0f;
static CGFloat leftFloat = 60.0f;
static CGFloat textViewHFloat = 36.0f;
static CGFloat sendBtnW = 60.0f;
static CGFloat sendBtnH = 35.0f;

@interface LayoutTextView()<UITextViewDelegate>
@property (assign, nonatomic) CGFloat superHight;
@property (assign, nonatomic) CGFloat textViewY;
@property (assign, nonatomic) CGFloat sendButtonOffset;
@property (assign, nonatomic) CGFloat keyBoardHight;
@property (assign, nonatomic) CGRect originalFrame;
@end

@implementation LayoutTextView

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame withCameraHide:NO];
}

- (instancetype)initWithFrame:(CGRect)frame withCameraHide:(BOOL)isCameraHide{
    self = [super initWithFrame:frame];
    if (self) {
        
        _originalFrame = frame;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth   = 0.5;
        self.layer.borderColor   = [UIColor colorWithHexString:@"dddddd"].CGColor;
        
        if (isCameraHide==NO) {
            UIButton *btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
            btnImg.frame = CGRectMake(5, 0, 50, 50);
            [btnImg setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
            [btnImg setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
            [btnImg addTarget:self action:@selector(btnCanmeraAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnImg];
        }
        
        UITextView *textView = [[UITextView alloc] init];
        textView.delegate    = self;
        textView.textColor   = [UIColor blackColor];
        textView.backgroundColor = [UIColor colorWithHexString:@"efefef"];
        textView.font = textViewFont;
        textView.layer.cornerRadius  = 18;
        
        textView.layer.masksToBounds = YES;
        textView.layer.borderWidth   = 0.5;
        textView.layer.borderColor   = [UIColor colorWithHexString:@"dddddd"].CGColor;
        textView.layoutManager.allowsNonContiguousLayout = NO;
        [self addSubview:textView];
        self.textView = textView;
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setEnabled:NO];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
        sendBtn.backgroundColor=[UIColor colorWithHexString:@"51a938"];
        sendBtn.layer.cornerRadius=5;
        [self addSubview:sendBtn];
        self.sendBtn =  sendBtn;

        CGFloat textViewX = leftFloat;
        CGFloat textViewW = Main_Screen_Width-(textViewX+sendBtnW+28);
        CGFloat textViewH = textViewHFloat;
        CGFloat textViewY = (self.frame.size.height-textViewH)*0.5;
        if (isCameraHide==NO) {
            _textView.frame = CGRectMake(textViewX, textViewY, textViewW, textViewH);
        }
        else{
            _textView.frame = CGRectMake(14, textViewY, SCREEN_WIDTH-55-sendBtnW, textViewH);
        }
        
        _textViewY = textViewY;
        _sendButtonOffset = (self.frame.size.height-sendBtnH)*0.5;
        _superHight = self.frame.size.height;
        
        _textView.textContainerInset = UIEdgeInsetsMake(8, 10, 8, 5);
    }
    return self;
}

- (void)sendBtnAction{
    if (_sendBlock) {
        _sendBlock(_textView);
    }
    [_textView resignFirstResponder];
}

- (void)btnCanmeraAction:(id)sender{
    if (_blockCanmeraAction) {
        _blockCanmeraAction(sender);
    }
    [_textView resignFirstResponder];
}



- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat sendBtnX = CGRectGetMaxX(_textView.frame)+14;
    //CGFloat sendBtnY = self.frame.size.height-(_sendButtonOffset+sendBtnH);
    _sendBtn.frame = CGRectMake(sendBtnX, 6, sendBtnW, sendBtnH);

}

#pragma mark - == UITextViewDelegate ==
- (void)textViewDidBeginEditing:(UITextView *)textView{
    //[_textView setContentInset:UIEdgeInsetsMake(0, 5, 0, 5)];
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text length]>0) {
        [self.sendBtn setEnabled:YES];
        [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"eeeeee"] forState:UIControlStateNormal];
    }
    else{
        [self.sendBtn setEnabled:NO];
        [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    }
    
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height<=frame.size.height) {

    }else{
        if (size.height>=maxHeight){
            size.height = maxHeight;
            textView.scrollEnabled = YES;   // 允许滚动
           
        }else{
            textView.scrollEnabled = NO;    // 不允许滚动
        }
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
    
    CGFloat superHeight = CGRectGetMaxY(textView.frame)+_textViewY;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x, Main_Screen_Height-(_keyBoardHight+superHeight), self.frame.size.width, superHeight)];
    }];
    
}

- (void)textViewDidChangeSelection:(UITextView *)textView{

    CGRect r = [textView caretRectForPosition:textView.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - textView.frame.size.height + r.size.height + 8, 0);
    if (textView.contentOffset.y < caretY && r.origin.y != INFINITY) {
        textView.contentOffset = CGPointMake(0, caretY);
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    textView.scrollEnabled = NO;
    CGRect frame = textView.frame;
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, textViewHFloat);
    [textView layoutIfNeeded];
    
    [_textView resignFirstResponder];
}

#pragma mark - == 键盘弹出事件 ==
- (void)keyboardWasShow:(NSNotification*)notification{
    
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (self.isNavHide) {
        _keyBoardHight = keyBoardFrame.size.height;
    }
    else{
        _keyBoardHight = keyBoardFrame.size.height+Height_NavBar;
    }
    

    
    [self translationWhenKeyboardDidShow:_keyBoardHight];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification{
    
    [self translationWhenKeyBoardDidHidden];
     self.hidden=YES;
}

- (void)translationWhenKeyboardDidShow:(CGFloat)keyBoardHight{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, Main_Screen_Height-(keyBoardHight+self.frame.size.height), self.frame.size.width, self.frame.size.height);
    }];
}

- (void)translationWhenKeyBoardDidHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = _originalFrame;
    }];
}
@end
