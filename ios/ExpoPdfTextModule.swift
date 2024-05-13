import ExpoModulesCore
import PDFKit
import Foundation

public class ExpoPdfTextModule: Module {
    public func definition() -> ModuleDefinition {
        Name("ExpoPdfText")

        AsyncFunction("parsePdf") { (url: String, promise: Promise) in
            guard let pdfUrl = URL(string: url) else {
              promise.reject("INVALID_URL", "Invalid URL provided.")
              return
            }

            if self.isWebURL(pdfUrl) {
                self.downloadPDF(from: pdfUrl) { result in
                    switch result {
                    case .success(let downloadedURL):
                        DispatchQueue.main.async {
                            if let parsedText = self.extractText(fromPDF: downloadedURL) {
                                promise.resolve(parsedText)
                            } else {
                                promise.reject("PARSE_ERROR", "Failed to parse the PDF.")
                            }
                        }
                    case .failure(let error):
                        promise.reject("DOWNLOAD_ERROR", "Failed to download file: \(error.localizedDescription)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if let parsedText = self.extractText(fromPDF: pdfUrl) {
                        promise.resolve(parsedText)
                    } else {
                        promise.reject("PARSE_ERROR", "Failed to parse the PDF.")
                    }
                }
            }
        }
    }

    private func extractText(fromPDF url: URL) -> String? {
        guard let pdfDocument = PDFDocument(url: url) else {
            print("Unable to create PDF document")
            return nil
        }
        
        let numberOfPages = pdfDocument.pageCount
        var extractedText = ""
        
        for i in 0..<numberOfPages {
            guard let page = pdfDocument.page(at: i) else { continue }
            if let pageText = page.string {
                extractedText += pageText
            }
        }
        
        return extractedText.isEmpty ? nil : extractedText
    }

    private func isWebURL(_ url: URL) -> Bool {
        return url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https"
    }

    private func downloadPDF(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            guard let localURL = localURL else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Downloaded file could not be located"])))
                return
            }
            
            completion(.success(localURL))
        }
        downloadTask.resume()
    }
}
