//
//  DS100Data.swift
//  DS100ify
//
//  Created by Karl Beecken on 24.10.22.
//

import Foundation

struct Entry: Identifiable, Decodable, Equatable {
    var id: Int {
        EVA_NR
    }

    var EVA_NR: Int
    var DS100: String
    var IFOPT: String
    var NAME: String
    var Verkehr: String
    var Laenge: String
    var Breite: String
    var Betreiber_Name: String
    var Betreiber_Nr: String
    var Status: String
}

struct IntEntry: Identifiable, Decodable, Equatable {
    var id: String {
        RL100Code
    }
    
    var PLC: String
    var RL100Code: String
    var RL100Langname: String
    var RL100Kurzname: String
    var TypKurz: String
    var TypLang: String
    var Betriebszustand: String
    var Datumab: String
    var Datumbis: String
    var Niederlassung: String
    var Regionalbereich: String
    var LetzteÄnderung: String

}

class DS100Data: ObservableObject {
    @Published var data: [Entry] = []
    @Published var intData: [IntEntry] = []

    public func load() {
        var returnedData: [Entry] = []

        let filepath = Bundle.main.url(forResource: "D_Bahnhof_2020_alle", withExtension: "CSV")
        
        if let urlContents = try? String(contentsOf: filepath!) {
            let records = urlContents.components(separatedBy: "\r\n")
            for record in records {
                if record != "" && record != "EVA_NR;DS100;IFOPT;NAME;Verkehr;Laenge;Breite;Betreiber_Name;Betreiber_Nr;Status" {
                    let columns = record.components(separatedBy: ";")
                    var newEntry = Entry(EVA_NR: Int(columns[0])! as Int,
                                         DS100: columns[1] as String,
                                         IFOPT: columns[2] as String,
                                         NAME: columns[3] as String,
                                         Verkehr: columns[4] as String,
                                         Laenge: columns[5] as String,
                                         Breite: columns[6] as String,
                                         Betreiber_Name: columns[7] as String,
                                         Betreiber_Nr: columns[8] as String,
                                         Status: columns[9] as String)
                    newEntry.NAME = newEntry.NAME.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                    newEntry.NAME = newEntry.NAME.trimmingCharacters(in: .whitespacesAndNewlines)
                    returnedData.append(newEntry)
                }
            }
            DispatchQueue.main.async {
                self.data = returnedData.sorted { $0.NAME < $1.NAME }
            }
        }
    }
    
    public func loadInt() {
        var returnedData: [IntEntry] = []
        
        let filepath = Bundle.main.url(forResource: "DBNetz-Betriebsstellenverzeichnis-Stand2021-10", withExtension: "csv")
        
        if let urlContents = try? String(contentsOf: filepath!, encoding: .utf8) {
            let records = urlContents.components(separatedBy: "\r\n")
            for record in records {
                if record != "" && record != "PLC;RL100-Code;RL100-Langname;RL100-Kurzname;Typ Kurz;Typ Lang;Betriebszustand;Datum ab;Datum bis;Niederlassung;Regionalbereich;Letzte Änderung" {
                    let columns = record.components(separatedBy: ";")
                    let newEntry = IntEntry(PLC: columns[0] as String,
                                         RL100Code: columns[1] as String,
                                         RL100Langname: columns[2] as String,
                                         RL100Kurzname: columns[3] as String,
                                         TypKurz: columns[4] as String,
                                         TypLang: columns[5] as String,
                                         Betriebszustand: columns[6] as String,
                                         Datumab: columns[7] as String,
                                         Datumbis: columns[8] as String,
                                         Niederlassung: columns[9] as String,
                                         Regionalbereich: columns[10] as String,
                                         LetzteÄnderung: columns[11] as String)
                    returnedData.append(newEntry)
                }
            }
            DispatchQueue.main.async {
                self.intData = returnedData.sorted { $0.RL100Code < $1.RL100Code }
            }
        }
    }
}
