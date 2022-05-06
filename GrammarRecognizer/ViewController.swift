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
    @IBOutlet weak var emptyImageView: UIImageView!
    private var response = [String: [String]]()
    private var responseKeys = [String]()
    public var firstClick: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.EmptyStateControl()
        
        self.textView.delegate = self
        self.tableView.dataSource = self
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        response = [String: [String]]()
        responseKeys = [String]()
        self.grammarSeparator(text: textView.text)
        self.textView.endEditing(true)
    }
    
    @IBAction func clearButton(_ sender: UIButton) {
        if textView.text == "Type here..." {
            return
        } else {
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to clear your text?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
                self.textView.text = ""
                self.response = [String: [String]]()
                self.responseKeys = [String]()
                self.tableView.reloadData()
                self.EmptyStateControl()
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func configureUI() {
        textView.text = "Type here..."
        textView.layer.cornerRadius = 16
        button.layer.cornerRadius = 16
        self.view.backgroundColor = UIColor(named: "midnightBlue")
        self.tableView.backgroundColor = UIColor(named: "midnightBlue")
        self.textView.backgroundColor = .lightGray
    }
    
    private func EmptyStateControl() {
        if responseKeys.count == 0 {
            tableView.isHidden = true
            emptyImageView.isHidden = false
        } else {
            tableView.isHidden = false
            emptyImageView.isHidden = true
        }
    }
    
    private func grammarSeparator(text: String) {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                var current = response[tag.rawValue] ?? []
                
                if tag.rawValue == "Noun" {
                    if !current.contains(text[tokenRange].description){
                        current.append(text[tokenRange].description)
                    }
                    response[tag.rawValue] = current
                } else {
                    if !current.contains(text[tokenRange].description.lowercased()){
                        current.append(text[tokenRange].description.lowercased())
                    }
                    response[tag.rawValue] = current
                }
                
            }
            return true
        }
        
        let a = response.keys
        responseKeys.append(contentsOf: a)
        self.EmptyStateControl()
        tableView.reloadData()
        
    }
    
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if firstClick {
            firstClick = false
            textView.text = ""
        } else {
            return
        }
        
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let words = response[responseKeys[indexPath.section]]?.joined(separator: ", ")
        
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

