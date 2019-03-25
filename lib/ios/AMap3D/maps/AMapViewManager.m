#import <React/RCTUIManager.h>
#import "AMapView.h"
#import "AMapMarker.h"
#import "AMapOverlay.h"

#pragma ide diagnostic ignored "OCUnusedClassInspection"
#pragma ide diagnostic ignored "-Woverriding-method-mismatch"

@interface AMapViewManager : RCTViewManager <MAMapViewDelegate>
@end

@implementation AMapViewManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    AMapView *mapView = [AMapView new];
    mapView.centerCoordinate = CLLocationCoordinate2DMake(39.9242, 116.3979);
    mapView.zoomLevel = 10;
    mapView.delegate = self;
    // 不显示精度圈
    mapView.customizeUserLocationAccuracyCircleRepresentation=YES;
    return mapView;
}

RCT_EXPORT_VIEW_PROPERTY(locationEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(showsCompass, showCompass, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsScale, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsIndoorMap, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsLabels, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsTraffic, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsBuildings, BOOL)
RCT_EXPORT_VIEW_PROPERTY(zoomLevel, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(maxZoomLevel, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minZoomLevel, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(rotateEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(tiltEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(mapType, MAMapType)
RCT_EXPORT_VIEW_PROPERTY(coordinate, CLLocationCoordinate2D)
RCT_EXPORT_VIEW_PROPERTY(limitRegion, MACoordinateRegion)
RCT_EXPORT_VIEW_PROPERTY(region, MACoordinateRegion)
RCT_EXPORT_VIEW_PROPERTY(tilt, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(rotation, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(distanceFilter, CLLocationDistance)
RCT_EXPORT_VIEW_PROPERTY(locationStyle, LocationStyle)

RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLongPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLocation, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onStatusChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onStatusChangeComplete, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onMapScreenShot, RCTBubblingEventBlock)

RCT_EXPORT_METHOD(animateTo:(nonnull NSNumber *)reactTag params:(NSDictionary *)params duration:(NSInteger)duration) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        AMapView *mapView = (AMapView *) viewRegistry[reactTag];
        MAMapStatus *mapStatus = mapView.getMapStatus;
        if (params[@"zoomLevel"]) {
            mapStatus.zoomLevel = [params[@"zoomLevel"] floatValue];
        }
        if (params[@"coordinate"]) {
            NSDictionary *coordinate = params[@"coordinate"];
            mapStatus.centerCoordinate = CLLocationCoordinate2DMake(
                    [coordinate[@"latitude"] doubleValue],
                    [coordinate[@"longitude"] doubleValue]);
        }
        if (params[@"tilt"]) {
            mapStatus.cameraDegree = [params[@"tilt"] floatValue];
        }
        if (params[@"rotation"]) {
            mapStatus.rotationDegree = [params[@"rotation"] floatValue];
        }
        [mapView setMapStatus:mapStatus animated:YES duration:duration / 1000.0];
    }];
}

RCT_EXPORT_METHOD(setFitView:(nonnull NSNumber *)reactTag params:(NSDictionary *)params duration:(NSInteger)duration) {
[self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
AMapView *mapView = (AMapView *) viewRegistry[reactTag];
if (params[@"LatLng1"] && params[@"LatLng1"]) {
float myLatitude = ([params[@"LatLng1"][@"latitude"] floatValue]+[params[@"LatLng2"][@"latitude"] floatValue])/2;
float myLongitude = ([params[@"LatLng1"][@"longitude"] floatValue]+[params[@"LatLng2"][@"longitude"] floatValue])/2;
float myX =fabsf([params[@"LatLng1"][@"latitude"] floatValue]-[params[@"LatLng2"][@"latitude"] floatValue]);
float myY =fabsf([params[@"LatLng1"][@"longitude"] floatValue]-[params[@"LatLng2"][@"longitude"] floatValue]);

MAMapRect mapRect = MAMapRectForCoordinateRegion(MACoordinateRegionMake(CLLocationCoordinate2DMake(myLatitude, myLongitude), MACoordinateSpanMake(myX, myY)));
    [mapView setVisibleMapRect: mapRect   animated:YES ];
}
}];
}

RCT_EXPORT_METHOD(getMapScreenShot:(nonnull NSNumber *)reactTag  ) {
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        AMapView *mapView = (AMapView *) viewRegistry[reactTag];
                // 截图前把自己的位置隐藏
        mapView.showsUserLocation = false;
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
        
        [mapView takeSnapshotInRect:mapView.annotationVisibleRect withCompletionBlock:^(UIImage *resultImage, NSInteger state){
            mapView.onMapScreenShot(@{
                                      @"screenShotPath":[self savescanresultimage:resultImage
                                                                        imagename:[NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@.png", [formater stringFromDate: [NSDate date]]]],
                                      });
                        // 截图后把自己的位置显示出来
            mapView.showsUserLocation = true;
        } ];
    }];
}


-(NSString *)savescanresultimage:(UIImage *)resultimage imagename:(NSString *)strimagename
{
    NSData *imageData = UIImagePNGRepresentation(resultimage);
    //  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //  NSString *documentsDirectory = [paths objectAtIndex:0];
    //  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:strimagename]; //Add the file name
    [imageData writeToFile:strimagename atomically:YES];
    return strimagename;
}


- (void)mapView:(AMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (mapView.onPress) {
        mapView.onPress(@{
                @"latitude": @(coordinate.latitude),
                @"longitude": @(coordinate.longitude),
        });
    }
}

- (void)mapView:(AMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    if (mapView.onLongPress) {
        mapView.onLongPress(@{
                @"latitude": @(coordinate.latitude),
                @"longitude": @(coordinate.longitude),
        });
    }
}

- (void)mapView:(AMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (mapView.onLocation) {
        mapView.onLocation(@{
                @"latitude": @(userLocation.coordinate.latitude),
                @"longitude": @(userLocation.coordinate.longitude),
                @"accuracy": @((userLocation.location.horizontalAccuracy + userLocation.location.verticalAccuracy) / 2),
                @"altitude": @(userLocation.location.altitude),
                @"speed": @(userLocation.location.speed),
                @"timestamp": @(userLocation.location.timestamp.timeIntervalSince1970),
        });
    }
}

- (MAAnnotationView *)mapView:(AMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        AMapMarker *marker = [mapView getMarker:annotation];
        return marker.annotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    if ([overlay isKindOfClass:[AMapOverlay class]]) {
        return ((AMapOverlay *) overlay).renderer;
    }
    return nil;
}

- (void)mapView:(AMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    AMapMarker *marker = [mapView getMarker:view.annotation];
    if (marker.onPress) {
        marker.onPress(nil);
    }
}

- (void)mapView:(AMapView *)mapView didAnnotationViewCalloutTapped:(MAAnnotationView *)view {
    AMapMarker *marker = [mapView getMarker:view.annotation];
    if (marker.onInfoWindowPress) {
        marker.onInfoWindowPress(nil);
    }
}

- (void)mapView:(AMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState
   fromOldState:(MAAnnotationViewDragState)oldState {
    AMapMarker *marker = [mapView getMarker:view.annotation];
    if (newState == MAAnnotationViewDragStateStarting && marker.onDragStart) {
        marker.onDragStart(nil);
    }
    if (newState == MAAnnotationViewDragStateDragging) {
        if (marker.onDrag) {
            marker.onDrag(nil);
        }
    }
    if (newState == MAAnnotationViewDragStateEnding && marker.onDragEnd) {
        marker.onDragEnd(@{
                @"latitude": @(marker.annotation.coordinate.latitude),
                @"longitude": @(marker.annotation.coordinate.longitude),
        });
    }
}

- (void)mapViewRegionChanged:(AMapView *)mapView {
    if (mapView.onStatusChange) {
        MAMapStatus *status = mapView.getMapStatus;
        mapView.onStatusChange(@{
                @"zoomLevel": @(status.zoomLevel),
                @"tilt": @(status.cameraDegree),
                @"rotation": @(status.rotationDegree),
                @"latitude": @(status.centerCoordinate.latitude),
                @"longitude": @(status.centerCoordinate.longitude),
        });
    }
}

- (void)mapView:(AMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (mapView.onStatusChangeComplete) {
        MAMapStatus *status = mapView.getMapStatus;
        mapView.onStatusChangeComplete(@{
                @"zoomLevel": @(status.zoomLevel),
                @"tilt": @(status.cameraDegree),
                @"rotation": @(status.rotationDegree),
                @"latitude": @(status.centerCoordinate.latitude),
                @"longitude": @(status.centerCoordinate.longitude),
                @"latitudeDelta": @(mapView.region.span.latitudeDelta),
                @"longitudeDelta": @(mapView.region.span.longitudeDelta),
                @"scalePerPixel": @(mapView.metersPerPointForCurrentZoom)
        });
    }
}

- (void)mapInitComplete:(AMapView *)mapView {
    mapView.loaded = YES;

    // struct 里的值会被初始化为 0，这里以此作为条件，判断 initialRegion 是否被设置过
    // 但实际上经度为 0 是一个合法的坐标，只是考虑到高德地图只在中国使用，就这样吧
    if (mapView.initialRegion.center.latitude != 0) {
        mapView.region = mapView.initialRegion;
    }
}

@end
