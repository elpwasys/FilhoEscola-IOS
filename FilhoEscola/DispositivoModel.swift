//
//  DispositivoModel.swift
//  ClubMesa
//
//  Created by Everton Luiz Pascke on 16/04/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class DispositivoModel: Mappable {
    
    var status: Status = .naoVerificado
    
    var uuid: String!
    var nome: String!
    var token: String!
    var numero: String!
    var prefixo: String!
    var dataNascimento: Date!
    
    static var current: DispositivoModel? {
        get {
            var model: DispositivoModel?
            let defaults = UserDefaults.standard
            if let uuid = defaults.value(forKey: uuid) as? String,
                let nome = defaults.value(forKey: nome) as? String,
                    let numero = defaults.value(forKey: numero) as? String,
                        let prefixo = defaults.value(forKey: prefixo) as? String,
                            let dataNascimento = defaults.value(forKey: dataNascimento) as? Date {
                model = DispositivoModel(uuid: uuid, nome: nome, numero: numero, prefixo: prefixo, dataNascimento: dataNascimento)
                if let value = defaults.value(forKey: token) as? String {
                    model?.token = value
                }
                if let rawValue = defaults.value(forKey: status) as? String, let value = Status.init(rawValue: rawValue) {
                    model?.status = value
                }
            }
            return model
        }
        set {
            let defaults = UserDefaults.standard
            if let model = newValue {
                defaults.set(model.uuid, forKey: uuid)
                defaults.set(model.nome, forKey: nome)
                defaults.set(model.status.rawValue, forKey: status)
                defaults.set(model.numero, forKey: numero)
                defaults.set(model.prefixo, forKey: prefixo)
                defaults.set(model.dataNascimento, forKey: dataNascimento)
                if model.token != nil {
                    defaults.set(model.token, forKey: token)
                }
            } else {
                defaults.removeObject(forKey: uuid)
                defaults.removeObject(forKey: nome)
                defaults.removeObject(forKey: token)
                defaults.removeObject(forKey: status)
                defaults.removeObject(forKey: numero)
                defaults.removeObject(forKey: prefixo)
                defaults.removeObject(forKey: dataNascimento)
            }
        }
    }
    
    enum Status: String {
        case verificado = "VERIFICADO"
        case naoVerificado = "NAO_VERIFICADO"
    }
    
    private static let uuid = "\(DispositivoModel.self).uuid"
    private static let nome = "\(DispositivoModel.self).name"
    private static let token = "\(DispositivoModel.self).token"
    private static let status = "\(DispositivoModel.self).status"
    private static let numero = "\(DispositivoModel.self).numero"
    private static let prefixo = "\(DispositivoModel.self).prefixo"
    private static let dataNascimento = "\(DispositivoModel.self).dataNascimento"
    
    init(uuid: String, nome: String, numero: String, prefixo: String, dataNascimento: Date) {
        self.uuid = uuid
        self.nome = nome
        self.numero = numero
        self.prefixo = prefixo
        self.dataNascimento = dataNascimento
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        uuid <- map["uuid"]
        nome <- map["nome"]
        token <- map["token"]
        status <- map["status"]
        numero <- map["numero"]
        prefixo <- map["prefixo"]
        dataNascimento <- (map["dataNascimento"], DateTransformType())
    }
    
    func dictonary() -> [String: String] {
        var hash:[String: String] = [
            "uuid": uuid,
            "nome": nome,
            "numero": numero,
            "prefixo": prefixo,
            "dataNascimento": DateUtils.format(dataNascimento, type: .dateBr)
        ]
        if let token = self.token {
            hash["token"] = token
        }
        return hash
    }
}
