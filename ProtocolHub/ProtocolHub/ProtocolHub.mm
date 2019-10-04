//
//  ProtocolHub.m
//  ProtocolHub
//
//  Created by YLCHUN on 2019/9/28.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ProtocolHub.h"
#import <objc/message.h>
#import <pthread.h>
#import <string>
#import <map>

@implementation ProtocolHub
{
    Protocol *_protocol;
    std::map<std::string, std::tuple<NSMethodSignature*, BOOL>> _instance_methods;
    NSHashTable *_outputs;
    pthread_mutex_t _lock;
}

+ (instancetype)hubWithProtocol:(Protocol *)protocol {
    if (!protocol) return nil;
    return [[super alloc] initWithProtocol:protocol];
}

+ (instancetype)alloc {
    return [super alloc];
}

- (void)dealloc {
    [_outputs removeAllObjects];
    _protocol = nil;
    _instance_methods.clear();
    pthread_mutex_destroy(&_lock);
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    if (self) {
        _protocol = protocol;
        pthread_mutex_init(&_lock, NULL);
        _outputs = [NSHashTable weakObjectsHashTable];
        [self loadProtocolMethod];
    }
    return self;
}

static void enumerateProtocolMethod(Protocol * _Nonnull proto, BOOL isRequired, BOOL isInstance, void(^useingBlock)(objc_method_description desc)) {
    unsigned int count;
    struct objc_method_description *list = protocol_copyMethodDescriptionList(proto, isRequired, isInstance, &count);
    for(int i = 0; i < count; i++) {
        useingBlock(list[i]);
    }
}

- (void)loadProtocolMethod {
    enumerateProtocolMethod(_protocol, YES, YES, ^(objc_method_description desc) {
        NSMethodSignature *ms = [NSMethodSignature signatureWithObjCTypes:desc.types];
        self->_instance_methods.insert(std::make_pair(sel_getName(desc.name), std::make_tuple(ms, YES)));
    });
    enumerateProtocolMethod(_protocol, NO, YES, ^(objc_method_description desc) {
        NSMethodSignature *ms = [NSMethodSignature signatureWithObjCTypes:desc.types];
        self->_instance_methods.insert(std::make_pair(sel_getName(desc.name), std::make_tuple(ms, NO)));
    });
}

- (BOOL)hasSel:(SEL)sel {
    return _instance_methods.find(sel_getName(sel)) != _instance_methods.end();
}

- (NSMethodSignature *)msForSel:(SEL)sel {
    return std::get<0>(_instance_methods.at(sel_getName(sel)));
}

- (BOOL)isRequiredSel:(SEL)sel {
    return std::get<1>(_instance_methods.at(sel_getName(sel)));
}

- (BOOL)isConforms:(id)obj {
    return class_conformsToProtocol([obj class], _protocol);
}

- (NSString *)description {
    pthread_mutex_lock(&_lock);
    NSArray *outputs = _outputs.allObjects;
    pthread_mutex_unlock(&_lock);
    NSMutableString *str = [NSMutableString string];
    [str appendString:[self typeDescription]];
    [str appendString:@" {\n"];
    for (id output in outputs) {
        [str appendFormat:@"\t%@\n", output];
    }
    [str appendString:@"}\n"];
    return [str copy];
}

- (NSString *)typeDescription {
    return [NSString stringWithFormat:@"%s<%s>", class_getName(self.class), protocol_getName(_protocol)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (![self hasSel:sel]) {
        [NSException raise:NSInvalidArgumentException format:@"*** -[%@ doesNotRecognizeSelector:%s] called!", [self typeDescription], sel_getName(sel)];
    }
    return [self msForSel:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    pthread_mutex_lock(&_lock);
    NSArray *outputs = _outputs.allObjects;
    pthread_mutex_unlock(&_lock);
    if ([self isRequiredSel:invocation.selector]) {
        for (id output in outputs) {
            [invocation invokeWithTarget:output];
        }
    }
    else {
        for (id output in outputs) {
            if ([output respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:output];
            }
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (![self hasSel:aSelector]) {
        return NO;
    }
    if ([self isRequiredSel:aSelector]) {
        return YES;
    }
    pthread_mutex_lock(&_lock);
    NSArray *receivers = _outputs.allObjects;
    pthread_mutex_unlock(&_lock);
    for (id receiver in receivers) {
        if ([receiver respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addOutput:(id)obj {
    if (!obj) return NO;
    if (![self isConforms:obj]) {
        NSLog(@"*** -[%@ %s] called! obj: %@ mast conforms to protocol: %s", [self typeDescription], sel_getName(_cmd), obj, protocol_getName(_protocol));
        return NO;
    }
    pthread_mutex_lock(&_lock);
    [_outputs addObject:obj];
    pthread_mutex_unlock(&_lock);
    return YES;
}

- (void)removeOutput:(id)obj {
    if (!obj) return;
    if (![self isConforms:obj]) return;
    pthread_mutex_lock(&_lock);
    [_outputs removeObject:obj];
    pthread_mutex_unlock(&_lock);
}

@end
