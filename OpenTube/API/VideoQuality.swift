import Foundation

enum VideoQuality: Int {
    case high
    case medium
    case small
    
    var videoKey: Int {
        switch self {
        case .high:
            return YouTubeQualityKey.av720p.rawValue
        case .medium:
            return YouTubeQualityKey.av360p.rawValue
        case .small:
            return YouTubeQualityKey.av260p.rawValue
        }
    }
}

private enum YouTubeQualityKey: Int {
    typealias RawValue = Int
    
    case av720p = 22
    case av360p = 36
    case av260p = 18
    
    case v1440p = 264
    case v1080p = 137
    case v720p = 136
    case v480p = 135
    case v360p = 134
    case v240p = 133
    case v144p = 160
    
    case a128k = 140
}
