//
//  ViewController.swift
//  GitBashMac
//
//  Created by iDarkDuck on 2019-01-18.
//  Copyright © 2019 iDarkDuck. All rights reserved.
//

import Cocoa
import Foundation


class ViewController: NSViewController {
    
    @IBOutlet weak var enableButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    

    
    @IBAction func enableButtonAction(_ sender: Any) {
        let currentBranch = bash(command: "git", arguments: ["describe", "--contains", "--all", "HEAD"])
        print("current branch:\(currentBranch)")
    }
    
    
    func shell(launchPath: String, arguments: [String]) -> String{
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)!
        if output.characters.count > 0 {
            //remove newline character.
            let lastIndex = output.index(before: output.endIndex)
            return String(output[output.startIndex ..< lastIndex])
        }
        return output
    }
    
    func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell(launchPath: "/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(launchPath: whichPathForCommand, arguments: arguments)
    }

}
