//
//  NSRegularExpression+FirstMatch.swift
//  Splatoon 2
//
//  Created by Josh Birnholz on 8/29/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

extension NSRegularExpression {
	
	func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = []) -> String? {
		guard let token_codeRange = firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))?.range,
			let range = Range(token_codeRange, in: string) else {
				return nil
		}
		
		return String(string[range])
	}
	
	func matches(in string: String, options: NSRegularExpression.MatchingOptions = []) -> [String] {
		let fullRange = NSRange(location: 0, length: string.count)
		
		let ranges = matches(in: string, options: options, range: fullRange)
		
		return ranges.flatMap {
			guard let range = Range($0.range, in: string) else {
				return nil
			}
			return String(string[range])
		}
	}
	
}
