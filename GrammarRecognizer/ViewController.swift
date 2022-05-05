//
//  ViewController.swift
//  GrammarRecognizer
//
//  Created by Santiago del Castillo Gonzaga on 04/05/22.
//

import UIKit
import NaturalLanguage

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var response = [String: [String]]()
    private var responseKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        
        self.textView.delegate = self
        self.tableView.dataSource = self
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        self.grammarSeparator(text: textView.text)
    }
    
    private func configureUI() {
        textView.text = "Type here..."
        textView.layer.cornerRadius = 16
        button.layer.cornerRadius = 16

    }
    
    private func grammarSeparator(text: String) {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                var current = response[tag.rawValue] ?? []
                if !current.contains(text[tokenRange].description){
                    current.append(text[tokenRange].description)
                }
                response[tag.rawValue] = current

            }
            return true
        }
        
        let a = response.keys
        responseKeys.append(contentsOf: a)
        tableView.reloadData()
    }
    
}

extension ViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        var words = response[responseKeys[indexPath.section]]?.joined(separator: ", ")
        content.text = words
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return responseKeys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return responseKeys[section]
    }
    
    
}

