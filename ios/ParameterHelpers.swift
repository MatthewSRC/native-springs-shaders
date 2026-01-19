import Foundation
import simd

func extractFloat2(from params: [String: Any], arrayName: String, xName: String? = nil, yName: String? = nil, defaultValue: SIMD2<Float>) -> SIMD2<Float> {
    if let array = params[arrayName] as? [Float], array.count >= 2 {
        return SIMD2<Float>(array[0], array[1])
    } else if let array = params[arrayName] as? [Double], array.count >= 2 {
        return SIMD2<Float>(Float(array[0]), Float(array[1]))
    } else if let array = params[arrayName] as? [NSNumber], array.count >= 2 {
        return SIMD2<Float>(array[0].floatValue, array[1].floatValue)
    }

    if let xName = xName, let yName = yName {
        let x = (params[xName] as? Float) ?? defaultValue.x
        let y = (params[yName] as? Float) ?? defaultValue.y
        return SIMD2<Float>(x, y)
    }

    return defaultValue
}


func extractFloat3(from params: [String: Any], arrayName: String, rName: String? = nil, gName: String? = nil, bName: String? = nil, defaultValue: SIMD3<Float>) -> SIMD3<Float> {
    if let array = params[arrayName] as? [Float], array.count >= 3 {
        return SIMD3<Float>(array[0], array[1], array[2])
    } else if let array = params[arrayName] as? [Double], array.count >= 3 {
        return SIMD3<Float>(Float(array[0]), Float(array[1]), Float(array[2]))
    } else if let array = params[arrayName] as? [NSNumber], array.count >= 3 {
        return SIMD3<Float>(array[0].floatValue, array[1].floatValue, array[2].floatValue)
    }

    if let rName = rName, let gName = gName, let bName = bName {
        let r = (params[rName] as? Float) ?? defaultValue.x
        let g = (params[gName] as? Float) ?? defaultValue.y
        let b = (params[bName] as? Float) ?? defaultValue.z
        return SIMD3<Float>(r, g, b)
    }

    return defaultValue
}

func boolToFloat(from params: [String: Any], key: String, defaultValue: Bool) -> Float {
    if let boolValue = params[key] as? Bool {
        return boolValue ? 1.0 : 0.0
    } else if let numValue = params[key] as? NSNumber {
        return numValue.boolValue ? 1.0 : 0.0
    } else if let floatValue = params[key] as? Float {
        return floatValue
    }
    return defaultValue ? 1.0 : 0.0
}
