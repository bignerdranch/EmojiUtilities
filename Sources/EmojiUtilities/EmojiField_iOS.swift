//
//  EmojiField.swift
//  EmojiUtilities (iOS)
//

#if os(iOS)
import UIKit

/// An object that displays an text area in your UI for selecting a single emoji.
///
/// Use an emoji field to gather input from the user using an the on-screen keyboard.
/// The emoji field uses the target-action mechanism to report changes made during the course of editing.
/// Store a reference to the text field in one of your controller objects.
public class EmojiField: UIControl {
    let textField = UITextField()

    public init() {
        super.init(frame: .zero)
        setUpSubviews()
    }

    public var text: String {
        get {
            textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    public override var intrinsicContentSize: CGSize {
        textField.intrinsicContentSize
    }

    // MARK: - UIResponder

    public override var textInputContextIdentifier: String? {
        "emoji"
    }

    public override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
             if mode.primaryLanguage == "emoji" {
                 return mode
             }
         }
         return nil
    }
}

extension EmojiField: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        string == "" || string.isEmoji && range.location == 0 && range.length == textField.text?.utf16.count
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
}

extension EmojiField {
    func setUpSubviews() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.font = .systemFont(ofSize: 150)
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @objc func textFieldDidChangeText(_ textField: UITextField) {
        sendActions(for: .valueChanged)
    }
}
#endif
