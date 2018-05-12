//
//  ViewController.swift
//  PEP351 Project 1
//
//  Created by Zachary Shakked on 4/3/17.
//  Copyright © 2017 Shakd, LLC. All rights reserved.
//

import UIKit
import Charts
import Darwin

public let AU: Double = 1.496 * pow(10, 11)

public final class ViewController: UIViewController, ChartViewDelegate {

    fileprivate let initialVelocity: Vector = Vector(x: 0, y: 32700)
    
    fileprivate let G: Double = 6.67 * pow(10, -11)
    fileprivate let M: Double = 1.989 * pow(10, 30)
    
    @IBOutlet weak var scatterChartView: ScatterChartView!
    @IBOutlet weak var numberOfIterationsButton: UIButton!
    @IBOutlet weak var timestepButton: UIButton!
    @IBOutlet weak var initialPositionButton: UIButton!
    @IBOutlet weak var initialVelocityButton: UIButton!
    
    
    
    @IBOutlet weak var simulatedPericenterButton: UIButton!
    @IBOutlet weak var simulatedSemimajorAxisButton: UIButton!
    @IBOutlet weak var simulatedApocenterButton: UIButton!
    @IBOutlet weak var simulatedEccentricity: UIButton!
    
    @IBOutlet weak var calculatedPericenterButton: UIButton!
    @IBOutlet weak var calculatedSemimajorAxisButton: UIButton!
    @IBOutlet weak var calculatedApocenterButton: UIButton!
    
    @IBOutlet weak var calculatedEccentricityButton: UIButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        scatterChartView.delegate = self
        scatterChartView.highlightPerDragEnabled = true
        runSimulations()
        
        let f = NumberFormatter()
        f.numberStyle = .scientific
        
        let initialPositionString = "x: \(f.string(from: NSNumber(value: initialPosition.x)) ?? "")m, y: \(f.string(from: NSNumber(value: initialPosition.y)) ?? "")m"
        initialPositionButton.setTitle(initialPositionString, for: .normal)
        
