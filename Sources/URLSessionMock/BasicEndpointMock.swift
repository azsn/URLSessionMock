import Foundation

/// Implementation of EndpointMock for a generic synchronous HTTP endpoint.
///
/// This mock always responses the same to every request it handles. It also
/// keeps track of requests it has handled through the `requests` property,
/// and emits the EndpointMockDidHandleRequest notification on the default
/// NotificationCenter after each handled request.
///
/// This mock is synchronous, so the URLSession's task completion handler
/// will be called before `URLSessionTask.resume()` returns. This is
/// convenient because your test's "assert" section can directly follow the "act"
/// section without needing `expectation` or otherwise blocking, but may
/// not be appropriate if testing multi-thread handling. Relatedly, this mock is
/// not thread-safe.
public class BasicEndpointMock: EndpointMock {

	/// The response HTTP status
	public var status: Int

	/// The URL associated with the response. If nil, this defaults to the request URL
	public var url: URL?

	/// The headers associated with the response. If nil, the response contains no headers.
	///
	/// TODO: URLSession seems to ignore cookies set in these headers and does not
	/// automatically add them to the session's cookie store as it does with normal
	/// HTTP responses. Why?
	public var headers: [String : String]?

	/// The body data of the HTTP response. If nil, the body will be empty.
	public var body: Data?

	/// If not nil, the mock will act as if the network request failed entirely, and the
	/// URLSession's task will fail with this error and not return any response.
	/// This is useful to mock network connection failures.
	public var error: Error?

	/// This is a list of every request this mock has handled. New requests are
	/// appended. You may safely clear the list of requests by setting this property
	/// to `[]`.
	public var requests: [URLRequest] = []

	/// Do not call directly; invoked by URLSession to handle requests.
	public func handle(
		request: URLRequest,
		client: URLProtocolClient,
		protocol proto: URLProtocol
	) {
		self.requests.append(request)

		if let error = self.error {
			client.urlProtocol(proto, didFailWithError: error)
		} else {
			let resp = HTTPURLResponse(
				url: self.url ?? request.url!,
				statusCode: self.status,
				httpVersion: "HTTP/1.1",
				headerFields: self.headers)!
			client.urlProtocol(proto, didReceive: resp, cacheStoragePolicy: .allowed)
			if let body = self.body {
				client.urlProtocol(proto, didLoad: body)
			}
		}
		client.urlProtocolDidFinishLoading(proto)

		NotificationCenter.default.post(name: .EndpointMockDidHandleRequest, object: self)
	}

	/// Specify any parameters necessary for the response this endpoint mock should make.
	/// Unspecified parameters get reasonable defaults. If `error` is specified, all other
	/// parameters are ignored and the requester only gets the error returned.
	public init(status: Int = 200, url: URL? = nil, body: Data? = Data(), headers: [String: String]? = nil, error: Error? = nil) {
		self.status = status
		self.url = url
		self.headers = headers
		self.body = body
		self.error = error
	}
}
