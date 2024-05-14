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
        
        return extractedText.isEmpty ? nil : self.cleanText(extractedText)
    }

    private func isWebURL(_ url: URL) -> Bool {
        return url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https"
    }
    
    private func cleanText(_ text: String) -> String {
        var cleanedText = text
        
        // 1. Remove references and citations (example format [1], [2], etc.)
        cleanedText = cleanedText.replacingOccurrences(of: "\\[\\d+\\]", with: "", options: .regularExpression)
        
        // 2. Remove unnecessary symbols
        let symbolsToRemove = ["@", "#", "$", "%", "^", "&", "*", "(", ")", "=", "+", "[", "]", "{", "}", "<", ">", "/", "\\", "|", "~", "`"]
        for symbol in symbolsToRemove {
            cleanedText = cleanedText.replacingOccurrences(of: symbol, with: "")
        }
        
        // 3. Remove annotations (parenthetical information)
        cleanedText = cleanedText.replacingOccurrences(of: "\\(.*?\\)", with: "", options: .regularExpression)
        
        // 4. Remove headers and footers (common patterns)
        cleanedText = cleanedText.replacingOccurrences(of: "(?i)(header text|footer text|page \\d+|date|confidential|author)", with: "", options: .regularExpression)
        
        // 7. Remove web links
        cleanedText = self.removeHTTPLinks(from: cleanedText)

        // 8. Additional cleaning steps based on specific content
        // Clean author and affiliation lines
        cleanedText = cleanedText.replacingOccurrences(of: "\\s+\\d+\\s\\w+\\s.+,\\s\\w+", with: "", options: .regularExpression)
        cleanedText = cleanedText.replacingOccurrences(of: "e-mail:.*", with: "", options: .regularExpression)
        
        // 9. Remove any remaining multiple newlines
        cleanedText = cleanedText.replacingOccurrences(of: "\n{2,}", with: "\n", options: .regularExpression)
        
        return cleanedText
    }
    
    private func removeHTTPLinks(from text: String) -> String {
        // Define the regular expression pattern for HTTP links
        let pattern = "http[s]?:[^\\s]+"
        
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return text
        }
        
        // Replace matches with an empty string
        let modifiedText = regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), withTemplate: "")
        
        return modifiedText
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
