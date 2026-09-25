import Foundation

public enum ContentType: String
{
    case json = "application/json"
    case xml = "application/xml"
    case form = "application/x-www-form-urlencoded"
    case multipart = "multipart/form-data"
}
