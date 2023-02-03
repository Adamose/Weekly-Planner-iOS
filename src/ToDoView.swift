import Foundation
import SwiftUI

//This is the view that comes in from the bottom of the screen
//It contaisn task that are not assigned to a specific day (task to-do and tasks that are overdue)
struct ToDoView: View {
    
    private let date = Calendar.current.startOfDay(for: Date())
    private let weekDayFormatter = DateFormatter()
    private var dates: [Date] = []
    @State private var selectedId: UUID? = nil
    @State private var newTask: String = ""

    //State booleans
    @State private var showAddTask: Bool  = false
    @State private var showNewTask: Bool = false
    @Binding public var showToDoView: Bool
    @FocusState private var focus: Bool

    //Loading storage and fectching tasks
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<Task>
    
    //Initializer takes a binded boolean to be used to control when to show this view
    init(showToDoView: Binding<Bool>) {
        self._showToDoView = showToDoView
        weekDayFormatter.dateFormat = "EEEE"

        //Getting the current 7 days
        for i in 0...6 {
            dates.append(Calendar.current.date(byAdding: .day, value: i, to: date)!)
        }
    }

    //Content of view
    var body: some View {

        ZStack {
            //Setting color of whole view to purple
            Color.purple.ignoresSafeArea()
        
            VStack {

                //Painting title of view
                Text("Tasks To-Do")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 30)
                    .foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))

                    //Closing view if user taps titel
                    .onTapGesture {
                        showToDoView = false
                    }
                
                //Horizontal stack containing three buttons
                HStack {
                    
                    //Delete task button
                    Button() {

                        //Makes sure there is a selected task to delete
                        if selectedId != nil {

                            //Finding the selected task
                            for task in tasks {
                                if task.id == selectedId {

                                    //Removing task from storage
                                    moc.delete(task)

                                    //Saving changes
                                    try? moc.save()
                                    selectedId = nil
                                    showAddTask = false
                                    break
                                }
                            }
                        }

                    //Label is a - sign    
                    } label: {
                        Text("-")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                    }
                    
                    //Move task button
                    Button() {

                        //Makes sure there is a selected task to move
                        if selectedId != nil {
                        showAddTask = true
                        }

                    //Label is a file drawer image    
                    } label: {
                        Image(systemName: "rectangle.stack.badge.plus.fill").foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                            .padding(.horizontal, 88)
                    }
                    
                    //Add task button
                    Button() {

                        //Makes sure there isn't already a new task being added
                        if !showNewTask {
                            newTask = ""
                            showNewTask = true
                            selectedId = nil
                            showAddTask = false
                        }

                    //Task's label is a + sign    
                    } label: {
                        Text("+")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                    }
                }
                
                //Checking if there is a task being added
                if showNewTask {
                    
                    HStack {
                        
                        //Painting bullet point
                        Circle()
                            .frame(width: 10.0, height: 10.0)
                            .foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                        
                        //Painting text field for user to enter content
                        TextField("New Task", text: $newTask)
                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .focused($focus)

                            //Giving text field focus as soon as it appears
                            .onAppear {
                                DispatchQueue.main.async {
                                    focus = true
                                }
                            }

                            //Adding task to storage when user finishes typing
                            .onSubmit {
                                addTask()
                            }
                        
                    }
                    .padding(.leading, 35.0)
                    .padding(.bottom, 10)
                }
                
                //Scrollable view to contain all tasks to-do
                ScrollView {
                
                    //Looping through all tasks in storage
                    ForEach(tasks) { task in
                        
                        //Painting task if it is a task to-do
                        if task.date == nil {
                            
                            HStack {
                                
                                //Checking if current task is selected, if so paint it's bullet point red
                                if task.id == selectedId {
                                    Circle()
                                        .frame(width: 10.0, height: 10.0)
                                        .foregroundColor(Color.red)
                                    
                                } else {
                                    Circle()
                                        .frame(width: 10.0, height: 10.0)
                                        .foregroundColor(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                                }
                                
                                //Painting task's string
                                Text(task.content ?? "Failed To Load Task")
                                        .font(.system(size: 20, weight: .semibold, design: .default))
                                
                                Spacer()
                            }
                            //Setting padding so tasks are to close to eachother
                            //Setting content shape so tap gestures are more consistent
                            .padding(.bottom, 10)
                            .contentShape(Rectangle())

                            //Event handler for when user presses task
                            .onTapGesture {

                                //Select the pressed task
                                selectedId = task.id
                            }
                        }
                    }
                    .padding(.leading, 35.0)
                    Spacer()
                } 
            }
            
            //Check if AddTask panel is unhidden
            if showAddTask {

                VStack {
                    
                    //Creating a button for each day
                    ForEach(dates, id: \.self) { day in

                        //Event handler for button
                        Button() {

                            //Find selected task
                            for task in tasks {
                                if task.id == selectedId {

                                    //Changing task's date to selected date
                                    task.date = day

                                    //Saving change to storage
                                    try? moc.save()

                                    //Unselecting task
                                    selectedId = nil

                                    //Hidding AddTask panel
                                    showAddTask = false
                                    break
                                }
                            }

                        //Making button label to be the weekday of date    
                        } label: {
                            Text(weekDayFormatter.string(from: day))
                                .foregroundColor(Color.purple)
                                .fontWeight(.medium)
                                .padding(.bottom, 5)
                        }
                    }
                    //Padding to not have dates start at top of panel
                    .padding(.top, 5)
                    
                }
                //Setting AddTask panel's background and corners
                .background(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
                .cornerRadius(15)
            }
        }

        //Event handler for when view is opened
        .onAppear {

            //Check for tasks that are over-due and unassign their date varible
            for task in tasks {
                if task.date != nil && task.date! < date {
                    task.date = nil
                }
            }
            
            //Save changes to storage
            try? moc.save()
        }

        //Event handler for when user presses empty space on view
        .onTapGesture {

            //Unselecting task if one was selected
            selectedId = nil

            //Hide AddTask panel if it was on screen
            showAddTask = false
        }
    }
    
    //Function to add a task (creates task without a assigned date)
    func addTask() {
        
        //Setting showNewTask to off since task is getting offically added
        showNewTask = false

        //Adding task to storage
        let task = Task(context: moc)
        task.content = newTask
        task.id = UUID()
        task.date = nil

        //Save change to storage
        try? moc.save() 
    }
}