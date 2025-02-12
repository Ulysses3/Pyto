//
//  MenuViewController.swift
//  Pyto
//
//  Created by Adrian Labbé on 4/17/19.
//  Copyright © 2019 Adrian Labbé. All rights reserved.
//

import UIKit
import FileBrowser

/// A View controller for choosing from `REPL`, `PyPi` and `Settings` from an `UIDocumentBrowserViewController`.
class MenuTableViewController: UITableViewController {
    
    /// Closes this View controller.
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Opens the REPL.
    func selectREPL() {
        if let repl = self.storyboard?.instantiateViewController(withIdentifier: "repl") {
            present(repl, animated: true, completion: nil)
        }
    }
    
    /// Opens PyPi.
    func selectPyPi() {
        if let pypi = self.storyboard?.instantiateViewController(withIdentifier: "pypi") {
            present(UINavigationController(rootViewController: pypi), animated: true, completion: nil)
        }
    }
    
    /// Show samples..
    func selectSamples() {
        guard let samples = Bundle.main.url(forResource: "Samples", withExtension: nil) else {
            return
        }
        
        let presentingVC = presentingViewController
        
        let fileBrowser = FileBrowser(initialPath: samples, allowEditing: false, showCancelButton: true)
        fileBrowser.didSelectFile = { file in
            guard file.filePath.pathExtension.lowercased() == "py" else {
                return
            }
            
            fileBrowser.presentingViewController?.dismiss(animated: true) {
                (presentingVC as? DocumentBrowserViewController)?.openDocument(file.filePath, run: false)
            }
        }
        
        present(fileBrowser, animated: true, completion: nil)
    }
    
    /// Opens documentation.
    func selectDocumentation() {
        let documentation = DocumentationViewController()
        present(ThemableNavigationController(rootViewController: documentation), animated: true, completion: nil)
    }
    
    /// Shows loaded modules.
    func selectLoadedModules() {
                
        func checkModules() {
            Python.shared.run(code: "import modules_inspector; modules_inspector.main()")
        }
        
        present(UINavigationController(rootViewController: ModulesTableViewController(style: .grouped)), animated: true, completion: nil)
        
        checkModules()
    }
    
    /// Opens settings.
    func selectSettings() {
                
        if let settings = UIStoryboard(name: "Settings", bundle: nil).instantiateInitialViewController() {
            let navVC = UINavigationController(rootViewController: settings)
            navVC.navigationBar.prefersLargeTitles = true
            navVC.modalPresentationStyle = .formSheet
            present(navVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view controller
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        guard #available(iOS 13.0, *) else {
            return cell
        }
        
        var image: UIImage?
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            image = UIImage(systemName: "play.fill")
        case IndexPath(row: 1, section: 0):
            image = UIImage(systemName: "doc.fill")
        case IndexPath(row: 0, section: 1):
            image = UIImage(named: "pypi")
        case IndexPath(row: 0, section: 2):
            image = UIImage(systemName: "bookmark.fill")
        case IndexPath(row: 1, section: 2):
            image = UIImage(systemName: "book.fill")
        case IndexPath(row: 0, section: 3):
            image = UIImage(systemName: "info.circle.fill")
        case IndexPath(row: 1, section: 3):
            image = UIImage(systemName: "gear")
        default:
            break
        }
        cell.imageView?.image = image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            selectREPL()
        case IndexPath(row: 0, section: 1):
            selectPyPi()
        case IndexPath(row: 0, section: 2):
            selectSamples()
        case IndexPath(row: 1, section: 2):
            selectDocumentation()
        case IndexPath(row: 0, section: 3):
            selectLoadedModules()
        case IndexPath(row: 1, section: 3):
            selectSettings()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        var buildDate: Date {
            if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"), let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath), let infoDate = infoAttr[.creationDate] as? Date {
                return infoDate
            } else {
                return Date()
            }
        }
        
        if section == 3, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            
            return """
            \nPyto version \(version) (\(build)) \(formatter.string(from: buildDate))
            
            Python \(Python.shared.version)
            """
        } else {
            return super.tableView(tableView, titleForFooterInSection: section)
        }
    }
}