        let initialVelocityString = "x: \(f.string(from: NSNumber(value: initialVelocity.x)) ?? "")m/s, y: \(f.string(from: NSNumber(value: initialVelocity.y)) ?? "")m/s"
        initialVelocityButton.setTitle(initialVelocityString, for: .normal)
    }
    
    fileprivate func runSimulations() {
        numberOfIterationsButton.setTitle("\(numberOfIterations)", for: .normal)
        timestepButton.setTitle(String(format: "%0.0f SECONDS", timestep), for: .normal)
        
        let eulerDataSet = getEulerSimulationDataSet()
        let rk2DataSet = getRK2SimulationDataSet()
        let rk4DataSet = getRK4SimulationDataSet()
//        let data = ScatterChartData(dataSets: [eulerDataSet])//, rk2DataSet, rk4DataSet])
//        let data = ScatterChartData(dataSets: [rk2DataSet])//, rk2DataSet, rk4DataSet])
        let data = ScatterChartData(dataSets: [rk4DataSet])//, rk2DataSet, rk4DataSet])
        scatterChartView.data = data
        scatterChartView.rightAxis.enabled = false
        scatterChartView.leftAxis.valueFormatter = ValueFormatter()
        scatterChartView.xAxis.valueFormatter = ValueFormatter()
        
        let horiztonalAxisWidth = abs(scatterChartView.chartXMax - scatterChartView.chartXMin) / AU
        let verticalAxisHeight = abs(scatterChartView.chartYMax - scatterChartView.chartYMin) / AU
        print("SemimajorAxis: \(horiztonalAxisWidth > verticalAxisHeight ? horiztonalAxisWidth : verticalAxisHeight) AU")
        
        var semimajorAxis: Double
        var semiminorAxis: Double
        var apocenter: Double
        var pericenter: Double
        var eccentricity: Double
        
        if (horiztonalAxisWidth > verticalAxisHeight) {
            semimajorAxis = horiztonalAxisWidth / 2.0
            semiminorAxis = verticalAxisHeight / 2.0
        } else {
            semimajorAxis = verticalAxisHeight / 2.0
            semiminorAxis = horiztonalAxisWidth / 2.0
        }
        eccentricity = (semimajorAxis - semiminorAxis) / (semimajorAxis + semiminorAxis)
        
        //apocenter is farthest
        apocenter = semimajorAxis * (1 + eccentricity)
        //pericenter is the closest
        pericenter = semimajorAxis * (1 - eccentricity)
        
        
        simulatedSemimajorAxisButton.setTitle("\(String(format: "%.4f", semimajorAxis)) AU", for: .normal)
        simulatedApocenterButton.setTitle("\(String(format: "%.4f", apocenter)) AU", for: .normal)
        simulatedPericenterButton.setTitle("\(String(format: "%.4f", pericenter)) AU", for: .normal)
        simulatedEccentricity.setTitle("\(String(format: "%.4f", eccentricity))", for: .normal)
        
        let orbitalEnergy = (pow(initialVelocity.magnitude, 2) / 2.0) - (G * M / initialPosition.magnitude)
        let calculatedSemimajorAxis = (-1 * G * M) / (2 * orbitalEnergy)
        let H = initialPosition.x * initialVelocity.magnitude
        let calculatedEccentricity = sqrt(1 + ((2 * orbitalEnergy * pow(H, 2)) / (pow((G * M), 2))))
        let calculatedApocenter = calculatedSemimajorAxis * (1 + calculatedEccentricity)
        let calculatedPericenter = calculatedSemimajorAxis * (1 - calculatedEccentricity)
        
        calculatedSemimajorAxisButton.setTitle("\(String(format: "%.4f", calculatedSemimajorAxis / AU)) AU", for: .normal)
        calculatedApocenterButton.setTitle("\(String(format: "%.4f", calculatedApocenter / AU)) AU", for: .normal)
        calculatedPericenterButton.setTitle("\(String(format: "%.4f", calculatedPericenter / AU)) AU", for: .normal)
        calculatedEccentricityButton.setTitle("\(String(format: "%.4f", calculatedEccentricity))", for: .normal)
    }
    
    @IBAction func numberOfIterationsButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Number of Iterations", message: "Enter the number of iterations you want the simulation to run.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okay = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alertController.textFields?[0].text, let value = Int(text) {
                self.numberOfIterations = value
            }
        }
        okay.isEnabled = false
        alertController.addTextField(configurationHandler: { (textfield) in
            textfield.keyboardType = .numberPad
            textfield.becomeFirstResponder()
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textfield, queue: OperationQueue.main) { (_) in
                let currentText = alertController.textFields?[0].text ?? ""
                okay.isEnabled = currentText != ""
            }
        })
        alertController.addAction(okay)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func timestepButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Timestep", message: "Enter a value for timestep in seconds.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okay = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alertController.textFields?[0].text, let value = Double(text) {
                self.timestep = value
            }
        }
        okay.isEnabled = false
        alertController.addTextField(configurationHandler: { (textfield) in
            textfield.keyboardType = .numberPad
            textfield.becomeFirstResponder()
            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textfield, queue: OperationQueue.main) { (_) in
                let currentText = alertController.textFields?[0].text ?? ""
                okay.isEnabled = currentText != ""
            }
        })
        alertController.addAction(okay)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    public var timestep: Double = 1000 {
        didSet {
            runSimulations()
        }
    }
    public var numberOfIterations: Int = 50000 {
        didSet {
            runSimulations()
        }
    }
    
    
    
    fileprivate let initialPosition: Vector = Vector(x: AU, y: 0)
    
    
    func getEulerSimulationDataSet() -> ScatterChartDataSet {
        var r: Vector = initialPosition
        var v: Vector = initialVelocity
        var a: Vector = Vector(x: (-1 * G * M / (pow(r.magnitude, 2))), y: 0)
        
        var entries: [ChartDataEntry] = []
        for _ in 0..<numberOfIterations {
            a = (-1 * (G * M / (r.magnitude * r.magnitude))) * r.unitVector
            v = (timestep * a) + v
            r = r + (timestep * v) + ((pow(timestep, 2)) / 2) * a
            
            let entry = ChartDataEntry(x: r.x, y: r.y)
            entries.append(entry)
        }
        
        
        let dataSet = ScatterChartDataSet(values: entries, label: "Euler")
        dataSet.scatterShapeSize = 5.0
        dataSet.colors = [UIColor.red]
        return dataSet
        
    }
    
    fileprivate func getRK2SimulationDataSet() -> ScatterChartDataSet {
        var r: Vector = initialPosition
        var v: Vector = initialVelocity
        
        var entries: [ChartDataEntry] = []
        for _ in 0..<numberOfIterations {
            
            let k1x = timestep * v.x
            let k1y = timestep * v.y
            let k1vx = ((-1 * G * M) / (pow(r.x, 2) + pow(r.y, 2)) * (r.x / (sqrt(pow(r.x,2) + pow(r.y,2))))) * timestep
            let k1vy = ((-1 * G * M) / (pow(r.x, 2) + pow(r.y, 2)) * (r.y / (sqrt(pow(r.x,2) + pow(r.y,2))))) * timestep
            
            let k2x = (v.x + k1vx) * timestep
            let k2y = (v.y + k1vy) * timestep
            let k2vx = ((-1 * G * M) / (pow(r.x + k1x, 2) + pow(r.y + k1y, 2)) * ((r.x + k1x) / (sqrt(pow(r.x + k1x,2) + pow(r.y + k1y,2))))) * timestep
            let k2vy = ((-1 * G * M) / (pow(r.x + k1x, 2) + pow(r.y + k1y, 2)) * ((r.y + k1y) / (sqrt(pow(r.x + k1x,2) + pow(r.y + k1y,2))))) * timestep
            
            r = Vector(x: r.x + 0.5 * (k1x + k2x), y: r.y + 0.5 * (k1y + k2y))
            v = Vector(x: v.x + 0.5 * (k1vx + k2vx), y: v.y + 0.5 * (k1vy + k2vy))
            
            let entry = ChartDataEntry(x: r.x, y: r.y)
            entries.append(entry)
        }
        
        
        let dataSet = ScatterChartDataSet(values: entries, label: "RK2")
        dataSet.scatterShapeSize = 5.0
        dataSet.colors = [UIColor.blue]
        return dataSet
    }
    
    fileprivate func getRK4SimulationDataSet() -> ScatterChartDataSet {
        var r: Vector = initialPosition
        var v: Vector = initialVelocity
        
        var entries: [ChartDataEntry] = []
        for _ in 0..<numberOfIterations {
            
            let k1x = timestep * v.x
            let k1y = timestep * v.y
            let k1vx = ((-1 * G * M) / (pow(r.x, 2) + pow(r.y, 2)) * (r.x / (sqrt(pow(r.x,2) + pow(r.y,2))))) * timestep
            let k1vy = ((-1 * G * M) / (pow(r.x, 2) + pow(r.y, 2)) * (r.y / (sqrt(pow(r.x,2) + pow(r.y,2))))) * timestep
            
            let k2x = (v.x + k1vx) * timestep
            let k2y = (v.y + k1vy) * timestep
            let k2vx = ((-1 * G * M) / (pow(r.x + k1x, 2) + pow(r.y + k1y, 2)) * ((r.x + k1x) / (sqrt(pow(r.x + k1x,2) + pow(r.y + k1y,2))))) * timestep
            let k2vy = ((-1 * G * M) / (pow(r.x + k1x, 2) + pow(r.y + k1y, 2)) * ((r.y + k1y) / (sqrt(pow(r.x + k1x,2) + pow(r.y + k1y,2))))) * timestep
            
            let k3x = (v.x + k2vx / 2.0) * timestep
            let k3y = (v.y + k2vy / 2.0) * timestep
            let k3vx = ((-1 * G * M) / (pow(r.x + k2x / 2.0, 2) + pow(r.y + k2y / 2.0, 2)) * ((r.x + k2x / 2.0) / (sqrt(pow(r.x + k2x / 2.0, 2) + pow(r.y + k2y / 2.0, 2))))) * timestep
            let k3vy = ((-1 * G * M) / (pow(r.x + k2x / 2.0, 2) + pow(r.y + k2y / 2.0, 2)) * ((r.y + k2y / 2.0) / (sqrt(pow(r.x + k2x / 2.0, 2) + pow(r.y + k2y / 2.0, 2))))) * timestep
            
            let k4x = (v.x + k3vx) * timestep
            let k4y = (v.y + k3vy) * timestep
            let k4vx = ((-1 * G * M) / (pow(r.x + k3x, 2) + pow(r.y + k3y, 2)) * ((r.x + k3x) / (sqrt(pow(r.x + k3x,2) + pow(r.y + k3y,2))))) * timestep
            let k4vy = ((-1 * G * M) / (pow(r.x + k3x, 2) + pow(r.y + k3y, 2)) * ((r.y + k3y) / (sqrt(pow(r.x + k3x,2) + pow(r.y + k3y,2))))) * timestep
            
            r = Vector(x: r.x + (1.0 / 6.0) * (k1x + (2 * k2x) + (2 * k3x) + k4x), y: r.y + (1.0 / 6.0) * (k1y + (2 * k2y) + (2 * k3y) + k4y))
            v = Vector(x: v.x + (1.0 / 6.0) * (k1vx + (2 * k2vx) + (2 * k3vx) + k4vx), y: v.y + (1.0 / 6.0) * (k1vy + (2 * k2vy) + (2 * k3vy) + k4vy))
            
            let entry = ChartDataEntry(x: r.x, y: r.y)
            entries.append(entry)
        }
        
        
        let dataSet = ScatterChartDataSet(values: entries, label: "RK4")
        dataSet.scatterShapeSize = 5.0
        dataSet.colors = [UIColor.green]
        return dataSet
    }
    
    //MARK:- ChatViewDelegate
    
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
}

