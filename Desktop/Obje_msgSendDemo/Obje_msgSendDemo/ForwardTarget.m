//
//  ForwardTarget.m
//  Obje_msgSendDemo
//
//  Created by Yongqiang Wei on 2018/10/16.
//  Copyright © 2018年 Yongqiang Wei. All rights reserved.
//

#import "ForwardTarget.h"

#import <objc/runtime.h>

@implementation ForwardTarget

- (void)sel
{
    NSLog(@"ForwardingTarget");
}

- (void)invocationTest
{
    NSLog(@"invocationTest");
}


id dynamicMethod(id self, SEL _cmd)
{
    NSLog(@"%s:动态添加的方法",__FUNCTION__);
    return @"1";
}


+ (BOOL)resolveInstanceMethod:(SEL)sel __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    
    class_addMethod(self.class, sel, (IMP)dynamicMethod, "@@:");
    BOOL result = [super resolveInstanceMethod:sel];
    result = YES;
    return result;
}

- (id)forwardingTargetForSelector:(SEL)aSelector __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    id result = [super forwardingTargetForSelector:aSelector];
    return result;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    id result = [super methodSignatureForSelector:aSelector];
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [self performSelector:anInvocation.selector withObject:nil];
    //    [super forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    
    [super doesNotRecognizeSelector:aSelector]; // crash
}
@end
