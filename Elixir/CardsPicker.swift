//
//  CardsPicker.swift
//  Elixir
//
//  Created by Youzhi Liu on 2023/3/5.
//

import UIKit

class CardsPicker: UIPickerView {
    var tarots: [Tarot] = ElixirModel.shared.tarots
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension CardsPicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tarots.count
    }
}

extension CardsPicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let width = getCellWidth()
        let height = getCellHeight()
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: height, height: width))
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: width))
        myImageView.image = UIImage(named: "card.png")
        myView.addSubview(myImageView)
        myView.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180))
        return myView
    }
    
    func getCellWidth() -> CGFloat {
        let cellDefaultWidth: Double = 126.0
        let screenDefaultWidth: Double = 393.0
        let factor: Double = cellDefaultWidth / screenDefaultWidth
        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
        var screenWidth: CGFloat = 0.0
        if let w = firstScene as? UIWindowScene {
            print(w.screen.bounds.width)
            screenWidth = w.screen.bounds.width
        }
        return factor * screenWidth
    }
    
    func getCellHeight() -> CGFloat {
        let cellDefaultHeight: Double = 70.0
        let screenDefaultHeight: Double = 852.0
        let factor: Double = cellDefaultHeight / screenDefaultHeight
        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
        var screenHeight: CGFloat = 0.0
        if let w = firstScene as? UIWindowScene {
            print(w.screen.bounds.height)
            screenHeight = w.screen.bounds.height
        }
        return factor * screenHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        //adjust the cell height according to screen size
//        let cellDefaultWidth: Double = 126.0
//        let screenDefaultWidth: Double = 393.0
//        let factor: Double = cellDefaultWidth / screenDefaultWidth
//        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
//        var screenWidth: CGFloat = 0.0
//        if let w = firstScene as? UIWindowScene {
//            print(w.screen.bounds.width)
//            screenWidth = w.screen.bounds.width
//        }
        return getCellWidth()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        //adjust the cell height according to screen size
//        let cellDefaultHeight: Double = 70.0
//        let screenDefaultHeight: Double = 852.0
//        let factor: Double = cellDefaultHeight / screenDefaultHeight
//        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
//        var screenHeight: CGFloat = 0.0
//        if let w = firstScene as? UIWindowScene {
//            print(w.screen.bounds.height)
//            screenHeight = w.screen.bounds.height
//        }
        return getCellHeight()
    }
    
    func rowHeightForCurrentScreen() -> CGFloat {
        let screenDefaultHeight: Double = 852.0
        let cellDefaultHeight: Double = 70.0
        let factor: Double = cellDefaultHeight / screenDefaultHeight

        let firstScene = UIApplication.shared.connectedScenes.first
        var screenHeight: CGFloat = 0.0
        if let w = firstScene as? UIWindowScene {
            screenHeight = w.screen.bounds.height
        }

        return factor * screenHeight
    }
}
