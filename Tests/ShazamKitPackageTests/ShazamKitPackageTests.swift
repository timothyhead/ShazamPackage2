import XCTest
import MusicKit
@testable import ShazamKitPackage

final class ShazamKitLinuxTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ShazamKitPackage().text, "Hello, World!")
    }
    func testInfoLabel_matchesFound_containsTextReturnsTrue() throws {
        // Arrange
        
        let shazamProcesses = ShazamProcesses()
        shazamProcesses.shazamModel = ShazamModel(title: "A", isrc: "A", artistName: "A", subTitle: "A", albumArtURL: URL(string: "nil")!, genres: ["A"], explicitContent: false, videoURL: URL(string: "nil")!, releaseDate: Date(), composerNames: ["A"], composers: ["A"], albumTitle_song: "A", duration: 10, durationMinutes: "A", trackNumber: 10, songId: MusicItemID("A"), copyright: "A", albumTitle: "A", universalPC: "A", recordLabelName: "A", isSingle: false, recordLabels: ["A"], recordlabelId: MusicItemID("A"), recordlabelName_record: "A")
        shazamProcesses.shazamDictionaryArray.append(["A": shazamProcesses.shazamModel as AnyObject])
        shazamProcesses.l = 10
        shazamProcesses.k = 10
                                                  
                                                
        
        //Act
        shazamProcesses.createCSV(from: shazamProcesses.shazamDictionaryArray)
        
        // Assert
        XCTAssertEqual("Csv file created in /Users/'username'/Library/Containers/'Bundle identifier'/Data/Documents at 'CSVRec.csv' \n \n The number of successful matches is 10\n\n The number of unsuccessful matches is 10", shazamProcesses.infoLabel)
        print(shazamProcesses.infoLabel,"A \(shazamProcesses.infoLabel)")
    
        
    }
}
