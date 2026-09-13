import Foundation

enum SimulatorList {
    struct Device {
        let udid: String
        let name: String
        let state: String

        init(udid: String = "21B507D3-909E-465B-957C-4B370278399F", name: String = "iPhone 17", state: String = "Shutdown") {
            self.udid = udid
            self.name = name
            self.state = state
        }
    }

    static func reporting(_ runtimes: [String: [Device]]) -> String {
        let written = runtimes.mapValues { devices in
            devices.map { ["udid": $0.udid, "name": $0.name, "state": $0.state] }
        }
        let data = (try? JSONSerialization.data(withJSONObject: ["devices": written])) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
