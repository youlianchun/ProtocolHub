//
//  ProtocolObj.h
//  ProtocolHub
//
//  Created by YLCHUN on 2019/10/1.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ProtocolObjDelegate <NSObject>

- (void)requiredFunc;
@optional
- (int)optionalFunc:(int)i;
@end

@interface ProtocolObj: NSObject
@end

NS_ASSUME_NONNULL_END
