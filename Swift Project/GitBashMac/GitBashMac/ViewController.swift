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
    @IBOutlet var welcomeImage: NSImageView!
    var enable = true
    var minimize = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setWelcomeImage()
        setupIsInstalled()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.title = "GitBash for MacOS"
        constructStatusIem()
        self.view.window?.styleMask.remove(NSWindow.StyleMask.resizable)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func setWelcomeImage(){
        welcomeImage.image =  NSImage(named:"GitBashMac.png")!
    }
    
    func setupIsInstalled(){
        if(gitBashMacisInstalled()){
            enable = false
            print("GitBash is Installed ")
            self.enableButton.title = "Disable";
        } else{
            enable = true
            print("GitBash is not Installed ")
            self.enableButton.title = "Enable";
        }
    }
    
    func gitBashMacisInstalled() -> Bool {
        let command = "[ -f ~/.git-bash-for-mac.sh ] && echo \"Found\" || echo \"Not found\" "
        let found = shell(command)
        if(found.contains("Not")) { return false; }
        return true
    }
    
    func setImage(){
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("GitBashMac.png")
            let image    = NSImage(contentsOfFile: imageURL.path)
            // Do whatever you want with the image
            welcomeImage.image = image
            print("success")
        }
    }
    
    @IBAction func enableButtonAction(_ sender: Any) {
        var command = ""
        var title = ""
        enableButton.isEnabled = false
        if(enable){
            title = "Disable";
            command = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/iDuckDark/GitBashMac/master/Swift%20Project/MetaData/install.sh)\""
        } else{
            enableButton.isEnabled = false
            title = "Enable";
            command = "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/iDuckDark/GitBashMac/master/Swift%20Project/MetaData/uninstall.sh)\""
        }
        do{
            try executeCommand(command, title)
        } catch let error {
            print("Error: \(error)")
        }
    }
    
    func executeCommand(_ command: String, _ title: String) throws {
        self.enableButton.title = "Loading..."
        print(self.shell(command))
        self.enable = !self.enable;
        self.enableButton.title = title
        self.enableButton.isEnabled = true
        self.relaunchTerminal()
        
    }
    
    func relaunchTerminal(){
        print(shell("osascript -e 'quit app \"Terminal\"'"))
        print(shell("osascript -e 'tell application \"Terminal\" to activate'"))
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        
        return output
    }
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func constructStatusIem() {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
        }
        constructMenu()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        if(gitBashMacisInstalled()){
            menu.addItem(NSMenuItem(title: " ✖ Disable GitBashMac", action: #selector(ViewController.enableButtonAction(_:)), keyEquivalent: "D"))
        } else{
            menu.addItem(NSMenuItem(title: " ✔ Enable GitBashMac", action: #selector(ViewController.enableButtonAction(_:)), keyEquivalent: "E"))
        }
        if(minimize){
            menu.addItem(NSMenuItem(title: " + Maximize GitBashMac", action: #selector(ViewController.maximizeWindow(_:)), keyEquivalent: "M"))
            
        } else{
            menu.addItem(NSMenuItem(title: " - Minimize GitBashMac", action: #selector(ViewController.minimizeWindow(_:)), keyEquivalent: "M"))
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit GitBashMac", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func printQuote(_ sender: Any?) {
        let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
        let quoteAuthor = "Mark Twain"
        print("\(quoteText) — \(quoteAuthor)")
    }
    
    func getWindowStatus() -> Int {
        print(NSApp.activationPolicy().rawValue)
        let status: Int = NSApp.activationPolicy().rawValue
        return status
    }
    
    @objc func minimizeWindow(_ sender: Any?){
        NSApp.setActivationPolicy(.accessory)
        // The application is an ordinary app that appears in the Dock and may
        // have a user interface.
        //NSApp.setActivationPolicy(.regular)
        
        // The application does not appear in the Dock and does not have a menu
        // bar, but it may be activated programmatically or by clicking on one
        // of its windows.
        //NSApp.setActivationPolicy(.accessory)
        
        // The application does not appear in the Dock and may not create
        // windows or be activated.
        //NSApp.setActivationPolicy(.prohibited)
        self.minimize = !self.minimize
        constructMenu()
    }
    
    @objc func maximizeWindow(_ sender: Any?){
        NSApp.setActivationPolicy(.regular)
        self.minimize = !self.minimize
        constructMenu()
    }
}
