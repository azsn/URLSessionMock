# URLSessionMock

A mock for Swift's URLSession network request class, allowing unit tests to
mock responses from API endpoints without any real network access. Any type of
server response can be mocked, but currently this package focuses on HTTP
endpoints. In addition, this package contains some related utility functions
that may be useful in unit tests using URLSessionMock.

### Usage example:

```swift
// Test setup
let session = URLSession.mock
let url = URL(string: "https://example.com")
let mock = BasicEndpointMock(status: 404)
URLSession.mockEndpoints = [url: mock]

// Production code to test
session.dataTask(with: url) { (data, response, error) in
	// response is a HTTPURLResponse with 404 status
}.resume()
```

### License

MIT
