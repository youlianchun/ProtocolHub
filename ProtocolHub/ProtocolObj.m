//
//  ProtocolObj.m
//  ProtocolHub
//
//  Created by YLCHUN on 2019/10/1.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ProtocolObj.h"

@interface ProtocolObj() <ProtocolObjDelegate>

@end

@implementation ProtocolObj
- (void)requiredFunc {
    NSLog(@"requiredFunc");
}
//- (int)optionalFunc:(int)i {
//    return i+1;
//}

@end

