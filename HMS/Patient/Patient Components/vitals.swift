//
//  vitals.swift
//  HMS
//
//  Created by Protyush Kundu on 23/04/24.
//
import SwiftUI
import HealthKit

// HealthKit Manager to handle health data access
class HealthKitManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    // Request authorization to access health data
    func requestHealthKitAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // Get today's total step count
    func getTodaysSteps(completion: @escaping (Double?, Error?) -> Void) {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, result, error in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    completion(nil, error)
                    return
                }
                let steps = sum.doubleValue(for: HKUnit.count())
                completion(steps, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Get today's average heart rate
    func getTodaysHeartRate(completion: @escaping (Double?, Error?) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
            DispatchQueue.main.async {
                guard let result = result, let average = result.averageQuantity() else {
                    completion(nil, error)
                    return
                }
                let heartRate = average.doubleValue(for: HKUnit.init(from: "count/min"))
                completion(heartRate, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Get today's average SpO2 (blood oxygen saturation)
    func getTodaysSpO2(completion: @escaping (Double?, Error?) -> Void) {
        let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: spo2Type, quantitySamplePredicate: predicate, options: .discreteAverage) { query, result, error in
            DispatchQueue.main.async {
                guard let result = result, let average = result.averageQuantity() else {
                    completion(nil, error)
                    return
                }
                let spo2 = average.doubleValue(for: HKUnit.percent())
                completion(spo2, nil)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Get today's average blood pressure
    func getTodaysBloodPressure(completion: @escaping (Double?, Double?, Error?) -> Void) {
        let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
        let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
        let startDate = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: systolicType, quantitySamplePredicate: predicate, options: .discreteAverage) { (query, result, error) in
            DispatchQueue.main.async {
                guard let result = result, let averageSystolic = result.averageQuantity() else {
                    completion(nil, nil, error)
                    return
                }
                let avgSystolic = averageSystolic.doubleValue(for: HKUnit.millimeterOfMercury())
                
                // Fetch average diastolic
                self.healthStore.execute(HKStatisticsQuery(quantityType: diastolicType, quantitySamplePredicate: predicate, options: .discreteAverage) { (query, result, error) in
                    DispatchQueue.main.async {
                        guard let result = result, let averageDiastolic = result.averageQuantity() else {
                            completion(nil, nil, error)
                            return
                        }
                        let avgDiastolic = averageDiastolic.doubleValue(for: HKUnit.millimeterOfMercury())
                        completion(avgSystolic, avgDiastolic, nil)
                    }
                })
            }
        }
        
        healthStore.execute(query)
    }
}

// SwiftUI View to display health vitals
// SwiftUI View to display health vitals
struct VitalsView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var steps: Double?
    @State private var heartRate: Double?
    @State private var spo2: Double?
    @State private var systolic: Double?
    @State private var diastolic: Double?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                // Steps
                HealthVitalView(title: "Steps", value: steps.map { "\(Int($0))" } ?? "NA", unit: "", gradient: Gradient(colors: [.blueShade.opacity(1),.blueShade.opacity(0.8)]), imageName: "figure.walk")
                
                // Heart Rate
                HealthVitalView(title: "Heart Rate", value: heartRate.map { "\(Int($0))" } ?? "NA", unit: "bpm", gradient: Gradient(colors: [.blueShade.opacity(1),.blueShade.opacity(0.8)]), imageName: "heart")
                
                // SpO2
                HealthVitalView(title: "SpO2", value: spo2.map { "\(Int($0))" } ?? "95", unit: "%", gradient: Gradient(colors: [.blueShade.opacity(1),.blueShade.opacity(0.8)]), imageName: "waveform.path.ecg")
                
                // Blood Pressure
                if let systolic = systolic, let diastolic = diastolic {
                    HealthVitalView(title: "Blood Pressure", value: "\(Int(systolic))/\(Int(diastolic))", unit: "mmHg", gradient: Gradient(colors: [.blueShade.opacity(1),.blueShade.opacity(0.8)]), imageName: "heart.text.square")
                } else {
                    HealthVitalView(title: "Blood Pressure", value: "NA", unit: "mmHg",gradient: Gradient(colors: [.blueShade.opacity(1),.blueShade.opacity(0.8)]), imageName: "heart.text.square")
                }
            }
            .padding()
        }
        .onAppear {
            healthKitManager.requestHealthKitAuthorization { success, error in
                if success {
                    healthKitManager.getTodaysSteps { steps, error in
                        self.steps = steps
                    }
                    
                    healthKitManager.getTodaysHeartRate { heartRate, error in
                        self.heartRate = heartRate
                    }
                    
                    healthKitManager.getTodaysSpO2 { spo2, error in
                        self.spo2 = spo2
                    }
                    
                    healthKitManager.getTodaysBloodPressure { systolic, diastolic, error in
                        self.systolic = systolic
                        self.diastolic = diastolic
                    }
                } else {
                    print("HealthKit authorization denied.")
                }
            }
        }
    }
}



// SwiftUI View to display a health vital in a rectangular box with an image
struct HealthVitalView: View {
    let title: String
    let value: String
    let unit: String
    let gradient: Gradient
    let imageName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 180, height: 150)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing))
                .frame(width: 180, height: 150)
            
            VStack {
                HStack {
                    Image(systemName: imageName)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(title)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.title2)
                }
                HStack {
                    Text(value)
                        .foregroundColor(.white)
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Text(unit)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal)
        }
         
    }
}


struct VitalsView_Previews: PreviewProvider {
    static var previews: some View {
        VitalsView()
    }
}
