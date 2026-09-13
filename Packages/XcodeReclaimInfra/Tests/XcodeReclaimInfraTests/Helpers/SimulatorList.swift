import Foundation

enum SimulatorList {
    struct Device {
        let udid: String
        let name: String
        let state: String
        let dataPathSize: Int?

        init(
            udid: String = "21B507D3-909E-465B-957C-4B370278399F",
            name: String = "iPhone 17",
            state: String = "Shutdown",
            dataPathSize: Int? = 0
        ) {
            self.udid = udid
            self.name = name
            self.state = state
            self.dataPathSize = dataPathSize
        }
    }

    static func reporting(_ runtimes: [String: [Device]]) -> String {
        let written = runtimes.mapValues { devices in
            devices.map { device -> [String: Any] in
                var written: [String: Any] = ["udid": device.udid, "name": device.name, "state": device.state]
                written["dataPathSize"] = device.dataPathSize
                return written
            }
        }
        let data = (try? JSONSerialization.data(withJSONObject: ["devices": written])) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}
