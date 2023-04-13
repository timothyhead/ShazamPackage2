//
//  ShazamProcesses.swift
//  ShazamKIt-MacOS
//
//  Created by Timothy Head on 29/09/2022.
//

import Foundation
import MusicKit
import AVFoundation
import ShazamKit
import Cocoa

public class ShazamProcesses: NSObject, SHSessionDelegate {
    
    var shazamModel = ShazamModel(title: "", isrc: "", artistName: "", subTitle: "", albumArtURL: URL(string: "nil")!, genres: [""], explicitContent: false, videoURL: URL(string: "nil")!, releaseDate: Date(), composerNames: [""], composers: [""], albumTitle_song: "", duration: 0, durationMinutes: "0", trackNumber: 0, songId: MusicItemID(""), copyright: "", albumTitle: "",universalPC: "", recordLabelName: "", isSingle: false, recordLabels: [""], recordlabelId: MusicItemID(""), recordlabelName_record: "")
    var listOfComposersModel = ListOfComposersModel(listOfComposers: [""])
    var songs = ShazamSongsAndOptioanalsModel(songs: [nil], albumArtURL: nil, videoURL: nil, releaseDate: nil)
    var shazamDictionaryArray: [Dictionary<String, AnyObject>] = Array()
    var isUsingInAppFolder = true
    //if using folder in downloads folder use this
    let manager = FileManager.default
    // if using folder in xcode proj use this
    var hasURLs = true
    var songNumbers = [Int]()
    var csvString = ""
    var fileUrls = [URL]()
   public var infoLabel = ""
 
    
    
    // counts the number of urls in get URLS func
    var i = 1
    // counts the number of matches or unsuccesful matches
    var j = 0
    // the number of successful matches
    var k = 0
    // the number of unsuccessful matches
    var l = 0
    // in didFind match func or didNotFindMatchFor func when 'j + 1  = i' all matching attemps done and csv file created at path "CSVRec.csv"
    
    // musicKIt
    
    var matchAppleMusic = MatchAppleMusic()
    
    var player: AVAudioPlayer!
    
       let session  = SHSession()
    
    public  func requestMusicAuthorization()  {
        Task.detached {
            let authorizationStatus = await MusicAuthorization.request()
            if authorizationStatus == .authorized {
               self.shazamTheURLS()
           
            } else {
                // User denied permission.
                print("User denied permisssion")
               
            }
        }
        
    }
    public  func shazamTheURLS() {
        
        
        guard let  urls = getUrlsFromDownloadFolder() else {
            DispatchQueue.main.async {
                self.infoLabel = "Url is wrong"
            }
            return
            
        }
        print(urls)
        
        
        var m = 0
        for url in urls {
            
            // remove .DS_Store file from folder which is automaticaly created when using downloads folder
            if url.absoluteString.contains(".DS_Store") {
                fileUrls.remove(at: m)
                continue
            }
            
            m += 1
            
            if m == i - 1 {
                
                generateSignatures(url: fileUrls[0])
                return
            }
            
        }
        
    }
    

public func generateSignatures(url: URL) {
    
 
    
    guard let  signature = generateSignature(from: url) else {
        DispatchQueue.main.async {
            self.infoLabel = "Failure generating signature"
        }
        return
    }
    
    
    //       Create a signature from the captured audio buffer.
    
    session.delegate = self
    // Check for a match.
    
    session.match(signature)
    
    
    
    // The delegate method that the session calls when matching a reference item.
    
    
    // The delegate method that the session calls when there is no match.
    
}
    public func generateSignature(from audioURL: URL) -> SHSignature? {
        // Step 1.
        // Create an audio format that's compatible with ShazamKit.
        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1) else {
            // Handle an error in creating the audio format.
            DispatchQueue.main.async {
                self.infoLabel = "Error creating audio format"
            }
            return nil
        }
        
        
        // Create a signature generator to generate the final signature.
        let signatureGenerator = SHSignatureGenerator()
        
        do {
            // Create an object for reading the audio file.
            let audioFile = try AVAudioFile(forReading: audioURL)
            // to change length of audioFile uncomment below and adjust as needed
            //  audioFile.framePosition = audioFile.length - 200000
            
            
            // Step 2.
            // Convert the audio to a supported format.
            ShazamProcesses.convert(audioFile: audioFile, outputFormat: audioFormat) { buffer in
                do {
                    
                    // Step 3.
                    // Append portions of the converted audio to the signature generator.
                    try signatureGenerator.append(buffer, at: nil)
                } catch {
                    // Handle an error generating the signature.
                    DispatchQueue.main.async {
                        self.infoLabel = "error generating the signature"
                    }
                    return
                }
            }
        } catch {
            // Handle an error reading the audio file.
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.infoLabel = "\(error.localizedDescription)"
            }
            return nil
        }
        
        // Step 4.
        // Generate the signature.
        return signatureGenerator.signature()
    }
}
extension ShazamProcesses {
    
