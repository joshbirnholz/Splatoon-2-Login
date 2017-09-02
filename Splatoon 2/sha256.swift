//
//  sha256.swift
//  Splatoon 2
//
//  Created by Josh Birnholz on 8/26/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Cocoa

extension Data {
	var sha256: Data? {
		guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
		CC_SHA256((self as NSData).bytes, CC_LONG(self.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
		return res as Data
	}
}

extension String {
	func sha256Hash() -> String? {
		guard
			let data = data(using: .utf8),
			let shaData = data.sha256
			else { return nil }
		let rc = shaData.base64EncodedString(options: [])
		return rc
	}
}
