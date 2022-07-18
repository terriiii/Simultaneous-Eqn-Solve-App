//
//  ViewController.swift
//  Gaucian Elimination
//
//  Created by Tenzin Sim on 12/9/19.
//  Copyright © 2019 Apple.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        inputText.delegate = self
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if inputText.text! != "" {
            //action
            start(inputText.text!)
        }else{
            outLabel.text = "Enter equations above"
        }
        //inputText.text = ""
        return true
    }
    //MARK: Propperties
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var outLabel: UILabel!
    
    func start(_ txtInput: String) {
        //MARK: Declaration
        let TOL = 1e-15 //accuracy tolerance level
        let str = "no solution" //MARK: fail txt
        var letters = [Character]("abcdefghijklmnopqrstuvwxyz")
        var numbers = [Character](".1234567890")
        var variables = [Character]()
        var coefficient = [Character]()
        //MARK: TxtInput
        var input = [Character](txtInput)
        //MARK: fix syntax
        input.append(",")
        input.removeAll{ $0 == " "}
        //MARK: Process input variables
        for i in input{
            if letters.contains(i) {
                variables.append(i)
                letters.remove(at: letters.firstIndex(of: i)!)
            }
        }
        //MARK: variables
        let arraySize = variables.count
        var state = false
        var counter = 0
        var variable = 0
        var side = false //left is false, right is true
        var polarity = 1.0 //1.0 is possitive and -1.0 is negative
        print("number of equations & variables:\(arraySize)")
        //MARK: Matrix Input
        var matrix = [[Double]](repeating: [Double](repeating: 0, count: arraySize+1), count: arraySize) //Initialise array
        //MARK: Txt processing functions
        func updatePolarity(){
            polarity = 1
            if input[0] == "+"{
                polarity = 1
                input.remove(at: 0)
            }else if input[0] == "-"{
                polarity = -1
                input.remove(at: 0)
            }
        }
        //MARK: Form matrix from txt
        while input != []{
            //print(input)
            coefficient = []
            if input[0] == "="{
                side = true
                input.remove(at: 0)
            }
            if input[0] == ","{
                side = false
                input.remove(at: 0)
                counter += 1
            }
            if side == false && input != []{
                coefficient = []
                updatePolarity()
                for i in input{
                    if !numbers.contains(i){
                        break
                    }
                    coefficient.append(i)
                }
                input.removeSubrange(0..<coefficient.count)
                if variables.contains(input[0]){
                    variable = variables.firstIndex(of: input[0])!
                    input.remove(at: 0)
                    if coefficient == []{
                        matrix[counter][variable] += polarity
                    }else{
                    matrix[counter][variable] += polarity * Double(String(coefficient))!
                    }
                }else{
                    matrix[counter][arraySize] -= polarity * Double(String(coefficient))!
                }
            }else if input != []{
                coefficient = []
                updatePolarity()
                for i in input{
                    if !numbers.contains(i){
                        break
                    }
                    coefficient.append(i)
                }
                input.removeSubrange(0..<coefficient.count)
                if variables.contains(input[0]){
                    variable = variables.firstIndex(of: input[0])!
                    input.remove(at: 0)
                    if coefficient == []{
                        matrix[counter][variable] -= polarity
                    }else{
                    matrix[counter][variable] -= polarity * Double(String(coefficient))!
                    }
                }else{
                    matrix[counter][arraySize] += polarity * Double(String(coefficient))!
                }
            }
            //print(coefficient)
            //print(matrix)
        }

        //MARK: output
        var output = [Double](repeating: 0.0, count: arraySize) //Initialise output

        //MARK: functions
        func addRows(_ n:Int,_ m:Int){
            for i in 0...arraySize{
                matrix[n][i]+=matrix[m][i]
            }
        }
        func subRows(_ n:Int,_ m:Int){
            for i in 0...arraySize{
                matrix[n][i]-=matrix[m][i]
            }
        }
        func mulRow(_ n:Int,_ m:Double){ //multiply(row,value)
            for i in 0...arraySize{
                matrix[n][i] = matrix[n][i] * m
            }
        }
        func divRow(_ n:Int,_ m:Double){ //divide(row,value)
            for i in 0...arraySize{
                matrix[n][i] = matrix[n][i] / m
            }
        }
        func equalZero(_ n:Double)->Bool{
            if n < TOL && n > -TOL{
                return true
            }else{
                return false
            }
        }

        //MARK:Gaucian Elimination Start
        for i in 0..<arraySize{
            if equalZero(matrix[i][i]) && arraySize-i != 1{
                state = false
                for k in i+1..<arraySize{
                    if !equalZero(matrix[k][i]) && state == false{
                        addRows(i, k)
                        state = true
                        //print(k)
                    }
                }
            }else if equalZero(matrix[i][i]) && arraySize-i != 1{
                print(str)
            }
            divRow(i, matrix[i][i])
            for j in (i+1)..<arraySize{
                if !equalZero(matrix[j][i]){
                    divRow(j, matrix[j][i])
                    subRows(j, i)
                }
            }
        }
        //print(matrix)
        for i in 1...arraySize{
            output[arraySize-i] = matrix[arraySize-i][arraySize]
            for j in arraySize-i+1..<arraySize{
                output[arraySize-i]-=matrix[arraySize-i][j]*output[j]
            }
        }
        print(output)
        var outTxt = [Character]()
        for i in 0..<arraySize{
            outTxt += [Character]("\(variables[i])=\(output[i])\n")
        }
        outLabel.text = String(outTxt)

    }
}

