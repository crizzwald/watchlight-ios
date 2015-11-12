//
//  InterfaceController.swift
//  WatchLight WatchKit Extension
//
//  Created by Todd Crown on 11/6/15.
//  Copyright © 2015 Todd Crown. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

enum NIBLight : Int {
    case White;
    case Color;
    case Rave;
    case Sensor;
}

class MainController: WKInterfaceController {
    
    @IBOutlet var mainGroup: WKInterfaceGroup!;
    @IBOutlet var mainPicker: WKInterfacePicker!;
    @IBOutlet var sensorText: WKInterfaceLabel!
    
    var pickerItems: [WKPickerItem]! = [];
    var colors: [Double]! = [];
    var currentColor: Double! = 0.0;
    var raveColor: Int = 0;
    var timer: NSTimer!;
    var raveSpeed: Double! = 0.05;
    var isRaving: Bool = false;
    
    @IBAction func mainPickerChanged(value: Int) {
        let hue = colors[value];
        mainGroup.setBackgroundColor(UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1.0));
        currentColor = hue;
    }
    
    func doWhiteMenuActionItem() {
        mainPicker.setAlpha(0.0);
        doMenuManagement(.White);
        animateWithDuration(0.5) { () -> Void in
            self.mainGroup.setBackgroundColor(UIColor.whiteColor());
            self.sensorText.setAlpha(0.0);
        }
        isRaving = false;
    }
    
    func doColorMenuActionItem() {
        mainPicker.setAlpha(0.00001);
        doMenuManagement(.Color);
        animateWithDuration(0.5) { () -> Void in
            self.mainGroup.setBackgroundColor(UIColor(hue: CGFloat(self.currentColor), saturation: 1.0, brightness: 1.0, alpha: 1.0))
            self.sensorText.setAlpha(0.0);
        }
        mainPicker.focus();
        isRaving = false;
    }
    
    func doRaveMenuActionItem() {
        mainPicker.setAlpha(0.0);
        doMenuManagement(.Rave);
        animateWithDuration(0.5) { () -> Void in
            self.sensorText.setAlpha(0.0);
        }
        startRave();
        isRaving = true;
    }
    
    func doSensorMenuActionItem() {
        mainPicker.setAlpha(0.0);
        doMenuManagement(.Sensor);
        animateWithDuration(0.5) { () -> Void in
            self.mainGroup.setBackgroundColor(UIColor(hue: CGFloat(0.4), saturation: 1.0, brightness: 1.0, alpha: 1.0))
            self.sensorText.setAlpha(1);
        }
        isRaving = false;
        
    }
    
    func startRave() {
        timer = NSTimer.scheduledTimerWithTimeInterval(self.raveSpeed, target: self, selector: "doColorRave", userInfo: nil, repeats: true)
        
    }
    
    func doColorRave() {
        if(raveColor >= colors.count) {
            raveColor = 0;
        }
        
        var color = UIColor.blackColor();
        
        if(raveColor % 2 == 0) {
            color = UIColor(hue: CGFloat(self.colors[self.raveColor]), saturation: 1.0, brightness: 1.0, alpha: 1.0);
        }
        
        self.mainGroup.setBackgroundColor(color);
 
        raveColor = raveColor + 1;
    }
    
    func doMenuManagement(light: NIBLight) {
        //kill the rave timer
        if(timer != nil) {
            timer.invalidate();
        }
        
        clearAllMenuItems();
        switch (light) {
        case .White:
            addMenuItemWithItemIcon(.Accept, title: "White", action: "doWhiteMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Color", action: "doColorMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Rave", action: "doRaveMenuActionItem");
            //addMenuItemWithItemIcon(.Add, title: "Sensor", action: "doSensorMenuActionItem");
        case .Color:
            addMenuItemWithItemIcon(.Add, title: "White", action: "doWhiteMenuActionItem");
            addMenuItemWithItemIcon(.Accept, title: "Color", action: "doColorMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Rave", action: "doRaveMenuActionItem");
            //addMenuItemWithItemIcon(.Add, title: "Sensor", action: "doSensorMenuActionItem");
        case .Rave:
            addMenuItemWithItemIcon(.Add, title: "White", action: "doWhiteMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Color", action: "doColorMenuActionItem");
            addMenuItemWithItemIcon(.Accept, title: "Rave", action: "doRaveMenuActionItem");
            //addMenuItemWithItemIcon(.Add, title: "Sensor", action: "doSensorMenuActionItem");
        case .Sensor:
            addMenuItemWithItemIcon(.Add, title: "White", action: "doWhiteMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Color", action: "doColorMenuActionItem");
            addMenuItemWithItemIcon(.Add, title: "Rave", action: "doRaveMenuActionItem");
            //addMenuItemWithItemIcon(.Accept, title: "Sensor", action: "doSensorMenuActionItem");
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        var i = 1.0;
        while(i > 0.0)
        {
            colors.append(i);
            let pickerItem = WKPickerItem();
            pickerItem.title = "\(i)";
            pickerItems.append(pickerItem);
            
            i = i - 0.0025;
        }
        
        //add the menu items
        doMenuManagement(.White);
        
        //set the picker items
        mainPicker.setItems(pickerItems);
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if(isRaving) {
            startRave()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        if(timer != nil) {
            timer.invalidate();
        }
    }
    
}
