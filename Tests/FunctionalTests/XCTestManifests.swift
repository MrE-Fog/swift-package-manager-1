#if !canImport(ObjectiveC)
import XCTest

extension CFamilyTargetTestCase {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CFamilyTargetTestCase = [
        ("testCanForwardExtraFlagsToClang", testCanForwardExtraFlagsToClang),
        ("testCLibraryWithSpaces", testCLibraryWithSpaces),
        ("testCUsingCAndSwiftDep", testCUsingCAndSwiftDep),
        ("testModuleMapGenerationCases", testModuleMapGenerationCases),
        ("testObjectiveCPackageWithTestTarget", testObjectiveCPackageWithTestTarget),
    ]
}

extension DependencyResolutionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DependencyResolutionTests = [
        ("testExternalComplex", testExternalComplex),
        ("testExternalSimple", testExternalSimple),
        ("testInternalComplex", testInternalComplex),
        ("testInternalExecAsDep", testInternalExecAsDep),
        ("testInternalSimple", testInternalSimple),
    ]
}

extension MiscellaneousTestCase {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__MiscellaneousTestCase = [
        ("testCanBuildMoreThanTwiceWithExternalDependencies", testCanBuildMoreThanTwiceWithExternalDependencies),
        ("testCanKillSubprocessOnSigInt", testCanKillSubprocessOnSigInt),
        ("testCompileFailureExitsGracefully", testCompileFailureExitsGracefully),
        ("testExternalDependencyEdges1", testExternalDependencyEdges1),
        ("testExternalDependencyEdges2", testExternalDependencyEdges2),
        ("testInternalDependencyEdges", testInternalDependencyEdges),
        ("testNoArgumentsExitsWithOne", testNoArgumentsExitsWithOne),
        ("testOverridingSwiftcArguments", testOverridingSwiftcArguments),
        ("testPackageManagerDefineAndXArgs", testPackageManagerDefineAndXArgs),
        ("testPassExactDependenciesToBuildCommand", testPassExactDependenciesToBuildCommand),
        ("testPkgConfigCFamilyTargets", testPkgConfigCFamilyTargets),
        ("testPrintsSelectedDependencyVersion", testPrintsSelectedDependencyVersion),
        ("testReportingErrorFromGitCommand", testReportingErrorFromGitCommand),
        ("testSecondBuildIsNullInModulemapGen", testSecondBuildIsNullInModulemapGen),
        ("testSpaces", testSpaces),
        ("testSwiftTestFilter", testSwiftTestFilter),
        ("testSwiftTestLinuxMainGeneration", testSwiftTestLinuxMainGeneration),
        ("testSwiftTestParallel", testSwiftTestParallel),
        ("testTrivialSwiftAPIDiff", testTrivialSwiftAPIDiff),
        ("testUnicode", testUnicode),
    ]
}

extension ModuleMapsTestCase {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ModuleMapsTestCase = [
        ("testDirectDependency", testDirectDependency),
        ("testTransitiveDependency", testTransitiveDependency),
    ]
}

extension SwiftPMXCTestHelperTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__SwiftPMXCTestHelperTests = [
        ("testBasicXCTestHelper", testBasicXCTestHelper),
    ]
}

extension ToolsVersionTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ToolsVersionTests = [
        ("testToolsVersion", testToolsVersion),
    ]
}

extension VersionSpecificTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__VersionSpecificTests = [
        ("testEndToEndResolution", testEndToEndResolution),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CFamilyTargetTestCase.__allTests__CFamilyTargetTestCase),
        testCase(DependencyResolutionTests.__allTests__DependencyResolutionTests),
        testCase(MiscellaneousTestCase.__allTests__MiscellaneousTestCase),
        testCase(ModuleMapsTestCase.__allTests__ModuleMapsTestCase),
        testCase(SwiftPMXCTestHelperTests.__allTests__SwiftPMXCTestHelperTests),
        testCase(ToolsVersionTests.__allTests__ToolsVersionTests),
        testCase(VersionSpecificTests.__allTests__VersionSpecificTests),
    ]
}
#endif