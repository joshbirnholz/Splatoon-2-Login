//
//  main.swift
//  Splatoon 2
//
//  Created by Josh Birnholz on 8/26/17.
//  Copyright © 2017 Joshua Birnholz. All rights reserved.
//

import Foundation

print("Enter username: ", terminator: "")
let name = Input.next()
print("Enter password: ", terminator: "")
let password = Input.next()

let semaphore = DispatchSemaphore(value: 0)

login(username: name, password: password) { token in
	if let token = token {
		print("Token: ", token)
	} else {
		print("Couldn't get token")
	}
	semaphore.signal()
}

semaphore.wait()

