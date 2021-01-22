//
//  EmojiField.swift
//  EmojiUtilities (macOS)
//

#if os(macOS)
import AppKit

/// An object that displays an text area in your UI for selecting a single emoji.
///
/// Use an emoji field to gather input from the user using an the on-screen keyboard.
/// The emoji field uses the target-action mechanism to report changes made during the course of editing.
/// Store a reference to the text field in one of your controller objects.
public class EmojiField: NSControl {
    let disclosureButton = NSButton()
    var hasPlaceholderValue = true

    public init() {
        super.init(frame: .zero)
        setUpSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var stringValue: String {
        get {
            hasPlaceholderValue ? "" : super.stringValue
        }
        set {
            setStringValue(newValue, allowPlaceholder: true, notify: false)
        }
    }

    public override var attributedStringValue: NSAttributedString {
        get {
            NSAttributedString(string: stringValue)
        }
        set {
            stringValue = newValue.string
        }
    }

    public var pointSize: CGFloat? {
        get {
            font?.pointSize
        }
        set {
            super.font = .systemFont(ofSize: newValue ?? 36)
        }
    }

    public override var font: NSFont? {
        get { super.font }
        set {}
    }

    // MARK: - NSView

    public override func draw(_ dirtyRect: NSRect) {
        guard !hasPlaceholderValue else { return }
        super.attributedStringValue.draw(in: bounds)
    }

    public override var intrinsicContentSize: CGSize {
        super.attributedStringValue.size()
    }

    public override var alignmentRectInsets: NSEdgeInsets {
        var alignmentRectInsets = disclosureButton.alignmentRectInsets
        alignmentRectInsets.top = 0
        if userInterfaceLayoutDirection == .leftToRight {
            alignmentRectInsets.left = 0
        } else {
            alignmentRectInsets.right = 0
        }
        return alignmentRectInsets
    }

    public override var focusRingMaskBounds: NSRect {
        bounds
    }

    public override func drawFocusRingMask() {
        super.attributedStringValue.draw(in: bounds)
    }

    // MARK: - NSResponder

    public override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            showsDisclosureButton = true
            return true
        } else {
            return false
        }
    }

    public override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            showsDisclosureButton = false
            return true
        } else {
            return false
        }
    }

    public override func mouseEntered(with event: NSEvent) {
        guard acceptsFirstResponder else { return }
        showsDisclosureButton = true
    }

    public override func mouseExited(with event: NSEvent) {
        showsDisclosureButton = window?.firstResponder == self
    }

    public override func mouseDown(with event: NSEvent) {
        guard acceptsFirstResponder else { return }
        window?.makeFirstResponder(self)
    }

    public override func mouseUp(with event: NSEvent) {
        guard event.clickCount == 2, window?.firstResponder == self else { return }
        NSApp.orderFrontCharacterPalette(self)
    }

    public override func deleteBackward(_ sender: Any?) {
        setStringValue("", allowPlaceholder: true, notify: true)
    }

    public override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == " " {
            NSApp.orderFrontCharacterPalette(self)
        } else {
            inputContext?.handleEvent(event)
        }
    }
}

extension EmojiField: NSTextInputClient {
    public func insertText(_ text: Any, replacementRange: NSRange) {
        let string = text as? String ?? ""
        setStringValue(string, allowPlaceholder: false, notify: true)
    }

    public func setMarkedText(_ string: Any, selectedRange: NSRange, replacementRange: NSRange) {}

    public func unmarkText() {}

    public func selectedRange() -> NSRange {
        NSRange(location: 0, length: stringValue.utf16.count)
    }

    public func markedRange() -> NSRange {
        NSRange(location: NSNotFound, length: 0)
    }

    public func hasMarkedText() -> Bool {
        false
    }

    public func attributedSubstring(forProposedRange range: NSRange, actualRange: NSRangePointer?) -> NSAttributedString? {
        nil
    }

    public func validAttributesForMarkedText() -> [NSAttributedString.Key] {
        []
    }

    public func firstRect(forCharacterRange range: NSRange, actualRange: NSRangePointer?) -> NSRect {
        var rect = NSRect(x: bounds.midX, y: bounds.minY, width: 1, height: bounds.height)
        rect = convert(rect, to: nil)
        if let window = window {
            rect = window.convertToScreen(rect)
        }
        return rect
    }

    public func characterIndex(for point: NSPoint) -> Int {
        0
    }
}

extension EmojiField: NSAccessibilityButton {
    public override func accessibilityLabel() -> String? {
        stringValue
    }

    public override func accessibilityPerformPress() -> Bool {
        becomeActive()
    }
}

extension EmojiField {
    func setUpSubviews() {
        super.stringValue = "🙃"
        super.font = .systemFont(ofSize: 150)
        super.alignment = .center

        disclosureButton.translatesAutoresizingMaskIntoConstraints = false
        disclosureButton.setButtonType(.momentaryPushIn)
        disclosureButton.bezelStyle = .roundedDisclosure
        disclosureButton.imagePosition = .imageOnly
        disclosureButton.target = self
        disclosureButton.action = #selector(disclosureButtonAction)
        disclosureButton.isHidden = true
        addSubview(disclosureButton)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor),
            disclosureButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            disclosureButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .inVisibleRect, .activeAlways], owner: self, userInfo: nil))
    }

    var showsDisclosureButton: Bool {
        get {
            !disclosureButton.isHidden
        }
        set {
            NSAnimationContext.runAnimationGroup { (context) in
                disclosureButton.animator().isHidden = !newValue
            }
        }
    }

    func setStringValue(_ newValue: String, allowPlaceholder: Bool, notify: Bool) {
        if let emoji = Emoji(rawValue: newValue) {
            super.stringValue = emoji.rawValue
            hasPlaceholderValue = false
        } else if allowPlaceholder {
            super.stringValue = "🙃"
            hasPlaceholderValue = true
        } else {
            return
        }

        noteFocusRingMaskChanged()

        if notify {
            sendAction(action, to: target)
        }
    }

    @discardableResult
    func becomeActive() -> Bool {
        guard acceptsFirstResponder else { return false }
        window?.makeFirstResponder(self)
        NSApp.orderFrontCharacterPalette(self)
        return true
    }

    @objc func disclosureButtonAction(_ sender: NSButton) {
        becomeActive()
    }
}
#endif
