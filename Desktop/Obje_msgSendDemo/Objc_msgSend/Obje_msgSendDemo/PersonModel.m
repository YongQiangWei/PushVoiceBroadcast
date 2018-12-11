//
//  PersonModel.m
//  Obje_msgSendDemo
//
//  Created by Yongqiang Wei on 2018/10/16.
//  Copyright © 2018年 Yongqiang Wei. All rights reserved.
//

#import "PersonModel.h"
#include <objc/runtime.h>

@implementation PersonModel
- (instancetype)initPersonWithName:(NSString *)name age:(NSInteger)age gender:(PersonGender)gender{
    if (self = [super init]) {
        _name = [name copy];
        _age = age;
        _gender = gender;
    }
    return self;
}
//- (void)buyCar:(NSString *)carName{
//    NSLog(@"%@b buy a new car %@",_name,carName);
//}
- (void)getPersonInformation{
    NSLog(@"person name: %@,age: %ld,gender:%ld",_name,_age,_gender);
}
@end
