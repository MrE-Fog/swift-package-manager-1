//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2014-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import XCTest
import SPMTestSupport
import TSCBasic
import PackageModel
import Workspace

class InitTests: XCTestCase {

    // MARK: TSCBasic package creation for each package type.
    
    func testInitPackageEmpty() throws {
        try testWithTemporaryDirectory { tmpPath in
            let fs = localFileSystem
            let path = tmpPath.appending("Foo")
            let name = path.basename
            try fs.createDirectory(path)
            
            // Create the package
            let initPackage = try InitPackage(
                name: name,
                packageType: .empty,
                destinationPath: path,
                fileSystem: localFileSystem
            )
            var progressMessages = [String]()
            initPackage.progressReporter = { message in
                progressMessages.append(message)
            }
            try initPackage.writePackageStructure()

            // Not picky about the specific progress messages, just checking that we got some.
            XCTAssertGreaterThan(progressMessages.count, 0)

            // Verify basic file system content that we expect in the package
            let manifest = path.appending("Package.swift")
            XCTAssertFileExists(manifest)
            let manifestContents: String = try localFileSystem.readFileContents(manifest)
            let version = InitPackage.newPackageToolsVersion
            let versionSpecifier = "\(version.major).\(version.minor)"
            XCTAssertMatch(manifestContents, .prefix("// swift-tools-version:\(version < .v5_4 ? "" : " ")\(versionSpecifier)\n"))
            XCTAssertMatch(manifestContents, .contains(packageWithNameOnly(named: name)))
        }
    }
    
    func testInitPackageExecutable() throws {
        try testWithTemporaryDirectory { tmpPath in
            let fs = localFileSystem
            let path = tmpPath.appending("Foo")
            let name = path.basename
            try fs.createDirectory(path)

            // Create the package
            let initPackage = try InitPackage(
                name: name,
                packageType: .executable,
                destinationPath: path,
                fileSystem: localFileSystem
            )
            var progressMessages = [String]()
            initPackage.progressReporter = { message in
                progressMessages.append(message)
            }
            try initPackage.writePackageStructure()

            // Not picky about the specific progress messages, just checking that we got some.
            XCTAssertGreaterThan(progressMessages.count, 0)
            
            // Verify basic file system content that we expect in the package
            let manifest = path.appending("Package.swift")
            XCTAssertFileExists(manifest)
            let manifestContents: String = try localFileSystem.readFileContents(manifest)
            let version = InitPackage.newPackageToolsVersion
            let versionSpecifier = "\(version.major).\(version.minor)"
            XCTAssertMatch(manifestContents, .prefix("// swift-tools-version:\(version < .v5_4 ? "" : " ")\(versionSpecifier)\n"))

            XCTAssertEqual(try fs.getDirectoryContents(path.appending("Sources")), ["main.swift"])
            XCTAssertBuilds(path)
            let triple = try UserToolchain.default.triple
            let binPath = path.appending(components: ".build", triple.platformBuildPathComponent(), "debug")
#if os(Windows)
            XCTAssertFileExists(binPath.appending("Foo.exe"))
#else
            XCTAssertFileExists(binPath.appending("Foo"))
#endif
            XCTAssertFileExists(binPath.appending(components: "Foo.swiftmodule"))
        }
    }

    func testInitPackageLibrary() throws {
        try testWithTemporaryDirectory { tmpPath in
            let fs = localFileSystem
            let path = tmpPath.appending("Foo")
            let name = path.basename
            try fs.createDirectory(path)

            // Create the package
            let initPackage = try InitPackage(
                name: name,
                packageType: .library,
                destinationPath: path,
                fileSystem: localFileSystem
            )
            var progressMessages = [String]()
            initPackage.progressReporter = { message in
                progressMessages.append(message)
            }
            try initPackage.writePackageStructure()

            // Not picky about the specific progress messages, just checking that we got some.
            XCTAssertGreaterThan(progressMessages.count, 0)

            // Verify basic file system content that we expect in the package
            let manifest = path.appending("Package.swift")
            XCTAssertFileExists(manifest)
            let manifestContents: String = try localFileSystem.readFileContents(manifest)
            let version = InitPackage.newPackageToolsVersion
            let versionSpecifier = "\(version.major).\(version.minor)"
            XCTAssertMatch(manifestContents, .prefix("// swift-tools-version:\(version < .v5_4 ? "" : " ")\(versionSpecifier)\n"))

            XCTAssertEqual(try fs.getDirectoryContents(path.appending("Sources").appending("Foo")), ["Foo.swift"])

            let tests = path.appending("Tests")
            XCTAssertEqual(try fs.getDirectoryContents(tests).sorted(), ["FooTests"])

            let testFile = tests.appending("FooTests").appending("FooTests.swift")
            let testFileContents: String = try localFileSystem.readFileContents(testFile)
            XCTAssertTrue(testFileContents.hasPrefix("import XCTest"), """
                          Validates formatting of XCTest source file, in particular that it does not contain leading whitespace:
                          \(testFileContents)
                          """)
            XCTAssertMatch(testFileContents, .contains("func testExample() throws"))

            // Try building it
            XCTAssertBuilds(path)
            let triple = try UserToolchain.default.triple
            XCTAssertFileExists(path.appending(components: ".build", triple.platformBuildPathComponent(), "debug", "Foo.swiftmodule"))
        }
    }
        
