//
//  ViewController.swift
//  Pretty
//
//  Created by Octree on 2018/4/5.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.red.cgColor
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOpenFile(notification:)), name: NSNotification.Name(rawValue: OCTOpenFileNotification), object: nil)
        FileName = "/Users/jzd/Movies/podfile_lock_resolution/three/Pretty/Resource/one.json"
        if FileName.count > 0 {
            parse(file: FileName)
        }
    }
    

    
    @objc func handleOpenFile(notification: Notification) {
        
        guard let filename = notification.object as? String else {
            return
        }
        parse(file: filename)
    }
    
    
    
    
    
    
    func parse(file name: String) {
        
        if name.hasSuffix(".json") {
            handle(file: name)
        }
    }
    
    
    
    
    
    func handle(file name: String) {
        do {
            let content = try String(contentsOfFile: name, encoding: .utf8)
            let myStrings = content.components(separatedBy: .newlines)
            
            var result = [String]()
            
            
            
            for ln in myStrings{
                
                
                if ln.contains("\""){
                    
                    let cakes = ln.components(separatedBy: ":")
                    
                    var onePiece: String?
                    
                    if cakes.count == 2{
                        
                        onePiece = "let "
                        print(cakes[0])
                        onePiece?.append(cakes[0].k)
                        
                        onePiece?.append(" : ")
                        
                        let val = cakes[1].replacingOccurrences(of: " ", with: "")
                        
                        if Int(val) == nil{
                            onePiece?.append("String")
                        }
                        else{
                            onePiece?.append("Int")
                        }
                    }
                    
                    if let info = onePiece{
                        result.append(info)
                    }

                }
                
                
                
            }
            
            
            
            result.forEach {
                print($0)
            }
            
        } catch {
            
            alert(title: "Error", msg: error.localizedDescription)
        }
    }
    
    

    
    
    func alert(title: String, msg: String) {

        
        let alert = NSAlert()
        
        
        alert.addButton(withTitle: "Ok")
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .warning
        alert.runModal()
    }

}




extension String{
    
    var k: String{
        let ret = matches(for: "^\"(.+)\"$")
        return ret[0]
    }
    
    
    
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error)")
            return []
        }
    }
    
    
}



