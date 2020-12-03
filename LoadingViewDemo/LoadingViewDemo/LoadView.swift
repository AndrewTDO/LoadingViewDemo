//
//  LoadView.swift
//  LoadingViewDemo
//
//  Created by Andrew Kovalenko on 03.12.2020.
//

import SwiftUI

typealias TaskCompletion = () -> Void

enum TaskStatus {
    case None
    case Fail
    case Success
}

protocol TaskProtocol {
    var id: Int { get }
    var status: TaskStatus { get }
    var children: [TaskProtocol] { get }
    var parentId: Int? { get set }
    
    func add(children: [TaskProtocol])
    func perform(completion: @escaping TaskCompletion)
}

class Task: TaskProtocol {
    
    var id: Int
    var status: TaskStatus = .None
    var children: [TaskProtocol]
    var parentId: Int?
    // Test value
    var testSuccess: Bool = arc4random_uniform(2) == 0
    
    init(id: Int) {
        self.id = id
        self.children = [TaskProtocol]()
    }
    
    func add(children: [TaskProtocol]) {
        for var item in children {
            item.parentId = id
            if !self.children.contains(where: { $0.id == item.id } ) {
                self.children.append(item)
            }
        }
    }
    
    func perform(completion: @escaping TaskCompletion) {
        
        // Test async operation
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(arc4random_uniform(10))) {
            
            if !self.children.isEmpty { // Parent task
                
                // Run children tasks aftr parent finished
                let group = DispatchGroup()
                for child in self.children {
                    group.enter()
                    child.perform {
                        group.leave()
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                    self.complete(success: self.testSuccess, completion: completion)
                }
            } else { // Child tast
                self.complete(success: self.testSuccess, completion: completion)
            }
        }
    }
    
    // Handle task completion
    private func complete(success: Bool, completion: @escaping TaskCompletion) {
        self.status = success ? .Success : .Fail
        completion()
    }
    
}

struct LoadView: View {
    
    @State var performingTasks = 0
    @State var showAlert = false
    @State var failedTasks = [TaskProtocol]()
    @State var loading = false
    
    var body: some View {
        VStack {
            
            ProgressView(loading ? "Performing tasks..." : "", value: Double(self.performingTasks), total: Double(self.testTasks().count))
                .padding(20)
            
            Button(action: {
                loading = true
                self.start(tasks: self.testTasks())
            }) {
                if loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Start performing")
                }
            }
            .disabled(self.loading)
            .alert(isPresented: $showAlert) {
                self.alertForTasks()
            }
        }
    }
    
    func alertForTasks() -> Alert {
        if self.failedTasks.count != 0 {
            var message = "Some tasks didn't complete successfully"
            
            if self.failedTasks.count == 1 {
                message = "Tasks with id: \(self.failedTasks[0].id) didn't complete successfully"
            }
            return Alert(title: Text("Failed!"),
                         message: Text(message),
                         primaryButton: .default(Text("Retry"), action: {
                            self.retryFailedTask()
                         }),
                         secondaryButton: .default(Text("Cancel"), action: {
                            self.loading = false
                         }))
        } else {
            return Alert(title: Text("Done!"),
                         message: Text("All tasks completed successfully"),
                         dismissButton: .default(Text("OK"), action: {
                            self.loading = false
                         }))
        }
    }
    
    func start(tasks: [TaskProtocol]) {
        
        let group = DispatchGroup()
        
        for task in tasks {
            
            var shouldPerform = true
            // Checking if has parent task
            if let parentId = task.parentId, let _ = tasks.filter({ $0.id == parentId }).first {
                shouldPerform = false
            }
            if shouldPerform {
                group.enter()
                task.perform {
                    // Update progress
                    performingTasks = tasks.filter({ $0.status != .None }).count
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            //Reset performingTasks count for ProgressView
            performingTasks = 0
            
            // Find failed tasks
            failedTasks = tasks.filter({$0.status == .Fail})
            
            self.showAlert = true
        }
    }
    
    private func retryFailedTask() {
        for failedTask in self.failedTasks {
            if let task = failedTask as? Task {
                // Reset status
                task.status = .None
                // Setting test value to true so all are finished successfully
                task.testSuccess = true
            }
        }
        self.start(tasks: failedTasks)
    }
    
    private func testTasks() -> [TaskProtocol] {
        // Setting totalValue for ProgressView from failedTasks count
        if failedTasks.count > 0 {
            return failedTasks
        }
        // Mock data for testing
        let task1 = Task.init(id: 0)
        let task2 = Task.init(id: 1)
        let task3 = Task.init(id: 2)
        let task4 = Task.init(id: 3)
        let task5 = Task.init(id: 4)
        let task6 = Task.init(id: 5)
        let task7 = Task.init(id: 6)
        let task8 = Task.init(id: 7)
        task2.add(children: [task1, task3])
        task3.testSuccess = true
        return [task1, task2, task3, task4, task5, task6, task7, task8]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoadView()
    }
}
