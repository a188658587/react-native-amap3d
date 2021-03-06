package cn.qiuxiang.react.amap3d.maps

import android.view.View
import com.amap.api.maps.AMap
import com.amap.api.maps.CameraUpdateFactory
import com.amap.api.maps.model.LatLng
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

@Suppress("unused")
internal class AMapViewManager : ViewGroupManager<AMapView>() {
    companion object {
        val ANIMATE_TO = 1
        val SET_FIT_VIEW = 2
        val GET_MAPSCREEN_SHOT = 3
    }

    override fun getName(): String {
        return "AMapView"
    }

    override fun createViewInstance(reactContext: ThemedReactContext): AMapView {
        return AMapView(reactContext)
    }

    override fun onDropViewInstance(view: AMapView) {
        super.onDropViewInstance(view)
        view.onDestroy()
    }

    override fun getCommandsMap(): Map<String, Int> {
        return mapOf("animateTo" to ANIMATE_TO, "setFitView" to SET_FIT_VIEW, "getMapScreenShot" to GET_MAPSCREEN_SHOT)
    }

    override fun receiveCommand(overlay: AMapView, commandId: Int, args: ReadableArray?) {
        when (commandId) {
            ANIMATE_TO -> overlay.animateTo(args)
            SET_FIT_VIEW -> overlay.setFitView(args)
            GET_MAPSCREEN_SHOT -> overlay.getMapScreenShot()
        }
    }

    override fun addView(mapView: AMapView, child: View, index: Int) {
        mapView.add(child)
        super.addView(mapView, child, index)
    }

    override fun removeViewAt(parent: AMapView, index: Int) {
        parent.remove(parent.getChildAt(index))
        super.removeViewAt(parent, index)
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> {

        return mapOf("onPress" to MapBuilder.of("registrationName", "onPress"),
                        "onLongPress" to MapBuilder.of("registrationName", "onLongPress"),
                        "onAnimateCancel" to MapBuilder.of("registrationName", "onAnimateCancel"),
                        "onAnimateFinish" to MapBuilder.of("registrationName", "onAnimateFinish"),
                        "onStatusChange" to MapBuilder.of("registrationName", "onStatusChange"),
                        "onStatusChangeComplete" to MapBuilder.of("registrationName", "onStatusChangeComplete"),
                        "onLocation" to MapBuilder.of("registrationName", "onLocation"),
                        "onMapScreenShot" to MapBuilder.of("registrationName", "onMapScreenShot")
                )
    }

    @ReactProp(name = "locationEnabled")
    fun setMyLocationEnabled(view: AMapView, enabled: Boolean) {
        view.setLocationEnabled(enabled)
    }

    @ReactProp(name = "showsIndoorMap")
    fun showIndoorMap(view: AMapView, show: Boolean) {
        view.map.showIndoorMap(show)
    }

    @ReactProp(name = "showsIndoorSwitch")
    fun setIndoorSwitchEnabled(view: AMapView, show: Boolean) {
        view.map.uiSettings.isIndoorSwitchEnabled = show
    }

    @ReactProp(name = "showsBuildings")
    fun showBuildings(view: AMapView, show: Boolean) {
        view.map.showBuildings(show)
    }

    @ReactProp(name = "showsLabels")
    fun showMapText(view: AMapView, show: Boolean) {
        view.map.showMapText(show)
    }

    @ReactProp(name = "showsCompass")
    fun setCompassEnabled(view: AMapView, show: Boolean) {
        view.map.uiSettings.isCompassEnabled = show
    }

    @ReactProp(name = "showsZoomControls")
    fun setZoomControlsEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isZoomControlsEnabled = enabled
    }

    @ReactProp(name = "showsScale")
    fun setScaleControlsEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isScaleControlsEnabled = enabled
    }

    @ReactProp(name = "mapLanguage")
    fun setLanguage(view: AMapView, mapLanguage:Int) {
        view.map.setMapLanguage(if(mapLanguage == 1) {"en"} else {"zh_cn"})
    }

    @ReactProp(name = "showsLocationButton")
    fun setMyLocationButtonEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isMyLocationButtonEnabled = enabled
    }

    @ReactProp(name = "showsTraffic")
    fun setTrafficEnabled(view: AMapView, enabled: Boolean) {
        view.map.isTrafficEnabled = enabled
    }

    @ReactProp(name = "maxZoomLevel")
    fun setMaxZoomLevel(view: AMapView, zoomLevel: Float) {
        view.map.maxZoomLevel = zoomLevel
    }

    @ReactProp(name = "minZoomLevel")
    fun setMinZoomLevel(view: AMapView, zoomLevel: Float) {
        view.map.minZoomLevel = zoomLevel
    }

    @ReactProp(name = "zoomLevel")
    fun setZoomLevel(view: AMapView, zoomLevel: Float) {
        view.map.moveCamera(CameraUpdateFactory.zoomTo(zoomLevel))
    }

    @ReactProp(name = "mapType")
    fun setMapType(view: AMapView, mapType: String) {
        when (mapType) {
            "standard" -> view.map.mapType = AMap.MAP_TYPE_NORMAL
            "satellite" -> view.map.mapType = AMap.MAP_TYPE_SATELLITE
            "navigation" -> view.map.mapType = AMap.MAP_TYPE_NAVI
            "night" -> view.map.mapType = AMap.MAP_TYPE_NIGHT
            "bus" -> view.map.mapType = AMap.MAP_TYPE_BUS
        }
    }

    @ReactProp(name = "zoomEnabled")
    fun setZoomGesturesEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isZoomGesturesEnabled = enabled
    }

    @ReactProp(name = "scrollEnabled")
    fun setScrollGesturesEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isScrollGesturesEnabled = enabled
    }

    @ReactProp(name = "rotateEnabled")
    fun setRotateGesturesEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isRotateGesturesEnabled = enabled
    }

    @ReactProp(name = "tiltEnabled")
    fun setTiltGesturesEnabled(view: AMapView, enabled: Boolean) {
        view.map.uiSettings.isTiltGesturesEnabled = enabled
    }

    @ReactProp(name = "coordinate")
    fun moveToCoordinate(view: AMapView, coordinate: ReadableMap) {
        view.map.moveCamera(CameraUpdateFactory.changeLatLng(LatLng(
                coordinate.getDouble("latitude"),
                coordinate.getDouble("longitude"))))
    }

    @ReactProp(name = "region")
    fun setRegion(view: AMapView, region: ReadableMap) {
        view.setRegion(region)
    }

    @ReactProp(name = "limitRegion")
    fun setLimitRegion(view: AMapView, limitRegion: ReadableMap) {
        view.setLimitRegion(limitRegion)
    }

    @ReactProp(name = "tilt")
    fun changeTilt(view: AMapView, tilt: Float) {
        view.map.moveCamera(CameraUpdateFactory.changeTilt(tilt))
    }

    @ReactProp(name = "rotation")
    fun changeRotation(view: AMapView, rotation: Float) {
        view.map.moveCamera(CameraUpdateFactory.changeBearing(rotation))
    }

    @ReactProp(name = "locationInterval")
    fun setLocationInterval(view: AMapView, interval: Int) {
        view.setLocationInterval(interval.toLong())
    }

    @ReactProp(name = "locationStyle")
    fun setLocationStyle(view: AMapView, style: ReadableMap) {
        view.setLocationStyle(style)
    }
}