    public  static func convert(audioFile: AVAudioFile,
                        outputFormat: AVAudioFormat,
                        processConvertedBlock: (AVAudioPCMBuffer) -> Void) {
        
        // Set the size of the conversion buffer.
        let frameCount = AVAudioFrameCount(
            (1024 * 64) / (audioFile.processingFormat.streamDescription.pointee.mBytesPerFrame)
        )
        // Calculate the number of frames for the output buffer.
        let outputFrameCapacity = AVAudioFrameCount(
            round(Double(frameCount) * (outputFormat.sampleRate / audioFile.processingFormat.sampleRate))
        )
        
        // Create the input and output buffers for converting the file.
        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount),
              let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
            return
        }
        
        // Create the format for the converter.
        guard let converter = AVAudioConverter(from: audioFile.processingFormat, to: outputFormat) else {
            return
        }
        
        // Code to convert the file goes here. See the next listing.
        while true {
            let status = converter.convert(to: outputBuffer,
                                           error: nil) { inNumPackets, outStatus in
                do {
                    // Read a frame from the audio file into the input buffer.
                    try audioFile.read(into: inputBuffer)
                    outStatus.pointee = .haveData
                    return inputBuffer
                } catch {
                    // Check if it's the end of the file or if an error occurred.
                    if audioFile.framePosition >= audioFile.length {
                        outStatus.pointee = .endOfStream
                        
                        return nil
                    } else {
                        outStatus.pointee = .noDataNow
                        
                        return nil
                    }
                }
            }
            
            
            
            switch status {
            case .error:
                // An error occurred during conversion; handle the error.
                return
                
            case .endOfStream:
                // All of the input is converted.
                return
                
            case .inputRanDry:
                // Some data was converted, but no more is available.
                processConvertedBlock(outputBuffer)
                return
                
            default:
                processConvertedBlock(outputBuffer)
            }
            
            // Reset the size of the buffers.
            inputBuffer.frameLength = 0
            outputBuffer.frameLength = 0
            
        }
        
    }
}
extension ShazamProcesses {
    
    // match functions
    
