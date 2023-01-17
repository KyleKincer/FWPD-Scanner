//
//  AdminToolsView.swift
//  Scanner
//
//  Created by Nick Molargik on 1/17/23.
//

import SwiftUI
import Firebase

struct AdminToolsView: View {
    @ObservedObject var viewModel : MainViewModel
    @State private var showProgressBar1 = false
    @State private var progressAmount1 = 0.0
    @State private var totalAmount1 = 0.0
    @State private var progressText = ""
    @State private var controlNum = ""
    @State private var totalAffected = 0
    @State private var totalRecords = 0
    @State private var activities = [Scanner.Activity]()
    @State private var matches = 0
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    emergencyDuplicatePurge()
                }
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 250, height: 50)
                        .foregroundColor(.red)
                    Text("Emergency Duplicate Purge")
                        .foregroundColor(.white)
                }
            })
            
            Button(action: {
                withAnimation {
                    removeRogueFires()
                }
            }, label: {
                ZStack {
                    Capsule()
                        .frame(width: 250, height: 50)
                        .foregroundColor(.red)
                    Text("Remove Rogue Fires")
                        .foregroundColor(.white)
                }
            })
            
            Spacer()
            
            Group {
                if (progressText != "") {
                    Text(progressText)
                }
                
                if (totalRecords > 0) {
                    Text(String(totalRecords) + " unique records pulled")
                }
                
                if (showProgressBar1) {
                    ProgressView("Browsing Records", value: progressAmount1, total: totalAmount1)
                        .tint(.red)
                        .padding()
                }
            }
            
            if (controlNum != "") {
                Text("Control #: " + controlNum)
            }
            
            if (matches > 0) {
                Text(String(matches - 1) + " duplicates found")
            }
            
            if (totalAffected > 0) {
                Text("Total records deleted from server: " + String(totalAffected))
            }
            
            Spacer()
        }
        .padding()
    }
    
    func removeRogueFires() {
        showProgressBar1 = true
        progressAmount1 = 0
        progressText = "Removing Rogue Fires"
        
        Task.init {
            do {
                let db = Firestore.firestore() //Firestore Initialization
                
                let query = try await db.collection("activities")
                    .whereField("isFire", isEqualTo: "true")
                    .getDocuments(source: .server)
                
                matches = query.documents.count
                
                for document in query.documents {
                    totalRecords = query.documents.count
                    totalAmount1 = Double(query.documents.count)
                    
                    db.collection("activities").document(document.documentID).delete() { err in
                        if err != nil {
                            print("Error deleting document")
                        } else {
                            print("Document deleted")
                        }
                    }
                    progressAmount1 += 1
                }
                
                progressText = "Complete"
            }
        }
    }
    
    func emergencyDuplicatePurge() {
        showProgressBar1 = true
        progressText = "Pulling All Records"
        
        // Get all records
        Task.init {
            do {
                // Get first set of activities
                activities = try await viewModel.networkManager.getAllActivities()
                
                progressText = "Pull Complete. Starting Matching."
                
                totalAmount1 = Double(activities.count)
                progressAmount1 = 0
                totalAffected = 0
                totalRecords = activities.count
                var lastControl = ""
                
                for activity in activities {
                    controlNum = activity.controlNumber
                    
                    if (lastControl != controlNum) {
                        
                        let db = Firestore.firestore() //Firestore Initialization
                        
                        let query = try await db.collection("activities")
                            .whereField("control_number", isEqualTo: activity.controlNumber)
                            .getDocuments(source: .server)
                        
                        matches = query.documents.count
                        
                        for document in query.documents {
                            if (document.documentID != activity.id) {
                                totalAffected += 1
                                activities.removeAll {
                                    $0.id == document.documentID
                                }
                                totalRecords = activities.count
                                totalAmount1 = Double(activities.count)

                                db.collection("activities").document(document.documentID).delete() { err in
                                                                    if err != nil {
                                                                        print("Error deleting document")
                                                                    } else {
                                                                        print("Document deleted")
                                                                    }
                                }
                            }
                        }
                        
                        progressAmount1 += 1
                        lastControl = controlNum
                        
                    }
                }
                
                progressText = "Complete"
                
            }
        }
    }
}

struct AdminToolsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminToolsView(viewModel: MainViewModel())
    }
}
