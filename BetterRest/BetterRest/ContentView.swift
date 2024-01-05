//
//  ContentView.swift
//  BetterRest
//
//  Created by Funnmedia's Mac on 28/10/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var WakeUp = defaultWakeTime
    @State private var SleepAmount = 7.0
    @State private var CoffeeCount = 2
    
    @State private var AlertTitle = ""
    @State private var AlertMessage = ""
    @State private var AlertShowing = false
    
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 30
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form
            {
                VStack(alignment: .leading, spacing: 1){
                    Text("When Do You Want To Wake Up?")
                        .font(.headline)
                    DatePicker("Please Enter A Time", selection: $WakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        
                }
                
                VStack(alignment: .leading, spacing: 1){
                    Text("Desired Amount Of Sleep").font(.headline)
                    Stepper("\(SleepAmount.formatted()) hours", value: $SleepAmount, in: 4...12 , step: 0.25)
                    
                }
                VStack(alignment: .leading, spacing: 1){
                    Text("Cups of Coffee Per Day").font(.headline)
                    Stepper(CoffeeCount == 1 ? "1 cup" : "\(CoffeeCount) cups", value: $CoffeeCount, in: 0...4)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar{
                Button("Calclulate", action: BedTime)
            }
            .alert(AlertTitle, isPresented: $AlertShowing) {
                Button("OK") {}
            }message: {
                Text(AlertMessage )
            }
        }
    }
    func BedTime() {
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: WakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: SleepAmount, coffee: Double(CoffeeCount))
            
            let sleepTime = WakeUp - prediction.actualSleep
            
            AlertTitle = "Your Bedtime Is...."
            AlertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        }catch{
            AlertTitle = "ERROR"
            AlertMessage = "There Was An Error Calculating Your Bedtime"
        }
        AlertShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
