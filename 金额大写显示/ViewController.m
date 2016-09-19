//
//  ViewController.m
//  金额大写显示
//
//  Created by 王奥东 on 16/9/13.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate>


@end

@implementation ViewController{
    NSArray * _capitalsOfSystem;//系统的大写金额显示内容
    NSArray * _capitals;//自定义大写金额的显示内容
    UILabel * _amountInWords;//大写金额显示的Label
}

//系统的大写金额显示内容
-(NSArray *)capitalsOfSystem{
    if (!_capitalsOfSystem) {
        _capitalsOfSystem = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];
    }
    return _capitalsOfSystem;
}

//自定义大写金额的显示内容
-(NSArray *)capitals{
    if (!_capitals) {
        //,@"百",@"仟",@"万",@"亿"
        _capitals = @[@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"镹",@"拾"];
    }
    return _capitals;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
  
    [self createCapitals];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(30, 180, 200, 20)];
    textField.backgroundColor = [UIColor whiteColor];
    textField.placeholder = @"请输入";
    textField.delegate = self;
    [self.view addSubview:textField];
    
    //大写金额显示的Label
    _amountInWords = [[UILabel alloc] initWithFrame:CGRectMake(textField.frame.origin.x, CGRectGetMaxY(textField.frame)+20, textField.frame.size.width, textField.frame.size.height)];
    
  
    [self.view addSubview:_amountInWords];
    
   
    
}

-(void)createCapitals {
    
    //系统的大写金额显示内容
    _capitalsOfSystem = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十"];
    
    //自定义大写金额的显示内容
    //,@"百",@"仟",@"万",@"亿"
    _capitals = @[@"壹",@"贰",@"叁",@"肆",@"伍",@"陆",@"柒",@"捌",@"镹",@"拾"];

}



#pragma mark - textField的此代理方法获取输入的内容
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //如果输入的内容符合要求，则获取数据内容并大写显示
    if ( [self isValidAboutInputText:textField shouldChangeCharactersInRange:range replacementString:string decimalNumber:2]) {
        
        
        
        //如果string.length为nil代表输入的是撤销
        NSString *subString;
        if (!string.length) {
            
            NSRange ranges;
            if (textField.text.length > 0) {
                ranges= NSMakeRange(0, textField.text.length - 1);
            }else{
                ranges = NSMakeRange(0, 0);
            }
            subString = [textField.text substringWithRange:ranges];
        }else{
            subString = textField.text;
            
        }
        
        //获取输入框中的内容
        double testNum = [[NSString stringWithFormat:@"%@%@",subString,string] doubleValue];
        
        
        //设置内容的显示格式为数字大写
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle =  kCFNumberFormatterSpellOutStyle;
        
        NSString *stringss = [formatter stringFromNumber:[NSNumber numberWithDouble: testNum]];
        
        //将系统的一二三四等替换成自定义的壹贰叁肆等
        for (NSUInteger j = 0; j < stringss.length; j++) {
            
            for (int i=0; i<self.capitalsOfSystem.count; i++) {
                //循环遍历字符串每个字符个对应的数值,适配ios7.0
                if ([[stringss substringWithRange:NSMakeRange(j, (NSUInteger)1)] isEqualToString:self.capitalsOfSystem[i]]) {
                    
                    stringss = [stringss stringByReplacingOccurrencesOfString:self.capitalsOfSystem[i] withString: self.capitals[i]];
                    
                }
            }
        }
        
        //拼接显示内容，后面+“元整”
        NSString *displayStr;
        
        //如果包含小数点,以小数点将1.1元分开
        for (NSUInteger j = 0; j < stringss.length; j++) {
            //如果包含小数点
            if ([[stringss substringWithRange:NSMakeRange(j, (NSUInteger)1)] isEqualToString:@"点"]) {
                //分开1.1元为1 1
                NSArray * wholeMoney = [stringss componentsSeparatedByString:@"点"];
                //获取角、分部分
                NSString *decimal = wholeMoney[1];
                //如果有分
                if (decimal.length == 2) {
                    //获取角
                    NSString *jiao = [decimal substringToIndex:1];
                    //获取分
                    NSString *fen = [decimal substringFromIndex:1];
                    
                    displayStr = [NSString stringWithFormat:@"%@元%@角%@分整",wholeMoney[0],jiao,fen];
                    break;
                }
                else {//只有角
                    //获取角
                    NSString *jiao = [decimal substringToIndex:1];
                    
                    displayStr = [NSString stringWithFormat:@"%@元%@角整",wholeMoney[0],jiao];
                    break;
                }
            }
            else {//如果是整数
                displayStr = [NSString stringWithFormat:@"%@元整",stringss];
            }
            
        }
        
        
        //设置显示大写金额的显示
        if ([displayStr isEqualToString:@"〇元整"]) {
            _amountInWords.text = @"";
        }else{
            _amountInWords.text = [displayStr stringByReplacingOccurrencesOfString:@"〇" withString:@"零"];;
        }
        
        _amountInWords.font = [UIFont systemFontOfSize:15];
        [_amountInWords sizeToFit];
        
        
        
        
        return YES;
    }else{
        return NO;
    }
    
}

//输入框中只能输入数字和小数点，且小数点只能输入一位，参数number 可以设置小数的位数
-(BOOL)isValidAboutInputText:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string decimalNumber:(NSInteger)number{
    
    NSScanner *scanner    = [NSScanner scannerWithString:string];
    NSCharacterSet *numbers;
    NSRange pointRange = [textField.text rangeOfString:@"."];
    if ( (pointRange.length > 0) && (pointRange.location < range.location  || pointRange.location > range.location + range.length) ){
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    }else{
        numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    }
    if ( [textField.text isEqualToString:@""] && [string isEqualToString:@"."] ){
        return NO;
    }
    short remain = number; //保留 number位小数
    NSString *tempStr = [textField.text stringByAppendingString:string];
    NSUInteger strlen = [tempStr length];
    if(pointRange.length > 0 && pointRange.location > 0){ //判断输入框内是否含有“.”。
        if([string isEqualToString:@"."]){ //当输入框内已经含有“.”时，如果再输入“.”则被视为无效。
            return NO;
        }
        if(strlen > 0 && (strlen - pointRange.location) > remain+1){ //当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。
            return NO;
        }
    }
    NSRange zeroRange = [textField.text rangeOfString:@"0"];
    if(zeroRange.length == 1 && zeroRange.location == 0){ //判断输入框第一个字符是否为“0”
        if(![string isEqualToString:@"0"] && ![string isEqualToString:@"."] && [textField.text length] == 1){ //当输入框只有一个字符并且字符为“0”时，再输入不为“0”或者“.”的字符时，则将此输入替换输入框的这唯一字符。
            textField.text = string;
            return NO;
        }else{
            if(pointRange.length == 0 && pointRange.location > 0){ //当输入框第一个字符为“0”时，并且没有“.”字符时，如果当此输入的字符为“0”，则视当此输入无效。
                if([string isEqualToString:@"0"]){
                    return NO;
                }
            }
        }
    }
    NSString *buffer;
    if ( ![scanner scanCharactersFromSet:numbers intoString:&buffer] && ([string length] != 0) ){
        return NO;
    }else{
        return YES;
    }
}





@end
