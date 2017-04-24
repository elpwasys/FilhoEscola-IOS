//
//  DispositivoService.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 16/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire

class DispositivoService: Service {
    
    static func verificar(prefixo: String, numero: String, codigo: String) throws -> DispositivoModel {
        let url = "\(Config.restURL)/dispositivo/verificar/\(prefixo)/\(numero)/\(codigo)"
        let response: DataResponse<DispositivoModel> = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        DispositivoModel.current = model
        return model
    }
    
    static func reenviar(prefixo: String, numero: String) throws -> DispositivoModel {
        let url = "\(Config.restURL)/dispositivo/reenviar/\(prefixo)/\(numero)"
        let response: DataResponse<DispositivoModel> = Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        DispositivoModel.current = model
        return model
    }
    
    static func confirmar(model: DispositivoModel) throws -> DispositivoModel {
        let url = "\(Config.restURL)/dispositivo/confirmar"
        let dictionary = model.dictonary()
        let response: DataResponse<DispositivoModel> = Alamofire.request(url, method: .post, parameters: dictionary, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        DispositivoModel.current = model
        return model
    }
    
    class Async {
        static func verificar(prefixo: String, numero: String, codigo: String) -> Observable<DispositivoModel> {
            return Observable.create { observer in
                do {
                    let result = try DispositivoService.verificar(prefixo: prefixo, numero: numero, codigo: codigo)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        static func reenviar(prefixo: String, numero: String) -> Observable<DispositivoModel> {
            return Observable.create { observer in
                do {
                    let result = try DispositivoService.reenviar(prefixo: prefixo, numero: numero)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        static func confirmar(model: DispositivoModel) -> Observable<DispositivoModel> {
            return Observable.create { observer in
                do {
                    let result = try DispositivoService.confirmar(model: model)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
    }
}