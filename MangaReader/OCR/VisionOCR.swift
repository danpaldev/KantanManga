//
//  VisionOCR.swift
//  Kantan-Manga
//
//  Created by Daniel Palacios on 19/03/24.
//

import Foundation
import Vision
import UIKit

class VisionOCR: ImageOCR {
    
    enum VisionOCRError: Error {
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

    func recognize(image: UIImage, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(VisionOCRError.cgImageConversionError))
            return
        }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                completion(.failure(VisionOCRError.customError(message: error.localizedDescription)))
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(VisionOCRError.noTextObservationsFound))
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                print(observation)
                return observation.topCandidates(1).first?.string
            }.joined(separator: "\n")

            completion(.success(recognizedStrings))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ja"]

        do {
            try requestHandler.perform([request])
        } catch {
            completion(.failure(VisionOCRError.customError(message: error.localizedDescription)))
        }
    }
}
