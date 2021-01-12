//
//  CjwItem.m
//  CjwSchool
//
//  Created by chenjinwei on 16/3/20.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import "CjwItem.h"

@implementation CjwItem
- (CjwItem *) initWithDictionary:(NSDictionary *) dic {
    if(self=[super init]){
        self.type       =[dic[@"type"] integerValue];
        self.title      =dic[@"title"];
        self.subtitle   =dic[@"subtitle"];
        self.img        =dic[@"img"];
        self.author     =dic[@"author"];
        self.from       =dic[@"from"];
        self.dateline   =dic[@"dateline"];
        self.tag        =[dic[@"tag"] integerValue];
        self.url        =dic[@"url"];
        self.imagelist  =dic[@"imagelist"];
        self.comment    =dic[@"comment"];
        self.tid        =dic[@"tid"];
        self.praise     =dic[@"praise"];
        self.replies    =dic[@"replies"];
        self.isReplies  =NO;
        self.height     =0;
        //self.imagelist  =[NSMutableArray arrayWithCapacity:9];
        //self.comment    =[NSMutableArray arrayWithCapacity:2];
        
        //self.url_pic0   =dic[@"url_pic0"];
    }
    return self;
}

#pragma mark 初始化对象（静态方法）
+ (CjwItem *) staticWithDictionary:(NSDictionary *) dic {
    CjwItem *item=[[CjwItem alloc]initWithDictionary:dic];
    return item;
}
@end
