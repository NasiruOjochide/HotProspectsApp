//
//  Prospect.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 02/03/2023.
//

import SwiftUI

class Prospect: Identifiable, Codable, Equatable, Comparable {
    static func < (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.name < rhs.name
    }
    
    static func == (lhs: Prospect, rhs: Prospect) -> Bool {
        lhs.id == rhs.id
    }
    
    
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
}



@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]

    let saveKey = "SavedData"
    let fileName = "Prospects"
    
    init() {
        
        //user defaults method
//        if let data = UserDefaults.standard.data(forKey: saveKey){
//            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data){
//                people = decoded
//                return
//            }
//        }
        
        //document's directory method
        do {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = path.appendingPathComponent(fileName)
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([Prospect].self, from: data)
            self.people = decodedData
        } catch {
            print(error.localizedDescription)
            self.people = []
        }
        
        //no saved data
        //self.people = []
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
        
//        or
//        if let index = people.firstIndex(of: prospect){
//            prospect.isContacted.toggle()
//            people[index] = prospect
//        }
        
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save(){
        //user default's method
//        if let encoded = try? JSONEncoder().encode(people){
//            UserDefaults.standard.set(encoded, forKey: saveKey)
//        }
        
        //document's directory method
        if let encoded = try? JSONEncoder().encode(self.people){
            do {
                try encoded.write(to: generateURL(), options: [.atomic, .completeFileProtection])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func generateURL() -> URL{
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let documentURL = url.appendingPathComponent(fileName)
        return documentURL
    }
}
