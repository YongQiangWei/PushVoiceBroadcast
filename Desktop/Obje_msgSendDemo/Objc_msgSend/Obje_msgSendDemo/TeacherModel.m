//
//  TeacherModel.m
//  Obje_msgSendDemo
//
//  Created by Yongqiang Wei on 2018/10/16.
//  Copyright © 2018年 Yongqiang Wei. All rights reserved.
//

#import "TeacherModel.h"
#import "ForwardTarget.h"
#import <objc/runtime.h>
@interface TeacherModel ()

@property (nonatomic, readwrite, strong) ForwardTarget *otherTarget;

@end

@implementation TeacherModel
- (instancetype)initPersonWithName:(NSString *)name age:(NSInteger)age gender:(PersonGender)gender{
    self = [super initPersonWithName:name age:age gender:gender];
    if (self) {
        _otherTarget = [[ForwardTarget alloc] init];
//        [self performSelector:@selector(buyCar:) withObject:@"BMW"];
    }
    return self;
}


id dynamicMethodIMP(id self, SEL _cmd, NSString *str)
{
    NSLog(@"%s:动态添加的方法",__FUNCTION__);
    NSLog(@"%@,%@",NSStringFromClass([self class]), str);
    return @"1";
}


+ (BOOL)resolveInstanceMethod:(SEL)sel __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    // 第一次调用resolveInstanceMethod给个机会让类添加这个实现这个函数
    //    class_addMethod(self.class, sel, (IMP)dynamicMethodIMP, "@@:");
    class_addMethod(self.class, sel, (IMP)dynamicMethodIMP, "@@:");
    BOOL result = [super resolveInstanceMethod:sel];
    result = YES;
    return result; // 1
}

- (id)forwardingTargetForSelector:(SEL)aSelector __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    // 第二次调用forwardingTargetForSelector让别的对象去执行这个函数
    id result = [super forwardingTargetForSelector:aSelector];
    result = self.otherTarget;
    return result; // 2
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    id result = [super methodSignatureForSelector:aSelector];
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    result = sig;
    return result; // 3
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // 第三次调用methodSignatureForSelector（函数符号制造器）和forwardInvocation（函数执行器）灵活的将目标函数以其他形式执行。
    //    [super forwardInvocation:anInvocation];
    anInvocation.selector = @selector(invocationTest);
    [self.otherTarget forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    [super doesNotRecognizeSelector:aSelector];
}

@end
