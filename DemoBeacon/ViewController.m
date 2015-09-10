//
//  ViewController.m
//  DemoBeacon
//
//  Created by Alan.Yen on 2015/9/10.
//  Copyright (c) 2015年 17Life All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    // From "Allen Weng" 的 iBeacon 測試經驗
    //
    
    //CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //要求永久使用位置
    [self.locationManager requestAlwaysAuthorization];

    //要求藍芽權限!!
    CBCentralManager *cbCentralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
    CBCentralManagerState state = [cbCentralManager state];
    NSLog(@"要求藍芽權限!! %zd", state);
    
    NSString *uuidString = @"23A01AF0-232A-4518-9C0E-323FB773F5EF";
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                           identifier:@"Sensoro"];
    self.beaconRegion.notifyOnEntry = YES;//進入觸發
    self.beaconRegion.notifyOnExit = YES;//離開觸發
    self.beaconRegion.notifyEntryStateOnDisplay = YES;//喚醒螢幕時直接檢查目前狀態
    [self.locationManager startMonitoringForRegion:self.beaconRegion];//偵測範圍觸發
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //偵測範圍觸發
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    //偵測範圍觸發
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - [CLLocationManagerDelegate]

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    NSLog(@"didDetermineState state:%zd", state);
    NSLog(@"didDetermineState region:%@", region);
    
    //
    //這個每次啟動app時（可能是startMonitoringForRegion）會觸發一次，狀態改變（進、出、變成未知）時會觸發一次，開啟藍芽也會觸發一次。
    //
    
    //如果在資料beacon範圍內，呼叫掃描
    if (state == CLRegionStateInside && [region.identifier hasPrefix:@"Sensoro"]) {
        CLBeaconRegion *beaconRegion = (CLBeaconRegion*)region;
        [self.locationManager startRangingBeaconsInRegion:beaconRegion];
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    //
    //進入範圍時會觸發一次，但在範圍內打開藍芽，這時似乎不會觸發，所以didDetermineState會比這個適合。
    //
    NSLog(@"didEnterRegion");
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"didExitRegion");
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"didStartMonitoringForRegion");
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"didRangeBeacons");
    
    for (CLBeacon *beacon in beacons) {
        //major和minor，一開始有時會掃不到。沒有掃到就繼續掃，
        if (beacon.major && beacon.minor) {
            [self.locationManager stopRangingBeaconsInRegion:region];
        }
    }
}

@end
