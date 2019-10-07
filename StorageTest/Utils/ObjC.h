//
//  ObjC.h
//  StorageTest
//
//  Created by Alexey Goryunov on 10/7/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjC : NSObject

+ (void)tryBlock:(void (^)(void))try catchBlock:(void (^)(NSException *))catch;

@end

NS_ASSUME_NONNULL_END
