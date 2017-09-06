//
//  AlunoService.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/08/17.
//  Copyright © 2017 Wasys Technology. All rights reserved.
//

import Foundation

import RxSwift
import Alamofire
import RealmSwift

class AlunoService: Service {
    
    static func solicitar(_ model: AlunoSolicitacaoModel) throws -> ResultModel {
        let url = "\(Config.restURL)/aluno/solicitar"
        let dictionary = model.dictionary
        let response: DataResponse<ResultModel> = try Network.request(url, method: .post, parameters: dictionary, encoding: JSONEncoding.default, headers: Device.headers).parse()
        let result = response.result
        if result.isFailure {
            throw result.error!
        }
        let model = result.value!
        return model;
    }
    
    static func get(_ key: AlunoKey) throws -> AlunoModel? {
        let realm = try Realm()
        guard let aluno = realm.objects(Aluno.self).filter("key = %ld", key.hashValue).first else {
            return nil
        }
        return AlunoModel.from(aluno)
    }
    
    static func atualizar(image: UIImage, for key: AlunoKey) throws -> AlunoModel {
        guard let data = UIImageJPEGRepresentation(image, 0.8) else {
            throw Trouble.any("Failed compression image.")
        }
        let realm = try Realm()
        guard let aluno = realm.objects(Aluno.self).filter("key = %ld", key.hashValue).first else {
            throw Trouble.any("Aluno \(key.hashValue) not found.")
        }
        try realm.write {
            aluno.foto = data
        }
        return AlunoModel.from(aluno)
    }
    
    static func listar(sync: Bool = false) throws -> [AlunoModel] {
        if sync {
            try MensagemService.buscar()
        }
        let realm = try Realm()
        let results = realm.objects(Aluno.self)
        return AlunoModel.from(results)
    }
    
    class Async {
        
        static func listar(sync: Bool = false) -> Observable<[AlunoModel]> {
            return Observable.create { observer in
                do {
                    let models = try AlunoService.listar(sync: sync)
                    observer.onNext(models)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func atualizar(image: UIImage, for key: AlunoKey) -> Observable<AlunoModel> {
            return Observable.create { observer in
                do {
                    let model = try AlunoService.atualizar(image: image, for: key)
                    observer.onNext(model)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                return Disposables.create()
            }
        }
        
        static func solicitar(_ model: AlunoSolicitacaoModel) -> Observable<ResultModel> {
            return Observable.create { observer in
                do {
                    let model = try AlunoService.solicitar(model)
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
