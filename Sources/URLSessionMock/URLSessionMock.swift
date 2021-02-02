import XCTest
import Foundation

/// A fake protocol which prevents its owning URLSession from making any real
/// network requests. It responds with a URLResponse and Data based on the
/// mock endpoint matching the request URL.
class URLProtocolMock: URLProtocol {
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	override func stopLoading() { }

	override func startLoading() {
		if let client = self.client {
			if let url = self.request.url {
				if let endpoint = URLSession.mockEndpoints[url] {
					var req = self.request
					req.bodyStreamToData()
					endpoint.handle(request: req, client: client, protocol: self)
					return
				} else {
					XCTFail("No mock endpoint assigned for URL: \(url)")
				}
			} else {
				XCTFail("No URL set for request: \(self.request)")
			}
			client.urlProtocolDidFinishLoading(self) // Only on XCTFail
		} else {
			XCTFail("No client set for request: \(self.request)")
		}
	}
}

extension URLRequest {
	// The URL Loading System converts httpBody to httpBodyStream before
	// passing the request to URLProtocol.startLoading. Streams are
	// inconvenient for unit tests, so automatically read the stream and
	// assign it to request's httpBody.
	mutating func bodyStreamToData() {
		guard
			self.httpBody == nil,
			let stream = self.httpBodyStream
		else {
			return
		}

		var buffer = Array<UInt8>(repeating: 0, count: 100)
		var data = Data()

		stream.open()
		while stream.hasBytesAvailable {
			let len = stream.read(&buffer, maxLength: buffer.count)
			data.append(buffer, count: len)
		}

		stream.close()
		self.httpBodyStream = nil
		self.httpBody = data
	}
}

extension URLSessionConfiguration {
	/// Returns a new URLSessionConfiguration which does not make any real network requests.
	/// See URLSession.mock for details.
	public static var mock: URLSessionConfiguration {
		get {
			let conf = URLSessionConfiguration.ephemeral
			conf.protocolClasses = [URLProtocolMock.self]
			return conf
		}
	}
}

extension URLSession {
	/// Mock endpoints used by a `URLSession.mock`
	public static var mockEndpoints = [URL: EndpointMock]()

	/// Returns a new ephemeral URLSession which does not make any real network requests.
	/// Example usage:
	/// ```
	/// let url = URL(string: "example.com")!
	/// let session = URLSession.mock
	/// URLSession.mockEndpoints = [url: BasicEndpointMock(data: Data("test".utf8))]
	/// session.dataTask(with: url) { (response, data, error) in
	///     // response is 200 OK, data is "test".utf8
	/// }.resume()
	/// ```
	public static var mock: URLSession {
		get { URLSession(configuration: .mock) }
	}

	/// Convenience for creating a regular (non-mocked) ephemeral URLSession
	public static var ephemeral: URLSession {
		get { URLSession(configuration: .ephemeral) }
	}
}
