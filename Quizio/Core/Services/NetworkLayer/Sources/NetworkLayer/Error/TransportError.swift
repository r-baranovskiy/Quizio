import Foundation

public enum TransportError: Error
{
    case offline, timeout, dnsFailure, cannotConnect, cancelled,tlsFailure, unknown
}
