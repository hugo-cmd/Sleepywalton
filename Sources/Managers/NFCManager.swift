import Foundation
#if canImport(CoreNFC)
import CoreNFC
#endif

final class NFCManager: NSObject {
    var onTagDetected: ((String) -> Void)?

    func scanOnce() {
        #if canImport(CoreNFC)
        if NFCNDEFReaderSession.readingAvailable {
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            session.alertMessage = "Hold near NFC tag"
            session.begin()
        }
        #endif
    }
}

#if canImport(CoreNFC)
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) { }
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { }
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCTag]) { }
}
#endif