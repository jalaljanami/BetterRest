//
//  ContentView.swift
//  BetterRest
//
//  Created by Glory's Macmini on 10/27/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    VStack(alignment: .leading, spacing: 0){
                        Text("When do you want to wake up?")
                            .font(.headline)
                        
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text("Desired amount of sleep")
                            .font(.headline)
                        
                        Stepper("\(sleepAmount.inString())", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text("Daily coffee intake")
                            .font(.headline)
                        
                        Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                    }

                    Button("Calculate") {
                        calculateBedTime()
                    }
                    .frame(maxWidth: .infinity, minHeight: 48, idealHeight: 20)
                    .foregroundStyle(.white)
                    .background {
                        Color.blue
                            .clipShape(Capsule())
                    }
                    
                }
                
                
               
                    
            }
            .navigationTitle("Better Rest")
            .toolbar {
//                Button("Done", action: calculateBedTime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            
            
            
        }
        
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
    
    
    private func timeString(from hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let hour = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hour, minutes)
    }
}

#Preview {
    ContentView()
}

extension Double {
    func inString() -> String {
        let totalMinutes = Int(self * 60)
        let hour = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hour, minutes)
    }
}
