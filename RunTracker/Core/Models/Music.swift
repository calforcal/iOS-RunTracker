//
//  Music.swift
//  RunTracker
//
//  Created by Michael Callahan on 11/3/26.
//

import Foundation

// MARK: - Song

struct Song: Identifiable, Hashable, Sendable {
    let id: String                // Spotify track id
    let title: String
    let artist: String
    let albumTitle: String?
    let duration: TimeInterval    // seconds
    let imageURL: URL?
    let uri: URL?                 // e.g. spotify:track:abc123 (opens the Spotify app)

    /// Link to the track on the web, useful for ShareLink or as a fallback
    /// when the Spotify app isn't installed.
    var webURL: URL? { URL(string: "https://open.spotify.com/track/\(id)") }

    /// "3:45" style duration.
    var formattedDuration: String {
        Duration.seconds(duration).formatted(.time(pattern: .minuteSecond))
    }
}

extension Song {
    /// Returns nil if the response has no Spotify id.
    init?(_ response: Components.Schemas.SongResponse) {
        guard let id = response.spotify_id, !id.isEmpty else { return nil }
        self.init(
            id: id,
            title: response.title ?? "Unknown title",
            artist: response.artist ?? "Unknown artist",
            albumTitle: response.album_title,
            duration: Double(response.duration_ms ?? 0) / 1_000,
            imageURL: response.image_url.flatMap(URL.init(string:)),
            uri: response.uri.flatMap(URL.init(string:))
        )
    }
}

// MARK: - Listening history

struct ListeningHistoryItem: Identifiable, Hashable, Sendable {
    let song: Song
    let playedAt: Date

    /// The same song can appear more than once, so the id combines
    /// the song with when it was played.
    var id: String { "\(song.id)-\(playedAt.timeIntervalSince1970)" }
}

extension ListeningHistoryItem {
    /// Returns nil if the song or play time is missing.
    init?(_ response: Components.Schemas.ListeningHistoryItemResponse) {
        guard
            let songResponse = response.song,
            let song = Song(songResponse),
            let playedAt = response.played_at
        else { return nil }
        self.init(song: song, playedAt: playedAt)
    }
}

struct ListeningHistory: Hashable, Sendable {
    /// Most recent first.
    let items: [ListeningHistoryItem]

    var isEmpty: Bool { items.isEmpty }
    var mostRecent: ListeningHistoryItem? { items.first }

    /// Songs played during a time window, e.g. while an activity was recorded.
    func items(from start: Date, to end: Date) -> [ListeningHistoryItem] {
        items.filter { $0.playedAt >= start && $0.playedAt <= end }
    }
}

extension ListeningHistory {
    init(_ response: Components.Schemas.ListeningHistoryResponse) {
        self.init(
            items: (response.items ?? [])
                .compactMap(ListeningHistoryItem.init)
                .sorted { $0.playedAt > $1.playedAt }
        )
    }
}
