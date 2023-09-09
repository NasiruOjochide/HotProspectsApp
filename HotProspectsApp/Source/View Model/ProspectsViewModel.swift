//
//  Prospects.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 09/09/2023.
//

import CodeScanner
import Foundation
import UserNotifications

@MainActor class ProspectsViewModel: ObservableObject {
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @Published private(set) var people: [Prospect]
    @Published var isShowingScanner = false
    @Published var isShowingFilter = false
    @Published var filter: FilterType = .none
    let saveKey = "SavedData"
    let fileName = "Prospects"
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return people
        case .contacted:
            return people.filter { $0.isContacted }
        case .uncontacted:
            return people.filter { !$0.isContacted }
        }
    }
    
    func handleScan (result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            add(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings{settings in
            if settings.authorizationStatus == .authorized{
                addRequest()
            }else{
                center.requestAuthorization(options: [.sound, .badge, .alert]){success, error in
                    if success{
                        addRequest()
                    }else{
                        if let error = error{
                            print("\(error.localizedDescription) : mess up...")
                        }
                    }
                }
            }
        }
    }
    
    
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
