import Foundation
import UIKit
import Combine

class BatteryManager: ObservableObject {
    @Published var batteryLevel: Float = 0.0
    @Published var batteryState: UIDevice.BatteryState = .unknown
    @Published var calibrationInProgress: Bool = false
    @Published var calibrationStep: String = "Inactiv"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Activăm monitorizarea bateriei
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryInfo()
        
        // Ascultăm schimbările de stare și nivel
        NotificationCenter.default.publisher(for: UIDevice.batteryLevelDidChangeNotification)
            .sink { [weak self] _ in self?.updateBatteryInfo() }
            .store(in: &cancellables)
            
        NotificationCenter.default.publisher(for: UIDevice.batteryStateDidChangeNotification)
            .sink { [weak self] _ in self?.updateBatteryInfo() }
            .store(in: &cancellables)
    }
    
    func updateBatteryInfo() {
        self.batteryLevel = UIDevice.current.batteryLevel * 100
        self.batteryState = UIDevice.current.batteryState
        
        if calibrationInProgress {
            checkCalibrationProgress()
        }
    }
    
    func startCalibration() {
        calibrationInProgress = true
        checkCalibrationProgress()
    }
    
    func checkCalibrationProgress() {
        if batteryState != .unplugged && batteryLevel > 5 {
            calibrationStep = "Pasul 1: Deconectează încărcătorul și consumă bateria până la 0%."
        } else if batteryState == .unplugged && batteryLevel <= 5 {
            calibrationStep = "Aproape gata! Lasă telefonul să se închidă singur."
        } else if batteryState == .charging {
            calibrationStep = "Pasul 2: Telefonul se încarcă. Lasă-l conectat neîntrerupt până ajunge la 100% și mai lasă-l 2 ore după aceea."
        } else if batteryLevel >= 100 && batteryState == .full {
            calibrationStep = "Calibrare completă! Valorile interne ale iOS-ului au fost resetate."
            saveCalibrationHistory()
            calibrationInProgress = false
        }
    }
    
    func saveCalibrationHistory() {
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        var history = UserDefaults.standard.stringArray(forKey: "CalibrationHistory") ?? []
        history.append("Calibrare completată pe: \(date)")
        UserDefaults.standard.set(history, forKey: "CalibrationHistory")
    }
}
