//
//  MainViewController.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var filterTextField: UITextField!
    @IBOutlet weak var indexedSwitch: UISwitch!
    @IBOutlet weak var useTransactionsSwitch: UISwitch!
    
    var viewModel: MainControllerViewModel!
 
    // MARK: Initializers/Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        viewModel = MainControllerViewModel(withStorageType: .coreData)
        indexedSwitch.setOn(viewModel.isDatabaseIndexed(), animated: false)
    }

    // MARK: IBActions
    
    @IBAction func generateTapped(_ sender: Any) {
        guard let count = Int(countTextField.text ?? "0") else {
            self.log("Please check Count Text Field")
            return
        }

        let activityIndicator = ActivityIndicator(withMessage: "Generating...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleGenerateTapped(count) { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func runTapped(_ sender: Any) {
        let activityIndicator = ActivityIndicator(withMessage: "Searching...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleSearchTapped(self.filterTextField.text) { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }
    
    @IBAction func clearAllTapped(_ sender: Any) {
        let activityIndicator = ActivityIndicator(withMessage: "Clearing...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleClearAllTapped() { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func printStatisticsTapped(_ sender: Any) {
        let activityIndicator = ActivityIndicator(withMessage: "Clearing...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleGetStatisticsTapped() { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func printQueryHelperTapped(_ sender: Any) {
        let activityIndicator = ActivityIndicator(withMessage: "Getting help...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handlePrintQueryHelperTapped() { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func transactionSwitchStateChanged(_ sender: UISwitch) {
        let activityIndicator = ActivityIndicator(withMessage: "Enabling Transactions...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleTransactionSwitchStateChanged(sender.isOn) { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func indexFieldsStateChanged(_ sender: UISwitch) {
        let activityIndicator = ActivityIndicator(withMessage: "Indexing fields...")
        activityIndicator.show(onView: self.view)
        self.viewModel.handleIndexSwitchStateChanged(sender.isOn) { [weak self] (logMessage) in
            self?.log(logMessage)
            activityIndicator.hide()
        }
    }

    @IBAction func helpTapped(_ sender: Any) {
        let helpText = self.viewModel.getHelpText()
        self.log(helpText)
    }

    // MARK: Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse", for: indexPath)
        let type = self.indexPathToStorageType(indexPath)
        cell.textLabel!.text = type.description

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.indexPathToStorageType(indexPath)
        self.viewModel.storageTypeChanged(to: type)
        updateUseTransactionsFieldWithNewStorageType(type)
    }

    // MARK: Utils
    
    func log(_ operationResult: DataStorageOperationResult) {
        self.log(operationResult.description)
    }
    
    func log(_ message: String) {
        self.logTextView.text.append(">> \(message)\n\n")
        let bottom = NSMakeRange(logTextView.text.count - 1, 1)
        logTextView.scrollRangeToVisible(bottom)
    }
    
    func indexPathToStorageType(_ indexPath: IndexPath) -> DatabaseType {
        var type = DatabaseType.coreData
        
        if indexPath.row == 1 {
            type = .realm
        }
        else if indexPath.row == 2 {
            type = .sqlite
        }
        return type
    }
    
    func updateUseTransactionsFieldWithNewStorageType(_ type: DatabaseType) {
        if type == .realm || type == .coreData {
            self.useTransactionsSwitch.setOn(true, animated: false)
            self.useTransactionsSwitch.isEnabled = false
        }
        else {
            self.useTransactionsSwitch.isEnabled = true
        }
    }
}

