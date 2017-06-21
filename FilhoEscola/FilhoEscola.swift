//
//  FilhoEscola.swift
//  FilhoEscola
//
//  Created by Everton Luiz Pascke on 08/02/17.
//  Copyright © 2017 Everton Luiz Pascke. All rights reserved.
//

import Foundation
import ObjectMapper

class Dispositivo: Mappable {
    
    var status: Status = .naoVerificado
    
    var uuid: String!
    var nome: String!
    var token: String!
    var numero: String!
    var prefixo: String!
    var dataNascimento: Date!
    
    static var current: Dispositivo? {
        get {
            var model: Dispositivo?
            let defaults = UserDefaults.standard
            if let uuid = defaults.value(forKey: uuid) as? String,
                let nome = defaults.value(forKey: nome) as? String,
                let numero = defaults.value(forKey: numero) as? String,
                let prefixo = defaults.value(forKey: prefixo) as? String,
                let dataNascimento = defaults.value(forKey: dataNascimento) as? Date {
                model = Dispositivo(uuid: uuid, nome: nome, numero: numero, prefixo: prefixo, dataNascimento: dataNascimento)
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
    
    private static let uuid = "\(Dispositivo.self).uuid"
    private static let nome = "\(Dispositivo.self).name"
    private static let token = "\(Dispositivo.self).token"
    private static let status = "\(Dispositivo.self).status"
    private static let numero = "\(Dispositivo.self).numero"
    private static let prefixo = "\(Dispositivo.self).prefixo"
    private static let dataNascimento = "\(Dispositivo.self).dataNascimento"
    
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

class Config {
    // homologacao: http://186.231.6.42:8586/getdoc_ag
    static var plist: [String: Any] = {
        guard let path = Bundle.main.path(forResource: "config", ofType: "plist") else {
            fatalError("File config.plist does not exist.")
        }
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String : Any] else {
            fatalError("Failed to create Dictionary for config.plist.")
        }
        return dictionary
    }()
    static var host: String {
        return value(forKey: "Host")
    }
    static var port: String {
        return value(forKey: "Port")
    }
    static var context: String {
        return value(forKey: "ContextApp")
    }
    static var `protocol`: String {
        return value(forKey: "Protocol")
    }
    static var fileURL: String {
        let contextFile = value(forKey: "ContextFile")
        return "\(Config.baseURL)/\(contextFile)"
    }
    static var restURL: String {
        let contextRest = value(forKey: "ContextRest")
        return "\(Config.baseURL)/\(contextRest)"
    }
    static var baseURL: String {
        return "\(Config.protocol)://\(Config.host):\(Config.port)/\(Config.context)"
    }
    static var mobileURL: String {
        let contextMobile = value(forKey: "ContextMobile")
        return "\(Config.baseURL)/\(contextMobile)"
    }
    static func value(forKey: String) -> String {
        guard let value = plist[forKey] as? String else {
            fatalError("Could not find property '\(forKey)' in config.plist.")
        }
        return value
    }
}

extension Device {
    enum Header: String {
        case deviceID = "Device-ID"
        case deviceSO = "Device-SO"
        case deviceToken = "Device-Token"
        case deviceModel = "Device-Model"
        case deviceWidth = "Device-Width"
        case deviceHeight = "Device-Height"
        case deviceSOVersion = "Device-SO-Version"
        case deviceAppVersion = "Device-App-Version"
    }
    static var headers: [String: String] {
        var headers = [
            Device.Header.deviceSO.rawValue: Device.so,
            Device.Header.deviceID.rawValue: Device.uuid,
            Device.Header.deviceModel.rawValue: Device.model,
            Device.Header.deviceWidth.rawValue: "\(Device.width)",
            Device.Header.deviceHeight.rawValue: "\(Device.height)",
            Device.Header.deviceSOVersion.rawValue: Device.systemVersion
        ]
        if let version = Device.appVersion {
            headers[Device.Header.deviceAppVersion.rawValue] = version
        }
        if let dispositivo = Dispositivo.current {
            if dispositivo.token != nil {
                headers[Device.Header.deviceToken.rawValue] = dispositivo.token
            }
        }
        return headers
    }
}
