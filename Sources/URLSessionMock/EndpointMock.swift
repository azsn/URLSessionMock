import Foundation

public protocol EndpointMock {
	/// Handles a network request made by a URLSession
	func handle(request: URLRequest, client: URLProtocolClient, protocol proto: URLProtocol)
}

extension Notification.Name {
	/// May optionally be emitted on the default NotificationCenter by EndpointMock implementations.
	/// The object of the notification must be the EndpointMock instance.
	public static let EndpointMockDidHandleRequest = Notification.Name("EndpointMockDidHandleRequest")
}
