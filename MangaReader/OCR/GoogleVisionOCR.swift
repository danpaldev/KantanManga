//
//  GoogleVisionOCR.swift
//  Kantan-Manga
//
//  Created by Daniel Palacios on 19/03/24.
//

import Foundation
import UIKit

class GoogleVisionOCR: ImageOCR {
    
    static private let apiKey = ""
    private let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    
    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.pngData()?.base64EncodedString() else {
            completion(.failure(GoogleVisionOCRError.customError(message: "Image data conversion failed")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json: [String: Any] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION"
                    ]
                ]
            ]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? GoogleVisionOCRError.customError(message: "Network or server error")))
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let responses = jsonResult["responses"] as? [[String: Any]],
                   let textAnnotations = responses.first?["textAnnotations"] as? [[String: Any]],
                   let firstAnnotation = textAnnotations.first,
                   let detectedText = firstAnnotation["description"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(detectedText))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(GoogleVisionOCRError.noTextObservationsFound))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(GoogleVisionOCRError.customError(message: "Failed to parse response")))
                }
            }
        }
        
        task.resume()
    }
    
    enum GoogleVisionOCRError: Error {
        case recognitionError
        case cgImageConversionError
        case noTextObservationsFound
        case customError(message: String)
        
        var localizedDescription: String {
            switch self {
            case .recognitionError:
                return "Recognition error occurred."
            case .cgImageConversionError:
                return "Could not convert UIImage to CGImage."
            case .noTextObservationsFound:
                return "No text observations found."
            case .customError(let message):
                return message
            }
        }
    }
}