    func testInitPackageCommandPlugin() throws {
        try testWithTemporaryDirectory { tmpPath in
            let fs = localFileSystem
            let path = tmpPath.appending("MyCommandPlugin")
            let name = path.basename
            try fs.createDirectory(path)

            // Create the package
            try InitPackage(
                name: name,
                packageType: .commandPlugin,
                destinationPath: path,
                fileSystem: localFileSystem
            ).writePackageStructure()

            // Verify basic file system content that we expect in the package
            let manifest = path.appending("Package.swift")
            XCTAssertFileExists(manifest)
            let manifestContents: String = try localFileSystem.readFileContents(manifest)
            XCTAssertMatch(manifestContents, .and(.contains(".plugin("), .contains("targets: [\"MyCommandPlugin\"]")))
            XCTAssertMatch(manifestContents, .and(.contains(".plugin("), .contains("capability: .command(intent: .custom(verb")))

            let source = path.appending("Plugins", "MyCommandPlugin", "plugin.swift")
            XCTAssertFileExists(source)
            let sourceContents: String = try localFileSystem.readFileContents(source)
            XCTAssertMatch(sourceContents, .contains("struct MyCommandPlugin: CommandPlugin"))
        }
    }
    
    func testInitPackageBuildToolPlugin() throws {
        try testWithTemporaryDirectory { tmpPath in
            let fs = localFileSystem
            let path = tmpPath.appending("MyBuildToolPlugin")
            let name = path.basename
            try fs.createDirectory(path)

            // Create the package
            try InitPackage(
                name: name,
                packageType: .buildToolPlugin,
                destinationPath: path,
                fileSystem: localFileSystem
            ).writePackageStructure()

            // Verify basic file system content that we expect in the package
            let manifest = path.appending("Package.swift")
            XCTAssertFileExists(manifest)
            let manifestContents: String = try localFileSystem.readFileContents(manifest)
            XCTAssertMatch(manifestContents, .and(.contains(".plugin("), .contains("targets: [\"MyBuildToolPlugin\"]")))
            XCTAssertMatch(manifestContents, .and(.contains(".plugin("), .contains("capability: .buildTool()")))

            let source = path.appending("Plugins", "MyBuildToolPlugin", "plugin.swift")
            XCTAssertFileExists(source)
            let sourceContents: String = try localFileSystem.readFileContents(source)
            XCTAssertMatch(sourceContents, .contains("struct MyBuildToolPlugin: BuildToolPlugin"))
        }
    }

    // MARK: Special case testing
    
    func testInitPackageNonc99Directory() throws {
        try withTemporaryDirectory(removeTreeOnDeinit: true) { tempDirPath in
            XCTAssertDirectoryExists(tempDirPath)
            
            // Create a directory with non c99name.
            let packageRoot = tempDirPath.appending("some-package")
            let packageName = packageRoot.basename
            try localFileSystem.createDirectory(packageRoot)
            XCTAssertDirectoryExists(packageRoot)
            
            // Create the package
            let initPackage = try InitPackage(
                name: packageName,
                packageType: .library,
                destinationPath: packageRoot,
                fileSystem: localFileSystem
            )
            initPackage.progressReporter = { message in }
            try initPackage.writePackageStructure()

            // Try building it.
            XCTAssertBuilds(packageRoot)
            let triple = try UserToolchain.default.triple
            XCTAssertFileExists(packageRoot.appending(components: ".build", triple.platformBuildPathComponent(), "debug", "some_package.swiftmodule"))
        }
    }
    
    func testNonC99NameExecutablePackage() throws {
        throw XCTSkip("This test fails to find XCTAssertEqual; rdar://101868275")

        try withTemporaryDirectory(removeTreeOnDeinit: true) { tempDirPath in
            XCTAssertDirectoryExists(tempDirPath)
            
            let packageRoot = tempDirPath.appending("Foo")
            try localFileSystem.createDirectory(packageRoot)
            XCTAssertDirectoryExists(packageRoot)
            
            // Create package with non c99name.
            let initPackage = try InitPackage(
                name: "package-name",
                packageType: .executable,
                destinationPath: packageRoot,
                fileSystem: localFileSystem
            )
            try initPackage.writePackageStructure()
            
            #if os(macOS)
              XCTAssertSwiftTest(packageRoot)
            #else
              XCTAssertBuilds(packageRoot)
            #endif
        }
    }

    func testPlatforms() throws {
        try withTemporaryDirectory(removeTreeOnDeinit: true) { tempDirPath in
            var options = InitPackage.InitPackageOptions(packageType: .library)
            options.platforms = [
                .init(platform: .macOS, version: PlatformVersion("10.15")),
                .init(platform: .iOS, version: PlatformVersion("12")),
                .init(platform: .watchOS, version: PlatformVersion("2.1")),
                .init(platform: .tvOS, version: PlatformVersion("999")),
            ]

            let packageRoot = tempDirPath.appending("Foo")
            try localFileSystem.removeFileTree(packageRoot)
            try localFileSystem.createDirectory(packageRoot)

            let initPackage = try InitPackage(
                name: "Foo",
                options: options,
                destinationPath: packageRoot,
                fileSystem: localFileSystem
            )
            try initPackage.writePackageStructure()

            let contents: String = try localFileSystem.readFileContents(packageRoot.appending("Package.swift"))
            XCTAssertMatch(contents, .contains(#"platforms: [.macOS(.v10_15), .iOS(.v12), .watchOS("2.1"), .tvOS("999.0")],"#))
        }
    }

    private func packageWithNameOnly(named name: String) -> String {
        return """
        let package = Package(
            name: "\(name)"
        )
        """
    }

    private func packageWithNameAndDependencies(with name: String) -> String {
        return """
let package = Package(
    name: "\(name)",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ]
)
"""
    }
}
