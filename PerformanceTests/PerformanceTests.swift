import XCTest
@testable import Papyrus


class PerformanceTests: XCTestCase
{
    private let fileManager = FileManager.default
    private var store: PapyrusStore!
    private var directory: URL!
    
    // MARK: Setup
    
    override func setUpWithError() throws
    {
        let temporaryDirectoryURL = URL(
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true
        )
        
        self.directory = temporaryDirectoryURL.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        
        self.store = PapyrusStore(url: self.directory)
        self.store.logLevel = .off
    }

    override func tearDownWithError() throws
    {
        
    }

    // MARK: Tests
    
    func testSimpleObjectWrites() throws
    {
        let objects = (0..<1000).map { _ in
            ExampleB(id: UUID().uuidString)
        }
        
        self.measure {
            let group = DispatchGroup()
            group.enter()
            
            Task {
                await self.store.save(objects: objects)
                group.leave()
            }
            
            group.wait()
        }
    }
    
    func testComplexObjectWrites() throws
    {
        let objects = (0..<1000).map { _ in
            ExampleA(
                id: UUID().uuidString,
                test: ExampleB(id: UUID().uuidString)
            )
        }
        
        self.measure {
            let group = DispatchGroup()
            group.enter()
            
            Task {
                await self.store.save(objects: objects)
                group.leave()
            }
            
            group.wait()
        }
    }
    
    func testObjectDeletion() async throws
    {
        let objects = (0..<1000).map { _ in
            ExampleB(id: UUID().uuidString)
        }
        
        await self.store.save(objects: objects)
        
        self.measure {
            let group = DispatchGroup()
            group.enter()
            
            Task {
                await self.store.delete(objects: objects)
                group.leave()
            }
            
            group.wait()
        }
    }
}
