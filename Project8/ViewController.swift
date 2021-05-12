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
	var activatedButtons = [UIButton]()
	var solutions = [String]()

	var score = 0 {
		didSet {
			scoreLabel.text = "Score: \(score)"
		}
	}
	var solutionsFound = 0

	var level = 1

	override func loadView() {
		view = UIView()
		view.backgroundColor = .white

		scoreLabel = UILabel()
		scoreLabel.translatesAutoresizingMaskIntoConstraints = false
		scoreLabel.textAlignment = .right
		scoreLabel.text = "Score: 0"
		view.addSubview(scoreLabel)

		cluesLabel = UILabel()
		cluesLabel.translatesAutoresizingMaskIntoConstraints = false
		cluesLabel.font = UIFont.systemFont(ofSize: 24)
		cluesLabel.text = "CLUES"
		cluesLabel.numberOfLines = 0
		cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
		view.addSubview(cluesLabel)

		answersLabel = UILabel()
		answersLabel.translatesAutoresizingMaskIntoConstraints = false
		answersLabel.font = UIFont.systemFont(ofSize: 24)
		answersLabel.text = "ANSWERS"
		answersLabel.numberOfLines = 0
		answersLabel.textAlignment = .right
		answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
		view.addSubview(answersLabel)

		currentAnswer = UITextField()
		currentAnswer.translatesAutoresizingMaskIntoConstraints = false
		currentAnswer.placeholder = "Tap letters to guess"
		currentAnswer.textAlignment = .center
		currentAnswer.font = UIFont.systemFont(ofSize: 44)
		currentAnswer.isUserInteractionEnabled = false
		view.addSubview(currentAnswer)

		let submit = UIButton(type: .system)
		submit.translatesAutoresizingMaskIntoConstraints = false
		submit.setTitle("SUBMIT", for: .normal)
		submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
		view.addSubview(submit)

		let clear = UIButton(type: .system)
		clear.translatesAutoresizingMaskIntoConstraints = false
		clear.setTitle("CLEAR", for: .normal)
		clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
		view.addSubview(clear)

		let buttonsView = UIView()
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.layer.borderWidth = 0.5
		buttonsView.layer.borderColor = CGColor(gray: 0.5, alpha: 1)
		view.addSubview(buttonsView)

		NSLayoutConstraint.activate([
			scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

			cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
			cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
			cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),

			answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
			answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
			answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
			answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),

			currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
			currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),

			submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
			submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
			submit.heightAnchor.constraint(equalToConstant: 44),

			clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
			clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
			clear.heightAnchor.constraint(equalToConstant: 44),

			buttonsView.widthAnchor.constraint(equalToConstant: 750),
			buttonsView.heightAnchor.constraint(equalToConstant: 320),
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
			buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
		])

		let width = 150
		let height = 80

		for row in 0..<4 {
			for col in 0..<5 {
				let letterButton = UIButton(type: .system)
				letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
				letterButton.setTitle("WWW", for: .normal)
				let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
				letterButton.frame = frame
				letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
				buttonsView.addSubview(letterButton)
				letterButtons.append(letterButton)
			}
		}

	}

	override func viewDidLoad() {
		super.viewDidLoad()
		loadLevel()
		// TODO: Display title and level
	}

	@objc func letterTapped(_ sender: UIButton) {
		guard let buttonTitle = sender.titleLabel?.text else { return }
		let options: UIView.AnimationOptions = currentAnswer.text == "" ? [.transitionCrossDissolve] : [.transitionFlipFromRight]
		UIView.transition(with: currentAnswer, duration: 0.5, options: options) {
			self.currentAnswer.text = self.currentAnswer.text?.appending(buttonTitle)
		}

		activatedButtons.append(sender)

		UIView.animate(withDuration: 0.5, delay: 0, options: []) {
			sender.alpha = 0
		} completion: { finished in
			sender.isHidden = true
			sender.alpha = 1
		}

	}

	@objc func clearTapped(_ sender: UIButton) {
		guard let answerText = currentAnswer.text, !answerText.isEmpty else { return }

		resetSolution()
	}

	@objc func submitTapped(_ sender: UIButton) {
		guard let answerText = currentAnswer.text, !answerText.isEmpty else { return }

		if let solutionPosition = solutions.firstIndex(of: answerText) {
			activatedButtons.removeAll()

			var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
			splitAnswers?[solutionPosition] = answerText
			answersLabel.text = splitAnswers?.joined(separator: "\n")

			currentAnswer.text = ""
			score += 1
			solutionsFound += 1

			if solutionsFound == 7 {
				if score == 7 {
					// TODO: Handle state where no more levels are available
					let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
					ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
					present(ac, animated: true)
				} else {
					let ac = UIAlertController(title: "You scored \(score)!", message: "There's room for improvement though", preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { action in
						// TODO: Duplicate code
						self.score = 0
						self.solutionsFound = 0
						self.activatedButtons.removeAll()
						for button in self.letterButtons {
							button.isHidden = false
						}
						self.loadLevel()
					}))
					ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
					present(ac, animated: true)
				}
			}
		} else {
			score -= 1
			let ac = UIAlertController(title: "That's not correct!", message: "\(answerText) is not a solution.", preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "OK", style: .default) { action in
				self.resetSolution()
		})
			present(ac, animated: true)
		}
	}

	fileprivate func resetSolution() {
		UIView.transition(with: currentAnswer, duration: 0.8, options: [.transitionFlipFromTop]) {
			self.currentAnswer.text = ""
		}

		for button in activatedButtons {
			button.isHidden = false
		}

		activatedButtons.removeAll()
	}

	func loadLevel() {
		var clueString = ""
		var solutionString = ""
		var letterBits = [String]()

		if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
			if let levelContents = try? String(contentsOf: levelFileURL) {
				var lines = levelContents.components(separatedBy: "\n")
				lines.shuffle()

				for (index, line) in lines.enumerated() {
					let parts = line.components(separatedBy: ": ")
					let answer = parts[0]
					let clue = parts[1]

					clueString += "\(index + 1). \(clue)\n"

					let solutionWord = answer.replacingOccurrences(of: "|", with: "")
					solutionString += "\(solutionWord.count) letters\n"
					solutions.append(solutionWord)

					let bits = answer.components(separatedBy: "|")
					letterBits += bits
				}
			}
		}

		cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
		answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)

		letterBits.shuffle()

		if letterBits.count == letterButtons.count {
			for i in 0 ..< letterButtons.count {
				letterButtons[i].setTitle(letterBits[i], for: .normal)
			}
		}

	}

	func levelUp(action: UIAlertAction) {
		level += 1
		solutions.removeAll(keepingCapacity: true)
		score = 0
		solutionsFound = 0

		loadLevel()

		for button in letterButtons {
			button.isHidden = false
		}
	}

}

