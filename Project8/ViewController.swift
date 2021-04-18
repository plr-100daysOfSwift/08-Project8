//
//  ViewController.swift
//  Project8
//
//  Created by Paul Richardson on 19/04/2021.
//

import UIKit

class ViewController: UIViewController {

	var cluesLabel: UILabel!
	var answersLabel: UILabel!
	var currentAnswer: UITextField!
	var scoreLabel: UILabel!
	var letterButtons = [UIButton]()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}

	override func loadView() {
		view = UIView()
		view.backgroundColor = .white
	}

}

