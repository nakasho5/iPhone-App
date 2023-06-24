//
//  MapView.swift
//  MyMap
//
//  Created by 中村翔 on 2023/06/23.
//

import SwiftUI
import MapKit

// マップの種類を示す列挙型
enum MapType {
    case standard    // 標準
    case satellite   // 衛星写真
    case hybrid      // 衛星写真+交通機関ラベル
}

struct MapView: UIViewRepresentable {
    // 検索キーワード
    let searchKey: String
    // マップ種類
    let mapType: MapType
    
    // 表示するViewを作成するときに実行
    func makeUIView(context: Context) -> MKMapView {
        // MKMapViewのインスタンス生成
        MKMapView()
    } // makeUIView ここまで
    
    // 表示したViewが更新されるたびに実行
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 入力された文字をデバッグエリアに表示
        print("検索キーワード：\(searchKey)")
        
        // マップ種類の設定
        switch mapType {
        case .standard:
            // 標準
            uiView.preferredConfiguration =  MKStandardMapConfiguration(elevationStyle: .flat)
            
        case .satellite:
            // 衛星写真
            uiView.preferredConfiguration = MKImageryMapConfiguration()
            
        case .hybrid:
            // 衛星写真+交通機関ラベル
            uiView.preferredConfiguration = MKHybridMapConfiguration()
        }
        
        // CLGeocoderインスタンスを生成
        let geocoder = CLGeocoder()
        
        // 入力された文字から位置情報を取得
        geocoder.geocodeAddressString (
            searchKey,
            completionHandler: { (placemarks, error) in
                // リクエストの結果が存在し、1件目の情報から位置情報を取り出す
                if let placemarks,
                   let firstPlacemark = placemarks.first,
                   let location = firstPlacemark.location {
                    
                    // 位置情報から緯度経度をtargetCoordinateに取り出す
                    let targetCoordinate = location.coordinate
                    
                    // 緯度経度をデバッグエリアに表示
                    print("緯度経度：\(targetCoordinate)")
                    
                    // MKPointAnnotationインスタンスを生成し、ピンを作る
                    let pin = MKPointAnnotation()
                    
                    // ピンを置く場所に緯度経度を設定
                    pin.coordinate = targetCoordinate
                    
                    // ピンのタイトルを設定
                    pin.title = searchKey
                    
                    // ピンを地図に置く
                    uiView.addAnnotation(pin)
                    
                    // 緯度経度を中心に半径500mの範囲を表示
                    uiView.region = MKCoordinateRegion(center: targetCoordinate,
                                                       latitudinalMeters: 500.0,
                                                       longitudinalMeters: 500.0)
                } // if ここまで
            }) // geocoder ここまで
    } // updateUIView ここまで
} // MapView ここまで

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(searchKey: "羽田空港", mapType:.standard)
    }
}
