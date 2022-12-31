// In-Out Parameters:

func swapTwoStrings(_ a: inout String, _ b: inout String) {
    let tempA = a
    a = b
    b = tempA
}

var QA = "Fady"
var Dev = "Derek"

swapTwoStrings(&QA, &Dev)

print("In an alternative universive, QA is \(QA)! and Dev is \(Dev)!")


// Generic Function is a function that can work with any type;

func swapAny<T>(_ a: inout T, _ b: inout T) {
    let tempA = b
    b = a
    a = tempA
}



