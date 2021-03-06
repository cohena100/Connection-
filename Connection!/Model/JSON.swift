/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

// Inspired by https://github.com/lingoer/SwiftyJSON

import Foundation

public enum JSONValue {
    
    case JSONObject(NSDictionary)
    case JSONArray(NSArray)
    case JSONString(String)
    case JSONNumber(NSNumber)
    case JSONNull
    
    public var string: String? {
        switch self {
        case .JSONString(let value):
            return value
        default:
            return nil
        }
    }
    
    public var integer: Int? {
        switch self {
        case .JSONNumber(let value):
            return value.integerValue
        default:
            return nil
        }
    }
    
    public var double: Double? {
        switch self {
        case .JSONNumber(let value):
            return value.doubleValue
        default:
            return nil
        }
    }
    
    public var float: Float? {
        switch self {
        case .JSONNumber(let value):
            return value.floatValue
        default:
            return nil
        }
    }
    
    public var bool: Bool? {
        switch self {
        case .JSONNumber(let value):
            return value.boolValue
        default:
            return nil
        }
    }
    
    public subscript(i: Int) -> JSONValue? {
        get {
            switch self {
            case .JSONArray(let value):
                return JSONValue.fromObject(value[i])
            default:
                return nil
            }
        }
    }
    
    public subscript(key: String) -> JSONValue? {
        get {
            switch self {
            case .JSONObject(let value):
                return JSONValue.fromObject(value[key]!)
            default:
                return nil
            }
        }
    }
    
    public static func fromObject(object: AnyObject) -> JSONValue? {
        switch object {
        case let value as NSString:
            return JSONValue.JSONString(value as String)
        case let value as NSNumber:
            return JSONValue.JSONNumber(value)
        case let value as NSNull:
            return JSONValue.JSONNull
        case let value as NSDictionary:
            return JSONValue.JSONObject(value)
        case let value as NSArray:
            return JSONValue.JSONArray(value)
        default:
            return nil
        }
    }
    
}

extension JSONValue: SequenceType {
    
    public func generate() -> GeneratorOf<JSONValue> {
        var enumerator: NSEnumerator?
        switch self {
        case .JSONObject(let value):
            enumerator = value.objectEnumerator()
        case .JSONArray(let value):
            enumerator = value.objectEnumerator()
        default:
            enumerator = nil
        }
        if let enumerator = enumerator {
        } else {
            return GeneratorOf {
                return nil;
            }
        }
        return GeneratorOf {
            let value: AnyObject? = enumerator!.nextObject()
            if let value: AnyObject = value {
            } else {
                return nil
            }
            return JSONValue.fromObject(value!)
        }
    }
    
}
