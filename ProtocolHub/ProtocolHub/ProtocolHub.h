//
//  ProtocolHub.h
//  ProtocolHub
//
//  Created by YLCHUN on 2019/9/28.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ProtocolHub(__Protocol__) ProtocolHub<__Protocol__>
#define NewProtocolHub(__Protocol__) [ProtocolHub(__Protocol__) hubWithProtocol:@protocol(__Protocol__)];

@interface ProtocolHub : NSProxy

+ (instancetype)alloc NS_UNAVAILABLE;

+ (instancetype)hubWithProtocol:(Protocol *)protocol NS_REQUIRES_SUPER;

/// addOutput
/// @param obj must conforms to Protocol
- (BOOL)addOutput:(id)obj NS_REQUIRES_SUPER;

/// removeOutput
/// @param obj must conforms to Protocol
- (void)removeOutput:(id)obj NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
