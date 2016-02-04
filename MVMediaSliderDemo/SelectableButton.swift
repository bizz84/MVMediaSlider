//
//  SelectableButton.swift
//  MVMediaSlider
//
//  Created by Andrea Bizzotto on 04/02/2016.
//  Copyright © 2016 musevisions. All rights reserved.
//

import UIKit

class SelectableButton: UIButton {


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let defaultImage = self.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate)
        self.setImage(defaultImage, forState: .Normal)
        let selectedImage = self.imageForState(.Selected)?.imageWithRenderingMode(.AlwaysTemplate)
        self.setImage(selectedImage, forState: .Selected)
    }
}
