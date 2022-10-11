//
//  main.swift
//  courseSnooper
//
//  Created by Camille Pureza on 2022-10-10.
//

import Foundation
import ArgumentParser

struct CourseSnooper: ParsableCommand {
  
    @Argument(help: "Department code (e.x. MATH, CPSC)") var department: String
    @Argument(help: "Course number (e.x. 107, 200)") var course: Int
    @Argument(help: "Section number (e.x. 107, 109)") var section: Int
  
    func run() throws {
        // Additional wrapper necessary to get URLSession to work within CLI project
        // https://developer.apple.com/forums/thread/713085
        func main() {
            let urlString = "https://courses.students.ubc.ca/cs/courseschedule?pname=subjarea&tname=subj-section&dept=\(department)&course=\(course)&section=\(section)"
            guard let url = URL(string: urlString) else {
                print("Failed to create url from parameters")
                CourseSnooper.exit()
            }
        
            let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
                guard error == nil,
                      let data = data,
                      let dataString = String(data: data, encoding: .utf8) else {
                    print("Failed to retrieve course data from url")
                    CourseSnooper.exit()
                }
                
                // Assumption that if we have invalid parameters, the UBC website will return a page with this string
                // e.x.: https://courses.students.ubc.ca/cs/courseschedule?pname=subjarea&tname=subj-section&dept=MATH&course=2192038091&section=128037019283
                guard !dataString.contains("The requested section is either no longer offered at UBC") else {
                    print("The requested class cannot be found")
                    CourseSnooper.exit()
                }

                // Option 1: Use an HTML parser to crawl the HTML
                // Option 2: Just parse the plain string
        
                /* Use option 2
                 *  Assumption:
                 *      In the HTML, the data we are interested in is stored like this:
                 *      <tr><td width=&#39;200px&#39;>Total Seats Remaining:</td><td align=&#39;left&#39;><strong>3</strong></td></tr>
                 *  HACK!!!:
                 *      - I'll just look for the string "Total Seats Remaining:"
                 *      - After that index, we will look for the contents of <strong>XXX</strong>
                 *  NOTE: This is super flimsy and will need to be re-writted everytime UBC changes their code.
                 */
        
                // Adding 'case' to some 'let's to allow for non-optional init within guard
                // https://stackoverflow.com/questions/35415025/using-guard-with-a-non-optional-value-assignment
                guard let totalSeatsIndex = dataString.range(of: "Total Seats Remaining:")?.upperBound,
                      case let trimmedString = String(dataString[totalSeatsIndex..<dataString.endIndex]),
                      let startIndex = trimmedString.range(of: "<strong>"),
                      let afterIndex = trimmedString.range(of: "</strong>"),
                      case let totalSeatsValue = String(trimmedString[startIndex.upperBound..<afterIndex.lowerBound]) else {
                    print("Failed to retrieve the number of total seats from the HTML")
                    CourseSnooper.exit()
                }

                print("totalSeatsValue: \(totalSeatsValue)")
                CourseSnooper.exit()
            }
        
            task.resume()
        }
        
        main()
        dispatchMain()
    }
}

CourseSnooper.main()
