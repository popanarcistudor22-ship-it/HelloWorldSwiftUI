import SwiftUI

struct ContentView: View {
    @StateObject private var batteryManager = BatteryManager()
    @State private var showHistory = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Cercul de afișare a procentajului
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20.0)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(batteryManager.batteryLevel / 100.0))
                        .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(batteryColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: batteryManager.batteryLevel)
                    
                    VStack {
                        Text("\(Int(batteryManager.batteryLevel))%")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                        Text(stateDescription)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 200, height: 200)
                .padding()
                
                // Zona de Calibrare
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ghid Calibrare Baterie")
                        .font(.headline)
                    
                    if batteryManager.calibrationInProgress {
                        Text(batteryManager.calibrationStep)
                            .padding()
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        batteryManager.startCalibration()
                    }) {
                        Text(batteryManager.calibrationInProgress ? "Calibrare în curs..." : "Începe un ciclu de calibrare")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(batteryManager.calibrationInProgress ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(batteryManager.calibrationInProgress)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Note despre limitări
                Text("Notă: iOS blochează accesul aplicațiilor la tensiune, temperatură și numărul de cicluri. Pentru cicluri, folosește funcția de citire a fișierelor Analytics (dezvoltare viitoare).")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Status Baterie")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Istoric") {
                        showHistory = true
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                HistoryView()
            }
        }
    }
    
    // Culori dinamice în funcție de nivel
    var batteryColor: Color {
        if batteryManager.batteryLevel > 20 { return .green }
        if batteryManager.batteryLevel > 10 { return .yellow }
        return .red
    }
    
    var stateDescription: String {
        switch batteryManager.batteryState {
        case .charging: return "Se încarcă"
        case .full: return "Încărcat complet"
        case .unplugged: return "Pe baterie"
        case .unknown: return "Necunoscut"
        @unknown default: return "Necunoscut"
        }
    }
}

// Fereastra pentru istoric
struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var history: [String] = UserDefaults.standard.stringArray(forKey: "CalibrationHistory") ?? []
    
    var body: some View {
        NavigationView {
            List(history, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("Istoric Calibrări")
            .toolbar {
                Button("Închide") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
