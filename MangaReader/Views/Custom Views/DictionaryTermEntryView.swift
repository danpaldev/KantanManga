//
//  DictionaryTermEntryView.swift
//  MangaReader
//
//  Created by Juan on 28/05/20.
//  Copyright © 2020 Bakura. All rights reserved.
//

import Foundation

extension NSAttributedString.Key {
    static let rubyAnnotation: NSAttributedString.Key = kCTRubyAnnotationAttributeName as NSAttributedString.Key
}

protocol DictionaryTermEntryViewDelegate: AnyObject {
    func lookupText(_ dictionaryTermEntryView: DictionaryTermEntryView, text: String)
}

class DictionaryTermEntryView: UIView {
    weak var delegate: DictionaryTermEntryViewDelegate?

    private let result: MergedTermSearchResult
    private var definitionTextViews = [UITextView]()

    init(result: MergedTermSearchResult) {
        self.result = result
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(lookup(_ :)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }

    private func setupView() {
        let annotation = CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, result.reading as CFString, [
            kCTForegroundColorAttributeName: UIColor.label,
            kCTRubyAnnotationSizeFactorAttributeName: 0.3
        ] as CFDictionary)

        let annotatedString = NSAttributedString(string: result.expression, attributes: [
            .foregroundColor: UIColor.label,
            .rubyAnnotation: annotation
        ])

        let title = UILabel()
        title.isUserInteractionEnabled = false
        title.font = .systemFont(ofSize: 40)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.attributedText = annotatedString

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8

        var groupedTerms = [String: [SearchTermResult]]()
        for term in result.terms {
            if groupedTerms[term.dictionary.title] != nil {
                groupedTerms[term.dictionary.title]?.append(term)
            } else {
                groupedTerms[term.dictionary.title] = [term]
            }
        }

        let tags = result.meta.map { createTag(text: "\($0.dictionary.title): \($0.termMeta.mode)", backgroundColor: .lightBlue) }
        let tagsStackView = UIStackView(arrangedSubviews: tags + [UIView()])
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        stackView.addArrangedSubview(tagsStackView)

        for group in groupedTerms {
            let termStackView = UIStackView()
            termStackView.axis = .vertical

            let dictionaryTag = createTag(text: group.key, backgroundColor: .purple)

            let spacingStack = UIStackView(arrangedSubviews: [dictionaryTag, UIView()])
            spacingStack.axis = .horizontal
            termStackView.addArrangedSubview(spacingStack)

            for term in group.value {
                let bodyStackView = UIStackView()
                bodyStackView.alignment = .center
                bodyStackView.axis = .horizontal

                let label = UILabel()
                label.text = "-"
                label.font = .systemFont(ofSize: 20)
                label.widthAnchor.constraint(equalToConstant: 20).isActive = true
                bodyStackView.addArrangedSubview(label)

                let body = UITextView()
                body.isEditable = false
                body.font = .systemFont(ofSize: 20)
                body.translatesAutoresizingMaskIntoConstraints = false
                body.isScrollEnabled = false
                body.text = term.term.glossary
                    .compactMap { item in
                        if case .text(let text) = item {
                            return text
                        }
                        return nil
                    }
                    .map { "• " + $0 } .joined(separator: "\n")

                bodyStackView.addArrangedSubview(body)
                termStackView.addArrangedSubview(bodyStackView)

                definitionTextViews.append(body)
            }
            stackView.addArrangedSubview(termStackView)
        }

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .systemGray

        addSubview(title)
        addSubview(stackView)
        addSubview(separator)

        title.heightAnchor.constraint(equalToConstant: 75).isActive = true
        title.addConstraintsTo(self, sides: [.horizontal, .top])
        stackView.addConstraintsTo(self, sides: [.horizontal, .bottom], spacing: .init(bottom: -10))
        stackView.topAnchor.constraint(equalTo: title.bottomAnchor).isActive = true

        // Separator constraints
        separator.addConstraintsTo(self, sides: [.horizontal, .bottom])
        separator.heightAnchor.constraint(equalToConstant: (1.0 / UIScreen.main.scale)).isActive = true
    }

    private func createTag(text: String, backgroundColor: UIColor) -> UIView {
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.textColor = .white
        tagLabel.font = .systemFont(ofSize: 15, weight: .bold)

        let tag = UIView()
        tag.backgroundColor = backgroundColor
        tag.layer.cornerRadius = 5
        tag.addSubview(tagLabel)

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.addConstraintsTo(tag, spacing: .init(top: 5, left: 5, bottom: -5, right: -5))

        return tag
    }

    @objc func lookup(_ sender: Any?) {
        if let textView = definitionTextViews.first(where: { $0.isFirstResponder }),
           let range = textView.selectedTextRange,
           let text = textView.text(in: range) {
            delegate?.lookupText(self, text: text)
        }
    }
}