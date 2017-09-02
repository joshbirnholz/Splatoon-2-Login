//
//  Input.swift
//	Input
//
//  Created by Josh Birnholz on 6/1/16.
//  Copyright © 2016 Josh Birnholz. All rights reserved.
//
import Foundation

/// This class can be used to obtain input from the user at the command line.
class Input {
	
	/**
	Returns the next input from the standard input as a String.
	- returns: The next input from the standard input, as a String.
	*/
	class func next() -> String {
		let inputData = FileHandle.standardInput.availableData
		return (NSString(data: inputData, encoding: String.Encoding.utf8.rawValue)! as String).replacingOccurrences(of: "\n", with: "")
	}
	
	/**
	Returns the next input from the standard input as an Int. If the user's input cannot be converted to an Int, `nil` is returned.
	- parameter force: If this parameter is true, the function will not return a value until the user inputs a valid Int. `nil` will never be returned when `force` is true.
	- returns: The next input from the standard input, as an Int, or `nil` if the user's input could not be converted to an Int.
	*/
	class func nextInt(force: Bool = false) -> Int? {
		
		if force {
			guard let value = Int(next()) else {
				return nextInt(force: true)
			}
			return value
		}
		
		return Int(next())
	}
	
	/**
	Returns the next input from the standard input as a Bool. If the user's input cannot be converted to a Bool, `nil` is returned. The following values can be interpreted as a Bool:
	* true
	* yes
	* t
	* y
	* false
	* no
	* f
	* n
	
	- parameter force: If this parameter is true, the function will not return a value until the user inputs a valid Bool. `nil` will never be returned when `force` is true.
	- returns: The next input from the standard input, as a Bool, or `nil` if the user's input could not be converted to a Bool.
	*/
	class func nextBool(force: Bool = false) -> Bool? {
		var bool: Bool?
		
		switch next().lowercased() {
		case "false", "f", "no", "n":
			bool = false
		case "true", "t", "yes", "y":
			bool =  true
		default:
			bool = nil
		}
		
		if force {
			guard bool != nil else {
				return nextBool(force: true)
			}
		}
		
		return bool
	}
	
	/**
	Returns the next input from the standard input as a Double. If the user's input cannot be converted to a Double, `nil` is returned.
	- parameter force: If this parameter is true, the function will not return a value until the user inputs a valid Double. `nil` will never be returned when `force` is true.
	- returns: The next input from the standard input, as a Double, or `nil` if the user's input could not be converted to a Double.
	*/
	class func nextDouble(force: Bool = false) -> Double? {
		
		if force {
			guard let value = Double(next()) else {
				return nextDouble(force: true)
			}
			return value
		}
		
		return Double(next())
	}
	
	/**
	Returns the next input from the standard input as a Float. If the user's input cannot be converted to a Float, `nil` is returned.
	- parameter force: If this parameter is true, the function will not return a value until the user inputs a valid Float. `nil` will never be returned when `force` is true.
	- returns: The next input from the standard input, as a Float, or `nil` if the user's input could not be converted to a Float.
	*/
	class func nextFloat(force: Bool = false) -> Float? {
		
		if force {
			guard let value = Float(next()) else {
				return nextFloat(force: true)
			}
			return value
		}
		
		return Float(next())
	}
	
}
