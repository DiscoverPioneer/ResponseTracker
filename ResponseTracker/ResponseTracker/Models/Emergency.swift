import Foundation

private struct SerializationKeys {
    static let type = "type"
    static let responses = "responses"
}

class Emergency: NSObject, NSCoding {
    var type: String
    var responses: [Response]?

    init(type: String, responses: [Response]?) {
        self.type = type
        self.responses = responses
    }

    func responsesCount() -> String {
        return String(describing: responses?.count ?? 0)
    }

    func responsesCount() -> Int {
        return responses?.count ?? 0
    }

    func add(response: Response) {
        if responses == nil { responses = [] }
        responses?.append(response)
    }

    func remove(responseAtIndex index: Int) {
        if index >= 0, index < responsesCount() {
            responses?.remove(at: index)
        }
    }

    func remove(response: Response) {
        if let responses = responses, let index = responses.index(where: { (response) -> Bool in
            return response == response
        }) {
            remove(responseAtIndex: responses.distance(from: responses.startIndex, to: index))
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(type, forKey: SerializationKeys.type)
        aCoder.encode(responses, forKey: SerializationKeys.responses)
    }

    required init?(coder aDecoder: NSCoder) {
        type = aDecoder.decodeObject(forKey: SerializationKeys.type) as? String ?? ""
        responses = aDecoder.decodeObject(forKey: SerializationKeys.responses) as? [Response]
    }
}

