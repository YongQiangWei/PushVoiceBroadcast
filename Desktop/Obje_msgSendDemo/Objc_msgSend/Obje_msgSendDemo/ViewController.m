//
//  ViewController.m
//  Obje_msgSendDemo
//
//  Created by Yongqiang Wei on 2018/10/16.
//  Copyright © 2018年 Yongqiang Wei. All rights reserved.
//

#import "ViewController.h"
#import "PersonModel.h"
#import "TeacherModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    TeacherModel *teacher = [[TeacherModel alloc] initPersonWithName:@"coco" age:28 gender:PersonGenderWoman];
    /**  unrecognized selector */
    /**  buyCar:已在TeacherModel 声明，但并未实现，其父类PersonModel也并未声明与实现 */
    [teacher buyCar:@"BMW"];
}


@end
