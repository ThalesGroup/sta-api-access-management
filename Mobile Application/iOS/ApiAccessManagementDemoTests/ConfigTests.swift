//
//  ConfigTests.swift
//  ApiAccessManagementDemoTests
//

import XCTest
@testable import ApiAccessManagementDemo

class ConfigTests: XCTestCase {

    func testBadJson() throws {
        
        let badConfig = Config(withJsonString: badJson)
        XCTAssertNil(badConfig)
        
        let emptyConfig = Config(withJsonString: emptyJson)
        XCTAssertNil(emptyConfig)
        
        let incorrectConfig = Config(withJsonString: incorrectKeyedJson)
        XCTAssertNil(incorrectConfig)
    }
    
    func testValidJson() throws {
                
        XCTAssert(jsonStrings.count == configReferences.count)
        
        let references = configReferences
        
        for (index, json) in jsonStrings.enumerated() {
            guard let config = Config(withJsonString: json) else {
                XCTFail("Config must not be nil")
                break
            }
            let reference = references[index]
            XCTAssert(reference.apiUrl == config.apiUrl)
            XCTAssert(reference.publicClientId == config.publicClientId)
            XCTAssert(reference.publicClientSecret == config.publicClientSecret)
            XCTAssert(reference.publicClientWellknown == config.publicClientWellknown)
            XCTAssert(reference.retailClientId == config.retailClientId)
            XCTAssert(reference.retailClientSecret == config.retailClientSecret)
            XCTAssert(reference.retailClientWellknown == config.retailClientWellknown)
        }
    }

    var configReferences: [Config] {
        let reference1 = Config(apiUrl: "https://storeapi.stademo.com:8090",
                               publicClientId: "18c15431-b224-4b6e-b7f4-9b1c206de5c1",
                               publicClientSecret: "d388e288-f2a8-4fc6-9d06-06f21faf3f48",
                               publicClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/I93AD2MBTD-STA/",
                               retailClientId: "b199e219-47b4-4304-a82d-e3f77aedc587",
                               retailClientSecret: "f7b101be-7866-4897-b540-d78ad1b88dbb",
                               retailClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/I93AD2MBTD-STA/")
        
        let reference2 = Config(apiUrl: "https://ayushmahawar-eval-test.apigee.net/store-api/",
                               publicClientId: "5062e01d-03f2-4a9c-a6fd-07ddb9fed319",
                               publicClientSecret: "01009106-1be9-4101-bf48-f94bbf57f48f",
                               publicClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/KX8O5LFZFD-STA/",
                               retailClientId: "cff33557-34d0-4105-a027-74956a9e74ca",
                               retailClientSecret: "2dba5b24-0c46-498e-8b6a-dadcdb43cc79",
                               retailClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/KX8O5LFZFD-STA/")

        let reference3 = Config(apiUrl: "https://ww2quvqcvb.execute-api.us-east-2.amazonaws.com/teststage/",
                               publicClientId: "22787bb2-c02f-4186-a087-438d4b32602f",
                               publicClientSecret: "20549e9a-c1cc-4ecb-a06b-0679076e7923",
                               publicClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/KX8O5LFZFD-STA/",
                               retailClientId: "b3f31b74-54cf-4940-8dfd-703e56dc717d",
                               retailClientSecret: "3a1514ca-4e45-4818-9597-6e3b0533090a",
                               retailClientWellknown: "https://spedemo-sasidp.stademo.com/auth/realms/KX8O5LFZFD-STA/")

        return [reference1, reference2, reference3]
    }

    var jsonStrings: [String] {
        let names = ["AndyInc", "ayush_apigee", "ayush_aws"]
        var jsonStrings = [String]()
        for name in names {
            guard let json = jsonWithName(name) else {
                break
            }
            jsonStrings.append(json)
        }
        return jsonStrings
    }
    
    var badJson: String {
        jsonWithName("bad_data")!
    }
    
    var emptyJson: String {
        jsonWithName("empty")!
    }
    
    var incorrectKeyedJson: String {
        jsonWithName("MissingKeys")!
    }

    func jsonWithName(_ name: String) -> String? {
        
        let bundle = Bundle(for: ConfigTests.self)
        guard let path = bundle.path(forResource: name, ofType: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: URL.init(fileURLWithPath: path))
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
