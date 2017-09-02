//
//  base64.swift
//  Splatoon 2
//
//  Created by Josh Birnholz on 8/26/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

extension String {
	
	var base64Decoded: String? {
		guard let data = NSData(base64Encoded: self, options: []) else {
			return nil
		}
		let decodedString = String(data: data as Data, encoding: .utf8)
		return decodedString
	}
	
	var urlSafeBase64Decoded: String? {
		return base64Decoded?.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
	}
	
}
