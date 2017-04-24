//
//  FileService.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 10/02/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class FileService: Service {
    
    private static let cacheDirectoryName = "Cache"
    
    enum Kind {
        case cache
        case documents
        case temporary
        var url: URL {
            switch self {
            case .cache:
                return Kind.documents.url.appendingPathComponent(cacheDirectoryName)
            case .documents:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            case .temporary:
                return URL(fileURLWithPath: NSTemporaryDirectory())
            }
        }
    }
    
    static func load(resource: String) throws -> URL {
        let baseURL = Config.baseURL;
        var url: URL
        if !resource.contains(baseURL) {
            url = createURL(in: .cache, for: resource)
        } else {
            url = createURL(in: .cache, for: resource.substring(from: baseURL.endIndex))
        }
        let manager = FileManager.default
        if !manager.fileExists(atPath: url.path) {
            let response: DataResponse<Data> = Alamofire.request("\(baseURL)/\(resource)").responseData()
            let result = response.result
            if result.isFailure {
                throw result.error!
            }
            let data = result.value!
            let fileName = url.lastPathComponent
            let directory = createURL(in: .cache, for: resource.replacingOccurrences(of: fileName, with: ""))
            do {
                try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw error
            }
            let path = directory.appendingPathComponent(fileName).path
            let success = manager.createFile(atPath: path, contents: data, attributes: nil)
            if !success {
                throw Trouble.any("Fail to create file for \(resource)")
            }
        }
        return url
    }
    
    static func createURL(in kind: Kind, for names: String...) -> URL {
        var url = kind.url
        for name in names {
            url = url.appendingPathComponent(name)
        }
        return url
    }
    
    class Async {
        static func load(resource: String) -> Observable<URL> {
            return load(resources: [resource])
        }
        static func load(resources: [String]) -> Observable<URL> {
            return Observable.create { observer in
                do {
                    for resource in resources {
                        let value = try FileService.load(resource: resource)
                        observer.onNext(value)
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}
