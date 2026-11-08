//
//  SongItem.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/7/26.
//

import SwiftUI

struct SongItem: View {
    let listeningHistoryItem: ListeningHistoryItem
    
    var body: some View {
        let song = listeningHistoryItem.song
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(song.title)")
                            .bold()
                    }
                    .frame(alignment: .leading)
                    HStack {
                        Text("\(song.artist)")
                            .italic()
                    }
                    .frame(alignment: .leading)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.pink.ignoresSafeArea())
        .cornerRadius(10)
    }
}

// MARK: - Mocks

extension Song {
    static let mock = Song(
        id: "4cOdK2wGLETKBW3PvgPWqT",
        title: "Never Gonna Give You Up",
        artist: "Rick Astley",
        albumTitle: "Whenever You Need Somebody",
        duration: 213,
        imageURL: URL(string: "https://i.scdn.co/image/ab67616d0000b27315ebbedaacef61af244262a8"),
        uri: URL(string: "spotify:track:4cOdK2wGLETKBW3PvgPWqT")
    )
}

extension ListeningHistoryItem {
    static let mock = ListeningHistoryItem(
        song: .mock,
        playedAt: .now.addingTimeInterval(-15 * 60)   // 15 minutes ago
    )
}

// MARK: - Preview

#Preview {
    List {
        SongItem(listeningHistoryItem: .mock)
            .listRowBackground(Color.clear)
    }
    .scrollContentBackground(.hidden)         // hide the List's default background
    .background(Color(red: 1.0, green: 0.89, blue: 0.88))
}
