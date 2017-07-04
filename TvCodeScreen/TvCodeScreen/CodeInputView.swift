//
//  CodeInputView.swift
//  TvCodeScreen
//
//  Created by Bruno Macabeus Aquino on 28/06/17.
//  Copyright © 2017 Bruno Macabeus Aquino. All rights reserved.
//

import UIKit

public protocol CodeInputViewDelegate {
    /**
     Delegate called when the user fill the code
     - parameter codeInputView: The CodeInputView that called this function
     - parameter codeText: Text typed by user
     */
    func finishTyping(_ codeInputView: CodeInputView, codeText: String)
}

public class CodeInputView: UIView {
    
    @IBInspectable public var codeLength: Int = 6
    @IBInspectable public var labelBackgroundColor: UIColor = .lightGray
    @IBInspectable public var labelFontColor: UIColor = .black
    @IBInspectable public var buttonBackgroundFocusedColor: UIColor = .white
    @IBInspectable public var buttonFontColor: UIColor = .gray
    private var codeLabels: [UILabel] = []
    private var currentCharacterSlotToType = 0
    public var delegate: CodeInputViewDelegate?
    public var codeText: String {
        return codeLabels.map({  $0.text! }).joined(separator: "")
    }
    
    public override func awakeFromNib() {
        // background
        backgroundColor = .clear
        
        // add components for view
        codeLabels = createCodeLabels(count: codeLength, labelWidth: 110, labelHeight: 120)
        addCodeLabelsToView(codeLabels)
        
        let inputButtons = createNumericInputButtons()
        addInputButtonsToView(inputButtons)
    }
    
    private func addCodeLabelsToView(_ newCodeLabels: [UILabel]) {
        let stackViewLabels = createStackViewForHorizontalElements(forViews: newCodeLabels, spacingBetweenElements: 30)
        
        addSubview(stackViewLabels)
        
        stackViewLabels.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stackViewLabels.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackViewLabels.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackViewLabels.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addInputButtonsToView(_ newInputButtons: [InputButton]) {
        let stackViewInputButtons = createStackViewForHorizontalElements(forViews: newInputButtons, spacingBetweenElements: 20)
        
        addSubview(stackViewInputButtons)
        
        stackViewInputButtons.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stackViewInputButtons.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackViewInputButtons.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackViewInputButtons.translatesAutoresizingMaskIntoConstraints = false
    }
    
    ////
    // Placeholder labels
    private func createCodeLabels(count: Int, labelWidth: Int, labelHeight: Int) -> [UILabel] {
        var labels: [UILabel] = []
        
        for _ in 0..<count {
            labels.append(createCodeLabel(width: labelWidth, height: labelHeight))
        }
        
        return labels
    }
    
    private func createCodeLabel(width: Int, height: Int) -> UILabel {
        let label = UILabel()
        label.frame.size = CGSize(width: width, height: height)
        label.font = label.font.withSize(CGFloat(height)) // todo: use dynamic type to set the size of label
        label.backgroundColor = labelBackgroundColor
        label.textColor = labelFontColor
        label.textAlignment = .center
        
        label.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        label.text = " "
        
        return label
    }
    
    ////
    // Input buttons
    private func createNumericInputButtons() -> [InputButton] {
        enum NumericInputButtonType {
            case pos(Int)
            
            var specification: (title: Character, target: Any, action: Selector)? {
                switch self {
                case .pos(let number) where number < 10:
                    return (
                        title: String(number).characters.first ?? " ",
                        target: self,
                        action: #selector(buttonTypeCharacter(_:))
                    )
                case .pos(10):
                    return (
                        title: "<",
                        target: self,
                        action: #selector(buttonRemoveCharacter(_:))
                    )
                default:
                    return nil
                }
            }
        }
        
        var buttons: [InputButton] = []
        
        for i in 0...10 {
            guard let currentSpecification = NumericInputButtonType.pos(i).specification else {
                continue
            }
            
            let button = InputButton(
                associatedCharacter: currentSpecification.title,
                target: currentSpecification.target,
                action: currentSpecification.action,
                labelColor: buttonFontColor,
                backgroundFocusedColor: buttonBackgroundFocusedColor
            )
            
            buttons.append(button)
        }
        
        return buttons
    }
    
    ////
    // Stackview
    private func createStackViewForHorizontalElements(forViews views: [UIView], spacingBetweenElements: Float) -> UIStackView {
        let stackLabels = UIStackView(arrangedSubviews: views)
        stackLabels.axis = .horizontal
        stackLabels.distribution = .equalSpacing
        stackLabels.alignment = .center
        stackLabels.spacing = CGFloat(spacingBetweenElements)
        
        return stackLabels
    }
    
    ////
    // Input button actions
    func buttonTypeCharacter(_ sender: InputButton) {
        addCharacterToTheCode(character: sender.associatedCharacter)
    }
    
    func buttonRemoveCharacter(_ sender: InputButton) {
        removeCharacterToTheCode()
    }
    
    /**
     Add a character to the code
     */
    private func addCharacterToTheCode(character: Character) {
        if currentCharacterSlotToType == codeLength {
            return
        }
        
        codeLabels[currentCharacterSlotToType].text = String(character)
        currentCharacterSlotToType += 1
        
        if currentCharacterSlotToType == codeLength {
            delegate?.finishTyping(self, codeText: codeText)
        }
    }
    
    /**
     Remove the last character in the code
     */
    private func removeCharacterToTheCode() {
        if currentCharacterSlotToType == 0 {
            return
        }
        
        codeLabels[currentCharacterSlotToType - 1].text = " "
        currentCharacterSlotToType -= 1
    }
}
