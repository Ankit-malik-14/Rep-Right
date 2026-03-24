//
//  MeathodStore.swift
//  Rep-Right
//
//  Created by Ankit Malik on 2026-03-23.
//

import Foundation
import SwiftUI

//MARK: - Function to convert [String] -> String
func arrayToString(arrayOfStrings: [String]) -> String{
    if arrayOfStrings.isEmpty{
        return "-/-"
    }
    if arrayOfStrings.count == 1{
        return arrayOfStrings[0]
    }
    var result = ""
    for i in arrayOfStrings{
        if i == arrayOfStrings.last{
            result = result + i
        }
        else{
            result = result + i + ", "
        }
    }
    return result
}


//MARK: - function to make [String] -> Points of paragraph
@ViewBuilder
func pointView(steps: [String]) -> some View {
    ForEach(steps,id: \.self){ step in
        HStack(alignment: .top){
            Text(steps.firstIndex(of: step )! + 1,format: .number)
                .fontWeight(.semibold)
            Text(step)
        }
    }
}
