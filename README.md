# ProtocolHub
ProtocolHub 协议集线器

#### 简介
ProtocolHub的功能是实现代理一对多，这个运用场景应该也算常见，特别是一些状态的显示同步。
ProtocolHub在创建时候就必须规定好Protocol，对于非可选方法的转发不再进行响应判断，对于可选方法进行了响应判断，所以在调用时候就不需要另作处理。

#### 使用介绍
来个Protocol
```
@protocol ProtocolObjDelegate <NSObject>
- (void)requiredFunc;
@optional
- (int)optionalFunc:(int)i;
@end
```
声明
```
@property (nonatomic, strong) ProtocolHub<ProtocolObjDelegate> *hub;
```
使用
```
//初始化
self.hub = NewProtocolHub(ProtocolObjDelegate);

//添加输出
id<ProtocolObjDelegate> *obj1 = ...
[self.hub addOutput:obj1];
id<ProtocolObjDelegate> *obj2 = ...
[self.hub addOutput:obj2];
...

//执行
int i = [self.hub optionalFunc:1];
[self.hub requiredFunc];
```

