//
//  ContentView.swift
//  SwiftDataExample
//
//  Created by J_Min on 2023/06/06.
//

import SwiftUI
import SwiftData

@Model
class TodoItem {
    let id: UUID
    
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool, createdAt: Date) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \.title, order: .forward, animation: .default) var allTodoItems: [TodoItem]
    
    var body: some View {
        VStack {
            CreateTodoItemView()
                .padding(.horizontal, 16)
            
            List {
                ForEach(allTodoItems) { todo in
                    HStack {
                        VStack (alignment: .leading) {
                            Text(todo.title)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        context.delete(todo)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                            
                            Text(todo.createdAt.toString())
                        }
                        
                        Spacer()
                        
                        Button {
                            todo.isCompleted.toggle()
                        } label: {
                            Circle()
                                .fill(todo.isCompleted ? .blue : .clear)
                                .stroke(Color(uiColor: .lightGray), lineWidth: 1)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
    }
}

struct CreateTodoItemView: View {
    
    @Environment(\.modelContext) private var context
    
    @State var todoTitle: String = ""
    @State var isCompleted: Bool = false
    
    var body: some View {
        
        VStack {
            TextField(text: $todoTitle) {
                Text("title...")
            }
            .textFieldStyle(.roundedBorder)
        }
        
        HStack {
            Toggle("isCompleted", isOn: $isCompleted)
                .toggleStyle(.button)
            
            Button {
                saveTodoItem()
                clear()
            } label: {
                Text("save")
            }
            .padding(.leading)
        }
        .padding(.top, 8)
    }
    
    func saveTodoItem() {
        let todo = TodoItem(title: todoTitle, isCompleted: isCompleted, createdAt: Date())
        context.insert(todo)
    }
    
    func clear() {
        todoTitle = ""
        isCompleted = false
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.mm.dd"
        
        return formatter.string(from: self)
    }
}
