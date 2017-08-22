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
    }
}
