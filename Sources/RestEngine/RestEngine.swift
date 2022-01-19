import Foundation


public enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public class Resource<T: Codable> {
    
    var urlString: String
    var parameters: [String : AnyObject]
    var headers: [String : String]
   public init(urlString: String, parameters: [String : AnyObject], headers: [String : String]) {
            self.urlString = urlString
            self.parameters = parameters
            self.headers = headers
        }
}

public class RestSession {
    public init() {}
    
    public func makeGetRequest<T : Codable>(_ resource: Resource<T>,
                                     completion: @escaping (T?) -> ()) {
        makeRequest(.get,
                    resource,
                    completion: completion)
    }
    
    public func makePostRequest<T : Codable>(_ resource: Resource<T>,
                                      completion: @escaping (T?) -> ()) {
        makeRequest(.post,
                    resource,
                    completion: completion)
    }
    
    public func makePutRequest<T : Codable>(_ resource: Resource<T>,
                                     completion: @escaping (T?) -> ()) {
        makeRequest(.put,
                    resource,
                    completion: completion)
    }
    
}

extension RestSession {
    
    public func makeRequest<T : Codable>(_ type: RequestType,
                                  _ resource: Resource<T>,
                                  completion: @escaping (T?) -> ()) {
        guard let serviceUrl = URL(string: resource.urlString) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = type.rawValue
        resource.headers.forEach { request.setValue($0.1, forHTTPHeaderField: $0.0) }
        if type == .post || type == .put { request.httpBody = getHttpBody(from: resource.parameters) }
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            do {
                if let data = data {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result)
                }
            } catch let error {
                if let decodingError = error as? DecodingError {
                    print("Decoding error", decodingError, response ?? URLResponse())
                }
                completion(nil)
            }
        }.resume()
    }
    
    public func getHttpBody(from params: [String: AnyObject]) -> Data? {
        if let httpBody = try? JSONSerialization
            .data(withJSONObject: params,
                  options: []) {
            return httpBody
        }
        return nil
    }
    
}
