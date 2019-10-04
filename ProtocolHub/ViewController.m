//
//  ViewController.m
//  ProtocolHub
//
//  Created by YLCHUN on 2019/10/1.
//  Copyright © 2019 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "ProtocolHub.h"
#import "ProtocolObj.h"

@interface ViewController ()
@property (nonatomic, strong) ProtocolHub<ProtocolObjDelegate> *hub;
@property (nonatomic, strong) NSMutableArray<ProtocolObj *> *objs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.objs = [NSMutableArray array];
    self.hub = NewProtocolHub(ProtocolObjDelegate);
    
    for (int i = 0; i < 5; i ++) {
        ProtocolObj *obj = [ProtocolObj new];
        [self.objs addObject:obj];
        [self.hub addOutput:obj];
    }
    [self.hub addOutput:[ProtocolObj class]];
    int i = [self.hub optionalFunc:1];
    [self.hub requiredFunc];
    NSLog(@"");
    // Do any additional setup after loading the view.
}
@end
