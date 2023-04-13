//
//  ShazamModel.swift
//  ShazamKIt-MacOS
//
//  Created by Timothy Head on 29/09/2022.
//

import Foundation
import MusicKit


public struct ShazamModel {
    
    var title: String
    var isrc: String
    var artistName: String
    var subTitle: String
    var albumArtURL: URL
    var genres: [String]
    var explicitContent: Bool
    var videoURL: URL
    var releaseDate: Date
    var composerNames: [String]
    var composers: [String]
    var albumTitle_song: String
    var duration: Int
    var durationMinutes: String
    var trackNumber: Int
    var songId: MusicItemID
    var copyright: String
    var albumTitle: String
    var universalPC: String
    var recordLabelName: String
    var isSingle: Bool
    var recordLabels: [String]
   // record
    var recordlabelId: MusicItemID
    var recordlabelName_record: String
    // list of composers

   
}
public struct ListOfComposersModel {
    var listOfComposers : [String]
}



public struct ShazamSongsAndOptioanalsModel {
    var songs: [Song?]
    var albumArtURL: URL?
    var videoURL: URL?
    var releaseDate: Date?
}
