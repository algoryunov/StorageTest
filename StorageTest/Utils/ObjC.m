//
//  ObjC.m
//  StorageTest
//
//  Created by Alexey Goryunov on 10/7/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

#import "ObjC.h"

@implementation ObjC

+ (void)tryBlock:(void (^)(void))try catchBlock:(void (^)(NSException *))catch {
    @try {
        try ? try() : nil;
    }
    @catch (NSException *e) {
        catch ? catch(e) : nil;
    }
    @finally {
//        finally ? finally() : nil;
    }
}

@end
