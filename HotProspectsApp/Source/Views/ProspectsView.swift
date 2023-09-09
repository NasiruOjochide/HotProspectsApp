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
    
    @ObservedObject var prospectsVM = ProspectsViewModel()
    
    init(filter: ProspectsViewModel.FilterType) {
        prospectsVM.filter = filter
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(prospectsVM.filteredProspects) { prospect in
                    HStack{
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if prospectsVM.filteredProspects == prospectsVM.people{
                            prospect.isContacted ?
                            Image(systemName: "checkmark.message") :
                            Image(systemName: "message")
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospectsVM.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospectsVM.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button{
                                prospectsVM.addNotification(for: prospect)
                            } label: {
                                Label("Remind Me!", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
            .navigationTitle(prospectsVM.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button{ prospectsVM.isShowingScanner = true} label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                    
                    Button{ prospectsVM.isShowingFilter = true} label: {
                        Label("filter", systemImage: "circle")
                    }
                }
                
            }
            .sheet(isPresented: $prospectsVM.isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com") { prospectsVM.handleScan(result: $0)
                }
            }
            .confirmationDialog("Filter", isPresented: $prospectsVM.isShowingFilter){
                Button("Name"){
                    let _ = prospectsVM.filteredProspects.sorted()
                }
                Button("contacted"){
                    let _ = prospectsVM.filteredProspects.sorted{lhs, rhs in
                        lhs.isContacted == true
                    }
                }
                Button("Uncontacted"){
                    let _ = prospectsVM.filteredProspects.sorted{lhs, rhs in
                        lhs.isContacted == false
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
