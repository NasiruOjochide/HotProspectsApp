//
//  ProspectsView.swift
//  HotProspectsApp
//
//  Created by Danjuma Nasiru on 02/03/2023.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter : FilterType
    
    @EnvironmentObject var prospects : Prospects
    @State private var isShowingScanner = false
    @State private var isShowingFilter = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                        HStack{
                            VStack(alignment: .leading){
                                Text(prospect.name)
                                    .font(.headline)
                                Text(prospect.emailAddress)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if filteredProspects == prospects.people{
                                prospect.isContacted ?
                                Image(systemName: "checkmark.message") :
                                Image(systemName: "message")
                            }
                        }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button{
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind Me!", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button{ isShowingScanner = true} label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                    
                    Button{ isShowingFilter = true} label: {
                        Label("filter", systemImage: "circle")
                    }
                }
                
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            }
            .confirmationDialog("Filter", isPresented: $isShowingFilter){
                Button("Name"){
                    filteredProspects.sorted()
                }
                Button("contacted"){
                    filteredProspects.sorted{lhs, rhs in
                        lhs.isContacted == true
                    }
                }
                Button("Uncontacted"){
                    filteredProspects.sorted{lhs, rhs in
                        lhs.isContacted == false
                    }
                }
            }
        }
    }
    
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
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    func handleScan (result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            prospects.add(person)
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
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
