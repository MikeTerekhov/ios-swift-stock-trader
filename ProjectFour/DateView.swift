//
//  DateView.swift
//  ProjectFour
//
//  Created by Mike Terekhov on 4/16/24.
//

import SwiftUI

struct DateView: View {
    let today = Date()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        Text(dateFormatter.string(from: today))
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.gray)
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.white)))
            .padding(.horizontal, 20)
    }
}

#Preview {
    DateView()
}
