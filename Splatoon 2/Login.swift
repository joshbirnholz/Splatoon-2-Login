//
//  Login.swift
//  Splatoon 2
//
//  Created by Josh Birnholz on 8/26/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

fileprivate struct AuthorizationResponse: Codable {
	var iat: Int
	var iss: URL
	
	struct Ext: Codable {
		var t: String
		
		struct P: Codable {
			var post_login_redirect_uri: URL
		}
		
		var p: P
		
		var a: String
	}
	
	var _ext: Ext
	
	var sub: String
	var jti: String
	var typ: String
	var exp: Int
}

// Takes a username and password, completion block with a string of the session token
func login(username: String, password: String, timeout: TimeInterval = 3, completion: @escaping (String?) -> ()) {
	
	func random() -> String {
		var str = ""
		let letters: NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
		
		for _ in 0 ..< 50 {
			str += String(Character(UnicodeScalar(letters.character(at: Int(arc4random_uniform(UInt32(letters.length)))))!))
		}
		
		return str
	}
	
	func hash(_ text: String) -> String {
		let str = text.sha256Hash()!
		let replaced = str.replacingOccurrences(of: "=", with: "")
			.replacingOccurrences(of: "-", with: "+")
			.replacingOccurrences(of: "/", with: "_")
		return replaced
	}
	
	func hmac(csrf_token: String) -> String {
		let message = [username, password, csrf_token].joined(separator: ":")
		let key = String(csrf_token[csrf_token.index(csrf_token.endIndex, offsetBy: -8)...])
		return message.hexhmac(algorithm: .SHA256, key: key)
	}
	
	func unpack(_ string: String) -> [String: Any] {
		var data = string.split(separator: ".")[1]
		let missingPadding = data.count % 4
		if missingPadding != 0 {
			for _ in 0 ..< missingPadding {
				data += "="
			}
		}
		
		guard let dataData = String(data).base64Decoded?.data(using: .utf8),
			let obj = try? JSONSerialization.jsonObject(with: dataData, options: []),
			let dict = obj as? [String: Any] else {
			return [:]
		}
		
		return dict
	}
	
	// Start method
	
	let decoder = JSONDecoder()
	
	let session = URLSession(configuration: .default)
	
	let JWToken = try! NSRegularExpression(pattern: "(eyJhbGciOiJIUzI1NiJ9\\.[a-zA-Z0-9_-]*\\.[a-zA-Z0-9_-]*)", options: [])
	let clientID = "71b963c1b7b6d119"
	
	let verifier = random()
	let headers = [
		"Accept-Encoding": "gzip",
		"User-Agent": "OnlineLounge/1.0.4 NASDKAPI Android"
	]
	
	// Requests authorization, calls completion handler which takes csrf_token, post_login
	func requestAuthorization(completion: @escaping ((String, URL)?) -> ()) {
		print("Requesting authorization…")
		let authorizationParameters = [
			"client_id": clientID,
			"redirect_uri": "npf\(clientID)://auth",
			"response_type": "session_token_code",
			"scope": "openid user user.birthday user.mii user.screenName",
			"session_token_code_challenge": hash(verifier),
			"session_token_code_challenge_method": "S256",
			"state": random(),
			"theme": "login_form"
		]
		
		var comps = URLComponents(string: "https://accounts.nintendo.com/connect/1.0.0/authorize")!
		
		comps.queryItems = authorizationParameters.map {
			URLQueryItem(name: $0.key, value: String(describing: $0.value))
		}
		
		let authorizationURL = comps.url!
		
		var authorizationRequest = URLRequest(url: authorizationURL)
		authorizationRequest.allHTTPHeaderFields = headers
		authorizationRequest.httpMethod = "GET"
		
		session.dataTask(with: authorizationRequest) { (data, response, error) in
			if let error = error {
				print("Error obtaining authorization:", error.localizedDescription)
				completion(nil)
				return
			}
			
			guard
				let data = data,
				let responseString = String(data: data, encoding: .utf8),
				let csrf_token = JWToken.firstMatch(in: responseString),
				let _ext = unpack(csrf_token)["_ext"] as? [String: Any],
				let p = _ext["p"] as? [String: Any],
				let post_login_string = p["post_login_redirect_uri"] as? String,
				let post_login = URL(string: post_login_string) else {
					completion(nil)
					return
			}
			
			completion((csrf_token, post_login))
			
			}.resume()
	}
	
	// completion block takes token_code
	func login(csrf_token: String, post_login: URL, completion: @escaping (String?) -> ()) {
		print("Logging in…")
		
		let loginParameters: [String : Any] = [
			"csrf_token": csrf_token,
			"display": "",
			"post_login_redirect_uri": post_login,
			"redirect_after": 5,
			"subject_id": username,
			"subject_password": password,
			"_h": hmac(csrf_token: csrf_token)
		]
		
		var comps = URLComponents(string: "https://accounts.nintendo.com/login")!
		
		comps.queryItems = loginParameters.map {
			URLQueryItem(name: $0.key, value: String(describing: $0.value))
		}
		
		let loginURL = comps.url!
		
		var loginRequest = URLRequest(url: loginURL)
		loginRequest.allHTTPHeaderFields = headers
		loginRequest.httpMethod = "POST"
		
		session.dataTask(with: loginRequest) { (data, response, error) in
			if let error = error {
				print("Error logging in:", error.localizedDescription)
				completion(nil)
				return
			}
			
			guard let data = data,
				let responseString = String(data: data, encoding: .utf8) else {
					completion(nil)
					return
			}
			
			guard let token_code = JWToken.firstMatch(in: responseString) else {
				print("Coudln't get token code")
				completion(nil)
				return
			}
			
			print(token_code)
			
			let token_code_unpacked = unpack(token_code)
			
			print(token_code_unpacked)
			
			guard let type = token_code_unpacked["typ"] as? String else {
					completion(nil)
					return
			}
			
			print(type)
			
			guard type == "session_token_code" else {
					completion(nil)
					return
			}
			
			completion(token_code)
			
			}.resume()
		
	}
	
	func getSessionToken(token_code: String, completion: @escaping (String?) -> ()) {
		print("Getting session token…")
		let tokenRequestParameters = [
			"client_id": clientID,
			"session_token_code": token_code,
			"session_token_code_verifier": verifier
		]
		
		var comps = URLComponents(string: "https://accounts.nintendo.com/connect/1.0.0/api/session_token")!
		
		comps.queryItems = tokenRequestParameters.map {
			URLQueryItem(name: $0.key, value: String(describing: $0.value))
		}
		
		let tokenRequestURL = comps.url!
		
		var tokenRequest = URLRequest(url: tokenRequestURL)
		tokenRequest.httpMethod = "POST"
		tokenRequest.allHTTPHeaderFields = headers
		
		session.dataTask(with: tokenRequest) { (data, response, error) in
			if let error = error {
				print("Error requesting token:", error.localizedDescription)
				completion(nil)
				return
			}
			
			guard let data = data,
				let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
				let session_token = json["session_token"] as? String else {
				completion(nil)
				return
			}
			
			completion(session_token)
		}
	}
	
	let startDate = Date()
	
	func authorizationCompletion(result: (String, URL)?) {
		if let (csrf_token, post_login) = result {
			
			func loginCompletion(tokenCode: String?) {
				if let tokenCode = tokenCode {
					
					func tokenCompletion(token: String?) {
						if let token = token {
							completion(token)
						} else if Date().timeIntervalSince(startDate) < timeout {
							tokenCompletion(token: nil)
						} else {
							print("Timeout")
							completion(nil)
						}
					}
					
					tokenCompletion(token: nil)
					
				} else if Date().timeIntervalSince(startDate) < timeout {
					login(csrf_token: csrf_token, post_login: post_login, completion: loginCompletion)
				} else {
					print("timeout")
					completion(nil)
				}
			}
			
			loginCompletion(tokenCode: nil)
		} else if Date().timeIntervalSince(startDate) < timeout {
			requestAuthorization(completion: authorizationCompletion)
		} else {
			print("timeout")
			completion(nil)
		}
		
		
	}
	
	authorizationCompletion(result: nil)
	
}
