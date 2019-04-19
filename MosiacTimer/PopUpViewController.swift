//
//  PopUpViewController.swift
//  MosiacTimer
//
//  Created by Sanjeev on 19/04/19.
//  Copyright © 2019 Sanjeev. All rights reserved.
//

import UIKit
import BottomPopup
import AVFoundation

class PopUpViewController: BottomPopupViewController,UITableViewDelegate, UITableViewDataSource {
    
    var player: AVAudioPlayer?
    @IBOutlet var dismissBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    private var myTableView: UITableView!
    let status = TimeStatusModel()
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    //Array for available tone options
    private let myArray: NSArray = ["Default","Point","Quite","Slow","Unconvinced","Unsure"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creating table view to show tone options
        myTableView = UITableView(frame: CGRect(x: 0, y: titleLabel.frame.origin.y + titleLabel.frame.height, width: view.frame.size.width , height: height ?? 300 - (titleLabel.frame.origin.y + titleLabel.frame.height)))
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        self.view.addSubview(myTableView)
        
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //adding the tone selected in user defaults
        status.audioTone = myArray[indexPath.row] as! String
        
        if indexPath.row != 0
        {
           //playing the tone for user check
            guard let url = Bundle.main.url(forResource: myArray[indexPath.row] as? String, withExtension: "wav") else { return }
        
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            
                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
                /* iOS 10 and earlier require the following line:
                 player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
                guard let player = player else { return }
            
                player.play()
            
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        // setting height for the each cell
        let titleheight = Float(titleLabel.frame.origin.y + titleLabel.frame.height)
        let viewHeight : Float = Float(height ?? 300)
        return (CGFloat((viewHeight - titleheight))/CGFloat(myArray.count))-4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(myArray[indexPath.row])"
        cell.textLabel!.font = UIFont(name:"HelveticaNeue-Light", size: 24.0)
        cell.textLabel!.textColor = UIColor.labelColor
        UITableViewCell.appearance().tintColor = UIColor.labelColor
        
        //adding the tick mark based which tone is selected
        if myArray[indexPath.row] as! String == status.audioTone{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    //dismissing the current view controller
    @IBAction func dismissBtnAction(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //overriding the setting on Botton popup values
    override func getPopupHeight() -> CGFloat {
        return height ?? CGFloat(300)
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

