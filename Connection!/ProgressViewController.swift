//
//  ProgressViewController.swift
//  Connection!
//
//  Created by Avi Cohen on 5/4/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    @IBOutlet weak var snapshotView: UIView!
    @IBOutlet weak var coverVisualEffectView: UIVisualEffectView!
    
    var snapshotViewContent: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        snapshotView.insertSubview(snapshotViewContent, belowSubview: coverVisualEffectView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
