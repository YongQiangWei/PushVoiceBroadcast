//
//  PersonModel.h
//  Obje_msgSendDemo
//
//  Created by Yongqiang Wei on 2018/10/16.
//  Copyright © 2018年 Yongqiang Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,PersonGender) {
    PersonGenderMan = 1,
    PersonGenderWoman
};
@interface PersonModel : NSObject
@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, assign) NSInteger age;
@property (nonatomic, readwrite, assign) PersonGender gender;

- (instancetype) initPersonWithName:(NSString *)name age:(NSInteger)age gender:(PersonGender) gender;
- (void) getPersonInformation;
//- (void) buyCar:(NSString *)carName;
@end

NS_ASSUME_NONNULL_END
