//
//  main.swift
//  courseSnooper
//
//  Created by Camille Pureza on 2022-10-10.
//

import Foundation

func main() {
    let department = "MATH" //Change to whatever department
    let courseNumber = "200" //Change to whatever courseNumber
    let sectionNumber = "109" //Change to whatever sectionNumber
    let urlString = "https://courses.students.ubc.ca/cs/courseschedule?pname=subjarea&tname=subj-section&dept=\(department)&course=\(courseNumber)&section=\(sectionNumber)"
    guard let url = URL(string: urlString) else { exit(0) }

    let task = URLSession(configuration: .default).dataTask(with: url) { data, response, error in
        guard error == nil,
              let data = data,
              let dataString = String(data: data, encoding: .utf8) else {
            print("Failed to retrieve course data from url")
            return
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
        
        let totalSeatsIndex = dataString.range(of: "Total Seats Remaining:")!.upperBound
        let trimmedString = String(dataString[totalSeatsIndex..<dataString.endIndex])
        
        let startIndex = trimmedString.range(of: "<strong>")
        let afterIndex = trimmedString.range(of: "</strong>")
        
        let totalSeatsValue = String(trimmedString[startIndex!.upperBound..<afterIndex!.lowerBound])
        print("totalSeatsValue: \(totalSeatsValue)")

        exit(0)
    }

    task.resume()
}

main()
dispatchMain()
