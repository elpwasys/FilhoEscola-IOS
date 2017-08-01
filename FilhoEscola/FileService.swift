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
            let response: DataResponse<Data> = try Network.request("\(baseURL)/\(resource)").responseData()
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
    
    static func upload(image: UIImage, handler: @escaping (UploadResultModel?, Error?) -> Void) {
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let manager = FileManager.default
            let directory = createURL(in: .cache, for: "upload")
            do {
                try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                // CRIA O NOME DA IMAGEM
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd_HHmmss'.jpeg'"
                let name = formatter.string(from: date)
                let url = directory.appendingPathComponent(name)
                manager.createFile(atPath: url.path, contents: data, attributes: nil)
                // Exclui o arquivo
                let remove = {
                    do {
                        try manager.removeItem(at: url)
                    } catch {
                        // Non-fatal: Arquivo provavelmente nao existe
                    }
                }
                try Network.upload(
                    multipartFormData: { multipart in
                        multipart.append(url, withName: "file")
                },
                    to: "\(Config.restURL)/file/upload",
                    method: .post,
                    headers: Device.headers,
                    encodingCompletion: { encondingResult in
                        switch encondingResult {
                        case .success(let request, _, _):
                            request.parse(handler: {(response: DataResponse<UploadResultModel>) in
                                remove()
                                let result = response.result
                                if result.isSuccess {
                                    handler(result.value!, nil)
                                } else {
                                    handler(nil, result.error!)
                                }
                            })
                        case .failure(let error):
                            remove()
                            handler(nil, error)
                        }
                }
                )
            } catch {
                handler(nil, error)
            }
        } else {
            handler(nil, Trouble.any("Falha ao comprimir imagem"))
        }
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
        static func upload(image: UIImage) -> Observable<UploadResultModel> {
            return Observable.create { observer in
                FileService.upload(image: image, handler: { (model, error) in
                    if model != nil {
                        observer.onNext(model!)
                        observer.onCompleted()
                    } else {
                        observer.onError(error!)
                    }
                })
                return Disposables.create()
            }
        }
    }
}
