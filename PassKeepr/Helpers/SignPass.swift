import Foundation

class pkPassSigner: NSObject, ObservableObject, URLSessionDelegate {
    @Published var isDataLoaded: Bool = false
    @Published var fileURL: URL? = nil

    func uploadPKPassFile(fileURL: URL, passUuid: UUID) {
        let url = URL(string: "https://localhost:3000/sign")

        var request = URLRequest(url: url!)
        request.httpMethod = "POST"

        // Prepare form data boundary
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create the body
        var body = Data()

        // Add the file data to the body
        if let fileData = try? Data(contentsOf: fileURL) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"pkpass\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/vnd.apple.pkpass\r\n\r\n".data(using: .utf8)!)
            body.append(fileData)
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        } else {
            print("Error: Unable to read file data")
            return
        }

        request.httpBody = body

        // Create a URLSession with delegate
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        // Perform the upload task
        DispatchQueue.global(qos: .userInitiated).async {
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                // Handle response
                if let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) {
                    print("Upload successful!")

                    // Save the response data to a file
                    if let data = data {
                        let fileManager = FileManager.default
                        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentsDirectory.appendingPathComponent("\(passUuid).pkpass")
                        DispatchQueue.main.async {
                            self.fileURL = destinationURL
                        }

                        do {
                            try data.write(to: destinationURL)
                            print("File saved to: \(destinationURL.path)")
                            DispatchQueue.main.async {
                                self.isDataLoaded = true
                            }
                        } catch {
                            print("Error saving file: \(error)")
                            DispatchQueue.main.async {
                                self.isDataLoaded = false
                            }
                        }
                    }
                } else {
                    print("Upload failed with response: \(String(describing: response))")
                    DispatchQueue.main.async {
                        self.isDataLoaded = false
                    }
                }
            }

            // Start the upload task
            task.resume()
            DispatchQueue.main.async {
                self.isDataLoaded = false // Immediately set isDataLoaded to false, it will be set to true once the signed pass is successfully received
            }
        }
        print("waiting for pass to be signed, isDataLoaded = false")
    }

    // Trust the self-signed certificate
    // Called by URLSession automatically as a delegate method when it sees an untrusted cert
    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil) // Default handling for other challenges
    }
}
