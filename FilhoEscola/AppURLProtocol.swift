//
//  AppURLProtocol.swift
//  GetDocAg
//
//  Created by Everton Luiz Pascke on 21/02/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

class AppURLProtocol: URLProtocol {
    
    fileprivate var response: URLResponse!
    fileprivate var data: NSMutableData!
    
    private var dataTask: URLSessionDataTask?
    private static let handleKey = "\(AppURLProtocol.self).handleKey"
    
    override class func canInit(with request: URLRequest) ->Bool {
        guard let host = request.url?.host, host == Config.host else {
            return false
        }
        if URLProtocol.property(forKey: AppURLProtocol.handleKey, in: request) != nil {
            return false
        }
        if let resource = request.url?.absoluteString {
            print("Starting", resource, separator: "... ", terminator: "\n")
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func stopLoading() {
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    override func startLoading() {
        if let model = findCache() {
            let response = URLResponse(url: self.request.url!, mimeType: model.mimeType, expectedContentLength: model.data.length, textEncodingName: model.encoding)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: model.data as Data)
            self.client?.urlProtocolDidFinishLoading(self)
            print("Cached", model.resource, separator: ": ", terminator: "\n")
        } else {
            if let request = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                URLProtocol.setProperty(true, forKey: AppURLProtocol.handleKey, in: request)
                for (key, value) in Device.headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                self.dataTask = session.dataTask(with: request as URLRequest)
                self.dataTask!.resume()
            }
        }
    }
    
    fileprivate func findCache() -> CacheModel? {
        if let resource = request.url?.absoluteString {
            do {
                return try CacheService.find(by: resource)
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    fileprivate func saveCache() {
        if let url = request.url {
            let extensions = ["js", "css", "png", "jpg", "jpeg", "woff", "woff2"]
            if extensions.contains(url.pathExtension) {
                let mimeType = response.mimeType
                let encoding = response.textEncodingName
                let resource = url.absoluteString
                do {
                    print("Caching", resource, separator: "... ", terminator: "\n")
                    let model = try CacheService.save(data: data as NSData, resource: resource, mimeType: mimeType, encoding: encoding)
                    print("Cache", model.resource, "success", separator: " ", terminator: ".\n")
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
    }
    
    fileprivate func verifyCache() {
        if self.response != nil, let response = self.response as? HTTPURLResponse {
            let headerKey = CacheModel.headerKey
            if let headerCacheVersion = response.allHeaderFields[headerKey] as? String {
                if let cacheVersion = UserDefaults.standard.value(forKey: headerKey) as? String {
                    if cacheVersion != headerCacheVersion {
                        do {
                            print("Cleaning cache...")
                            try CacheService.clear()
                            print("Cache cleaned successfully!")
                        } catch {
                            print("Clean cache error", error.localizedDescription, separator: ": ", terminator: "\n")
                        }
                    }
                }
                UserDefaults.standard.set(headerCacheVersion, forKey: headerKey)
            }
        }
    }
}

extension AppURLProtocol: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.client?.urlProtocol(self, didFailWithError: error!)
            print(error!.localizedDescription)
        } else {
            self.client?.urlProtocolDidFinishLoading(self)
            self.saveCache()
        }
    }
}

extension AppURLProtocol: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
        self.data.append(data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.response = response
        self.data = NSMutableData()
        self.verifyCache()
        completionHandler(.allow)
    }
}
