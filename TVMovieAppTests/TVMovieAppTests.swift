//
//  TVMovieAppTests.swift
//  TVMovieAppTests
//
//  Created by Ben Johnson on 13/05/2016.
//  Copyright © 2016 CSCI342. All rights reserved.
//

import XCTest
@testable import TVMovieApp

class TVMovieAppTests: XCTestCase {
    
    let client = TVMClient()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetTVDBAuthKey() {
        
        let expectation = self.expectationWithDescription("AuthKey Expectation")
        
        client.getTVDBAuthKey { (authKey, error) in
            XCTAssertNotNil(authKey)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func testClientQuery() {
        
        let expectation = self.expectationWithDescription("Client QueryExpectation")
        client.query("Silicon Valley", completition: { (results, error) in
            if let _ = error {
                XCTAssertTrue(results.count == 0)
            } else {
                XCTAssertTrue(results.count > 0)
            }
            expectation.fulfill()
            
        })
        
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    func testGetFilmDetail() {
        let expectation = self.expectationWithDescription("Client Get Film Detail")
        let siliconValleySearchResult = SearchResult(name: "Silicon Valley", posterURL: "", identifier: "277165", type: .Show)
        
        client.getFilmDetail(siliconValleySearchResult) { (film, error) in
            if let film = film {
                XCTAssert(film.name == "Silicon Valley")
                XCTAssertNil(error)
            } else {
                XCTAssertNil(film)
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    
}
