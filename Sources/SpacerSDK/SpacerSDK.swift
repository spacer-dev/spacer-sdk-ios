public class SpacerSDK {
    public class func cbLockerService() -> CBLockerService {
        return CBLockerService()
    }

    public class func myLockerService() -> MyLockerService {
        return MyLockerService()
    }

    public class func sprLockerService() -> SPRLockerService {
        return SPRLockerService()
    }

    private(set) static var config = SPRConfig.Default
    public class func configure(config: SPRConfig) {
        self.config = config
    }
}

public typealias SPR = SpacerSDK
