//
//  CacheService.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 03/03/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import RealmSwift

class CacheService: Service {
    
    static func count() throws -> Int {
        let realm = try Realm()
        let results = realm.objects(Cache.self)
        return results.count
    }
    
    static func clear() throws {
        let realm = try Realm()
        try realm.write {
            let results = realm.objects(Cache.self)
            realm.delete(results)
            UserDefaults.standard.removeObject(forKey: CacheModel.headerKey)
        }
    }
    
    static func find(by resource: String) throws -> CacheModel? {
        let realm = try Realm()
        if let cache = realm.objects(Cache.self).filter("resource = %@", extract(resource)).first {
            return CacheModel.from(cache)
        }
        return nil
    }
    
    static func load(by resource: String) throws -> CacheModel {
        let url = "\(Config.protocol)://\(Config.host):\(Config.port)\(resource)";
        if let cacheModel = try find(by: url) {
            return cacheModel
        } else {
            let dataResponse: DataResponse<Data> = try Network.request(url).responseData()
            let result = dataResponse.result
            if result.isFailure {
                throw result.error!
            }
            if let response = dataResponse.response {
                let data = result.value!
                let mimeType = response.mimeType
                let encoding = response.textEncodingName
                return try save(data: data as NSData, resource: url, mimeType: mimeType, encoding: encoding)
            } else {
                throw Trouble.any("Failed to save '\(resource)'")
            }
        }
    }
    
    static func save(_ model: CacheModel) throws {
        let cache = Cache.from(model)
        let realm = try Realm()
        try realm.write {
            realm.add(cache, update: true)
        }
    }
    
    static func save(data: NSData, resource: String, mimeType: String?, encoding: String?) throws -> CacheModel {
        let model = CacheModel(data: data, resource: extract(resource))
        model.mimeType = mimeType
        model.encoding = encoding
        try save(model)
        return model
    }
    
    private static func extract(_ resource: String) -> String {
        let baseURL = "\(Config.baseURL)/"
        if resource.contains(baseURL) {
            return resource.substring(from: baseURL.endIndex)
        }
        let context = "/\(Config.context)/"
        if resource.contains(context) {
            return resource.substring(from: context.endIndex)
        }
        return resource
    }
    
    class Async {
        static func load(by resource: String) -> Observable<CacheModel> {
            return Observable.create { observer in
                do {
                    let model = try CacheService.load(by: resource)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
