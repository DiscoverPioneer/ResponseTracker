import Foundation

class CallsDataProvider {
    class func getCalls() -> [Call] {
        var sampleData: [Call] = []

        let response1 = Response(incidentNumber: "123", details: "", date: Date())
        let response2 = Response(incidentNumber: "123", details: "", date: Date())
        let response3 = Response(incidentNumber: "123", details: "", date: Date())

        sampleData.append(Call(type: "Structure Fire", responses: nil))
        sampleData.append(Call(type: "Training", responses: [response1]))
        sampleData.append(Call(type: "Ambulance", responses: [response1,response2]))
        sampleData.append(Call(type: "Structure Fire", responses: nil))
        sampleData.append(Call(type: "Training", responses: [response1,response3]))
        sampleData.append(Call(type: "Ambulance", responses: [response1,response2,response3]))
        return sampleData
    }
}
