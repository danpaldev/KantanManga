//
//  CompoundDictionary.swift
//  MangaReader
//
//  Created by Juan on 10/01/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation
import SQLite

struct DictionaryResult {
    let word: [String]
    let meanings: [String]
    let entryId: Int64
}

enum DictionaryError: Error {
    case canNotGetLibraryURL
    case dictionaryAlreadyExists
}

class CompoundDictionary {
    private var db: Connection?

    func createDataBase(fileName: String = "dic.db", fileManager: FileManager = .default) throws {
        guard let libraryUrl = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            throw DictionaryError.canNotGetLibraryURL
        }

        let dbUrl = libraryUrl.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: dbUrl.absoluteString) else {
            throw DictionaryError.dictionaryAlreadyExists
        }

        let db = try Connection(dbUrl.absoluteString)
        try DBRepresentation.Dictionaries.createTable(in: db)
        try DBRepresentation.Kanji.createTable(in: db)
        try DBRepresentation.KanjiMeta.createTable(in: db)
        try DBRepresentation.Terms.createTable(in: db)
        try DBRepresentation.TermsMeta.createTable(in: db)
        try DBRepresentation.Tags.createTable(in: db)
    }

    func dictionaryExists(title: String, revision: String) -> Bool {
        guard let db = db else { return false }
        do {
            let count = try db.scalar(
                DBRepresentation.Dictionaries.table.filter(
                    DBRepresentation.Dictionaries.title == title &&
                        DBRepresentation.Dictionaries.revision == revision
                ).count
            )
            return count < 1
        } catch {
            return false
        }
    }

    func findWord(word: String) -> [DictionaryResult] {
        guard let dictUrl = Bundle.main.url(forResource: "jamdict", withExtension: "db") else {
            return []
        }

        let sense = Table("Sense")
        let senseGloss = Table("SenseGloss")
        let kanji = Table("Kanji")
        let kana = Table("Kana")
        let idColumn = Expression<Int64>("ID")
        let idseqColumn = Expression<Int64>("idseq")
        let sidColumn = Expression<Int64>("sid")
        let textColumn = Expression<String>("text")

        var result = [DictionaryResult]()
        do {
            let connection = try Connection(dictUrl.absoluteString)
            let query = try connection.prepare("SELECT * FROM Entry WHERE idseq IN (SELECT idseq FROM Kanji WHERE text == ?) OR idseq IN (SELECT idseq FROM Kana WHERE text == ?) OR idseq IN (SELECT idseq FROM sense JOIN sensegloss ON sense.ID == sensegloss.sid WHERE text == ?)")
            for entry in try query.run([word, word, word]) {
                guard let idseq = entry[0] as? Int64 else { continue }
                let kanjis = try connection.prepare(kanji.select(textColumn).filter(idseqColumn == idseq))
                var words = [String]()
                for kanji in kanjis {
                    words.append(kanji[textColumn])
                }

                let kanas = try connection.prepare(kana.select(textColumn).filter(idseqColumn == idseq))
                for kana in kanas {
                    words.append(kana[textColumn])
                }

                var meanings = [String]()
                let senses = try connection.prepare(sense.filter(idseqColumn == idseq))
                for sense in senses {
                    var senseGlosses = [String]()
                    let glosses = try connection.prepare(senseGloss.select(textColumn).filter(sidColumn == sense[idColumn]))
                    for gloss in glosses {
                        senseGlosses.append(gloss[textColumn])
                    }
                    meanings.append(senseGlosses.joined(separator: "; "))
                }

                result.append(DictionaryResult(word: words, meanings: meanings, entryId: idseq))
            }
        } catch let error {
            print(error)
        }

        return result
    }
}