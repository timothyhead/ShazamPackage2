# ShazamKitPackage



A description of this package.

Use 'https://github.com/timothyhead/ShazamKitPackage.git' without quotes as url for package

NB: THe minimun deployment is mac OS 12.0


  1. create a Viewcontroller and create a Label called infoLabel and connect the outlet to your code if using story boards
  
  2.// MARK: - csv file created at path "CSVRec.csv"
// MARK: - ShazamFolder looped through with files numbered from 1 upwards inorder


import Cocoa
import Foundation
import ShazamKit
import AVFoundation
import AppKit
import MusicKit
import ShazamKitPackage

3.
a. The viewController looks like this:

class ViewController: NSViewController, SHSessionDelegate {
    
    
    @IBOutlet weak var infoLabel: NSTextField!
    
    
    let shazamProcesses = ShazamProcesses()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.postInfo, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shazamProcesses.requestMusicAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(self.info(notification:)), name: NSNotification.Name.postInfo, object: nil)
       
        
    }
 
    @objc func info(notification: NSNotification) {
        DispatchQueue.main.async {
            self.infoLabel.stringValue = notification.userInfo?.values.first as! String
            print(notification.userInfo?.values.first as! String)
        }
    }
    
}
b. NOTE: You dont need the infolabel or NotificationCenter if you don't wont any infomation displayed on your ViewController'

4. info.plist should have:
 a. Privacy - Media Library Usage Description
 b. Privacy - Music Usage Description
 c. Privacy - Downloads Folder Usage Description
 5. In Signing and Capabilties in the project target, in the app sandbox, File access type should have the downloads folder selected as read only.
 6. The file that the code accesses that should have your
 music files in should be called  'ShazamFolder' and should be in your downloads folder. It should be comprised of music files with a compatible extension The music files should be  in the range of 3.000000-12.000000 seconds.
 
 7. A csv file is created in /Users/'username'/Library/Containers/'Bundle identifier'/Data/Documents at CSVRec.csv.
