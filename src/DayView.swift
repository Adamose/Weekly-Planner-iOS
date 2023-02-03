import SwiftUI
import Foundation

//This is the that each individual date has, there are 7 instances of this view loaded at one time
struct DayView: View {

    let weekDay: String
    let monthDay: String
    let date: Date
    let calendar = Calendar.current
    @State private var newTask: String = ""
    @State private var selectedId: UUID? = nil

    //State booleans
    @State private var showNewTask: Bool = false
    @FocusState private var focus: Bool

    //Loading storage and fectching tasks
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var tasks: FetchedResults<Task>
    
    //Initializer assigned date components
    init(weekDay: String, monthDay: String, date: Date) {
        self.weekDay = weekDay
        self.monthDay = monthDay
        self.date = date
    }
    
    //Content of view
    var body: some View {
        
        VStack {

            //Painting title of view
            Text(weekDay)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color.purple)
                .padding(.top)

                //Event handler for tap gesture on title (moves task to task to-do view)
                .onTapGesture {

                    //Makes sure their is a selected task to move
                    if selectedId != nil {

                        //Finding task to move
                        for task in tasks {
                            if task.id == selectedId {

                                //Updating task's date variable to move it
                                task.date = nil
                                selectedId = nil

                                //Saving changes to storage
                                try? moc.save()
                                break
                            }
                        }
                    }
                }
            
            //Horizontal stack containing two buttons and month
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
                                break
                            }
                        }
                    }

                //Label is a - sign    
                } label: {
                    Text("-")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hue: 0.741, saturation: 1.0, brightness: 1.0))
                }
                
                //Painting month
                Text(monthDay)
                    .font(.headline)
                    .padding(.horizontal, 85.0)
                

                //Add task button
                Button() {

                    //Counting how many task current date has
                    var count: Int = 0
                    for task in tasks {
                        if task.date != nil && calendar.isDate(task.date!, inSameDayAs: date) {
                            count += 1
                        }
                    }
                    
                    //Makes sure date has less than 12 tasks
                    if count < 12 && !showNewTask {
                        newTask = ""
                        showNewTask = true
                    }

                //Label is a + sign    
                } label: {
                    Text("+")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hue: 0.741, saturation: 1.0, brightness: 1.0))
                }
            }
            
            //Checking if there is a task being added
            if showNewTask {
                
                HStack {
                    
                    //Painting bullet point
                    Circle()
                        .frame(width: 10.0, height: 10.0)
                        .foregroundColor(Color(hue: 0.741, saturation: 1.0, brightness: 1.0))
                    
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
            
            //Looping through all tasks in storage
            ForEach(tasks) { task in
                 
                //Painting task if it's date is the same as current view's date
                if task.date != nil && calendar.isDate(task.date!, inSameDayAs: date) {
                    
                    HStack {
                        
                        //Checking if current task is selected, if so paint it's bullet point red
                        if task.id == selectedId {
                            Circle()
                                .frame(width: 10.0, height: 10.0)
                                .foregroundColor(Color.red)
                            
                        } else {
                            Circle()
                                .frame(width: 10.0, height: 10.0)
                                .foregroundColor(Color(hue: 0.741, saturation: 1.0, brightness: 1.0))
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
        .contentShape(Rectangle())

        //Event handler for when user presses empty space on view
        .onTapGesture {

            //Unselecting task if one was selected
            selectedId = nil
        }
    }
    
    //Function to add a task (creates task with view's date as assigned date)
    func addTask() {
        
        //Setting showNewTask to off since task is getting offically added
        showNewTask = false

        //Adding task to storage
        let task = Task(context: moc)
        task.content = newTask
        task.id = UUID()
        task.date = date

        //Save change to storage
        try? moc.save()
    }
}