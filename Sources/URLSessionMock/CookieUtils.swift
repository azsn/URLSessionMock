import Foundation

extension HTTPCookieStorage {
	/// Returns true if the named cookie is stored for any domain in this session.
	public func hasCookie(_ name: String) -> Bool {
		for cookie in self.cookies ?? [] {
			if cookie.name == name {
				return true
			}
		}
		return false
	}

	/// Adds each cookie in the array to the store.
	public func setCookies(_ cookies: [HTTPCookie]) {
		for cookie in cookies {
			self.setCookie(cookie)
		}
	}

	/// Removes cookies from the store by name, regardless of domain.
	public func removeCookies(_ names: [String]) {
		for cookie in self.cookies ?? [] {
			if names.contains(cookie.name) {
				self.deleteCookie(cookie)
			}
		}
	}
}

extension URLSession {
	/// Calls hasCookie on this session's cookie store
	public func hasCookie(_ name: String) -> Bool {
		return configuration.httpCookieStorage?.hasCookie(name) ?? false
	}

	/// Calls setCookies on this session's cookie store
	public func setCookies(_ cookies: [HTTPCookie]) {
		configuration.httpCookieStorage?.setCookies(cookies)
	}

	/// Calls removeCookies on this session's cookie store
	public func removeCookies(_ names: [String]) {
		configuration.httpCookieStorage?.removeCookies(names)
	}
}

extension HTTPCookie {
	/// Convenience for quickly creating an HTTPCookie.
	/// Note that because cookies created with this function do not have an expiration
	/// date set, HTTPCookieStorage will not save them across application restarts.
	public static func make(
		path: String = "/",
		name: String = "name",
		value: String = "value",
		domain: String = "example.com"
	) -> HTTPCookie {
		return HTTPCookie(properties: [
			.path: path,
			.name: name,
			.value: value,
			.domain: domain
		])!
	}
}