    public func session(_ session: SHSession, didFind match: SHMatch) {
     
        // formatter for durations
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        j += 1
        //    get results
        let items = match.mediaItems
        items.forEach { item in
            if let title =  item.title {
                shazamModel.title = title
            } else {
                shazamModel.title = "title"
            }
            if let artist = item.artist {
                shazamModel.artistName = artist
            } else {
                shazamModel.artistName = "artistName"
            }
            if let subtitle = item.subtitle {
                shazamModel.subTitle = subtitle
            } else {
                shazamModel.subTitle = "subTitle"
            }
            if let artworkURL = item.artworkURL {
                songs.albumArtURL = artworkURL.absoluteURL
                shazamModel.albumArtURL = songs.albumArtURL!
            }
            shazamModel.genres = item.genres
            shazamModel.explicitContent = item.explicitContent
            if let videoURL = item.videoURL {
                songs.videoURL = videoURL.absoluteURL
                shazamModel.videoURL = songs.videoURL!
            }
           
           
            songs.songs  = item.songs
            for song in songs.songs {
                if let releaseDate = song?.releaseDate {
                    songs.releaseDate = releaseDate
                    shazamModel.releaseDate = songs.releaseDate!
                }
            }
            if let isrc = item.isrc {
                shazamModel.isrc = isrc
                Task {
                    // get MusicCatalogResourceResponse<Song>?
                   let music =  await matchAppleMusic.matchToAppleMusic(isrc: isrc)
                  
                    // if there is a MusicCatalogResourceResponse<Song>? object get the info from it
                    if let music = music {
                    if  !music.items.isEmpty {
                        // get full list of composer names in composerName array
                        for item in music.items {
                            shazamModel.composerNames.append(item.composerName ?? "")
                        }
                        if let composers = music.items.first?.composers {
                            for composer in composers {
                                shazamModel.composers.append(composer.name)
                                
                            }
                        
                        
                        }
                       
                       
                        shazamModel.duration = Int(music.items.first?.duration ?? 0)
                        let duration = Double(music.items.first?.duration ?? 0)
                        if duration != 0 {
                            let durationdividedBy60 = duration  / 60
                            let durationDecimalMinutes = NSNumber(value: durationdividedBy60)
                          
                            let durationMinutes = formatter.string(from: durationDecimalMinutes)
                            let decimalFractionOfDurationMinutes = Double(truncating: durationDecimalMinutes) - (Double(durationMinutes ?? "") ?? 0)
                            let durationSeconds = decimalFractionOfDurationMinutes * 60
                            if durationSeconds < 10 {
                                shazamModel.durationMinutes =  (durationMinutes ?? "0") + ":0\(Int(durationSeconds))"
                            } else {
                                shazamModel.durationMinutes =  (durationMinutes ?? "0") + ":\(Int(durationSeconds))"
                            }
                         
                        }
               
                            
                        
                 
                        shazamModel.trackNumber = music.items.first?.trackNumber ?? 0
                        shazamModel.songId = music.items.first?.id ?? ""
                       
                      
                        // get  album title in the MusicCatalogResourceResponse<Song>? object
                        shazamModel.albumTitle_song = music.items.first?.albumTitle ?? ""
                        if let firstAlbumTitle = music.items.first?.albumTitle {
                            shazamModel.albumTitle_song = firstAlbumTitle
                           
                            // get the album with new funtion
                        let album = await matchAppleMusic.fetchAlbum(album: firstAlbumTitle)
                            if let album = album {
                            if !album.albums.isEmpty {
                                shazamModel.copyright = album.albums.first?.copyright ?? ""
                                if let recoredLabels = album.albums.first?.recordLabels {
                                    for recordLabel in recoredLabels {
                                        shazamModel.recordLabels.append(recordLabel.name)
                                        
                                    }
                                
                                }
                                
                                 
                                shazamModel.isSingle = album.albums.first?.isSingle ?? false
                                shazamModel.albumTitle = album.albums.first?.title ?? ""
                                shazamModel.universalPC = album.albums.first?.upc ?? ""
                                
                                
                                // use recordLabelName for recordLabel ID
                                shazamModel.recordLabelName = album.albums.first?.recordLabelName ?? ""
                                let recordLabels = await matchAppleMusic.fetchRecordLabel(recordLabelName: shazamModel.recordLabelName)
                                shazamModel.recordlabelName_record = recordLabels?.recordLabels.first?.name ?? ""
                                
                               shazamModel.recordlabelId = recordLabels?.recordLabels.first?.id ?? MusicItemID("")
                                
                            }
                            }
                           
                        }
                      
                    }
                  
                     
                    }
                    shazamDictionaryArray.append(["\(j)  \(fileUrls[j - 1])" : shazamModel as AnyObject])
                    l += 1
                    
                    // when 'j + 1  = i' all matching attemps done and csv file created at path "CSVRec.csv"
                    if j + 1 == i  {
                        self.createCSV(from: self.shazamDictionaryArray)
                        return
                    }
                    generateSignatures(url: fileUrls[j])
                }
              
            } else {
                shazamModel.isrc = "isrc"
                shazamDictionaryArray.append(["\(j)  \(fileUrls[j - 1])" : shazamModel as AnyObject])
                l += 1
                
                // when 'j + 1  = i' all matching attemps done and csv file created at path "CSVRec.csv"
                if j + 1 == i  {
                    self.createCSV(from: self.shazamDictionaryArray)
                    return
                }
                generateSignatures(url: fileUrls[j])
              
            }
           
            
        }
      
        
    }
    
    public  func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature, error: Error?) {
        print("No match found")
        j += 1
        
        if let error = error {
            print(error)
        }
        k += 1
       
        // when 'j + 1  = i' all matching attemps done and csv file created at path "CSVRec.csv"
        if j + 1 == i {
            self.createCSV(from: self.shazamDictionaryArray)
            return
        }
        generateSignatures(url: fileUrls[j])
        
    }
}
extension ShazamProcesses {
    
    
    
    public func createCSV(from recArray:[Dictionary<String, AnyObject>]){
     
    
        
        for dct in recArray {
            
            csvString.append("\(dct.keys) \(String(describing: dct.values))\n\n")
            
        }
        
        
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSVRec.csv")
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
   
                
                self.infoLabel = "Csv file created in /Users/'username'/Library/Containers/'Bundle identifier'/Data/Documents at 'CSVRec.csv' \n \n The number of successful matches is \(self.l)\n\n The number of unsuccessful matches is \(self.k)"
                let  info = ["userInfo" : self.infoLabel]
                
                NotificationCenter.default.post(name: Notification.Name.postInfo, object: nil, userInfo: info)
                
            
        } catch {
            print("error creating file")
            
                self.infoLabel = "Sorry error creating csv file"
                
                let  info = ["userInfo" : self.infoLabel]
                
                NotificationCenter.default.post(name: Notification.Name.postInfo, object: nil, userInfo: info)
            
        }
       
    }
}

extension ShazamProcesses {
    
    // for files in downloads folder
    
    public func getUrlsFromDownloadFolder() -> [URL]? {
        do {
            let rootFolderURL = try manager.url (
                for: .downloadsDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            let nestedFolderURL = rootFolderURL.appendingPathComponent("ShazamFolder")
            
            
             fileUrls =   try! manager.contentsOfDirectory(at: nestedFolderURL, includingPropertiesForKeys: nil)
            
            
            i = fileUrls.count
            return fileUrls
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}


