//
//   MatchAppleMusic.swift
//  ShazamKIt-MacOS
//
//  Created by Timothy Head on 15/07/2022.
//

import Foundation
import MusicKit

public class MatchAppleMusic {
    
    public init() {}
    let keyPath:  KeyPath<Song.FilterType, String> = \Song.FilterType.isrc!
   public func matchToAppleMusic(isrc: String) async ->  MusicCatalogResourceResponse<Song>? {
        let songRequest = MusicCatalogResourceRequest<Song>(matching: \.isrc, equalTo: isrc)
        do {
        let musicResponse = try await songRequest.response()
            return musicResponse
        } catch {
            print("error is \(error.localizedDescription)")        }
       return nil
        
    }
 

   public func fetchAlbum(album : String) async -> MusicCatalogSearchResponse?{
        let albumRequest = MusicCatalogSearchRequest(term: album, types: [ Album.self])
        do {
        let albumResponse = try await albumRequest.response()
            return albumResponse
        } catch {
            print("error is \(error.localizedDescription)")
            return nil
        }
      
    }
   public func fetchRecordLabel(recordLabelName: String) async -> MusicCatalogSearchResponse? {
        let recordLabelRequest = MusicCatalogSearchRequest(term: recordLabelName, types: [RecordLabel.self])
        do {
            let recordLabelResponse = try await recordLabelRequest.response()
            return recordLabelResponse
        } catch {
            print("error is \(error.localizedDescription)")
            return nil
        }
    }


}
