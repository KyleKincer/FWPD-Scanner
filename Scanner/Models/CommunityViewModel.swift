//
//  CommunityViewModel.swift
//  Scanner
//
//  Created by Kyle Kincer on 12/13/22.
//

import Foundation
import SwiftUICharts
import Firebase

class CommunityViewModel: ObservableObject {
        
    func getMostActiveCommenters() -> ChartData {
        var values: [(String, Int)] = []
        let query = Firestore.firestore().collection("users").order(by: "commentCount", descending: true).limit(to: 10)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting most active commenters: \(error)")
            } else {
                let users = querySnapshot!.documents.map { (document) -> User in
                    // Initialize a new User object with the data from the document
                    let user = User(document: document)
                    return user
                }
                
                for user in users {
                    values.append((user.username, user.commentCount ?? 0))
                }
            }
        }
        return ChartData(values: values)
    }
}
