import SwiftUI

//MongoDB synchronous swift driver
//import MongoSwiftSync

struct ContentView: View {

    private var views: [DayView] = []
    @State var showingToDoView = false
    
    //Initializer finds the 7 current dates of the week and formats them accordingly
    init() {
        let calendar = Calendar.current
        let today = Date()
        let monthDayFormatter = DateFormatter()
        let weekDayFormatter = DateFormatter()
        
        //Setting formatters
        monthDayFormatter.dateFormat = "MM/dd"
        weekDayFormatter.dateFormat = "EEEE"
        
        //Creating 7 instances of DayView views and assigning them the correct dates and formatted date strings
        for i in 0...6 {
            let date = calendar.date(byAdding: .day, value: i, to: today)
            views.append(DayView(weekDay: weekDayFormatter.string(from: date!), monthDay: monthDayFormatter.string(from: date!), date: date!))
        }  
    }

// Connecting to mongoDB atlas cluster
// MongDB doesn't support built-in cluster connections anymore so this code is no longer functional and would require a server
//
//        do {
//
//            let uri = "mongodb+srv://IOS:<CLUSTERID>@cluster.tfgazsh.mongodb.net/?retryWrites=true&w=majority"
//            let client = try MongoClient(uri)
//            let database = client.db("Database").collection("Tasks")
//            let query: BSONDocument = ["a": 1]
//            let documents = try database.find(query)
//            for d in documents {
//                print(try d.get())
//            }
//
//        } catch {
//
//        }
//        
//        //Event handler for when applications closes, used to cleanup driver resources            
//        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main) { _in
//            print("closing Application")
//
//            cleanupMongoSwift()
//            }
//        }
   
    //Content of view
    var body: some View {
        
        VStack {
        
            //Painting title
            Text("Weekly Planner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color(hue: 0.741, saturation: 1.0, brightness: 1.0))
                .padding(.top)
        
            //Creating TabView containing our 7 DayView views
            TabView() {
                views[0]
                views[1]
                views[2]
                views[3]
                views[4]
                views[5]
                views[6]
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page)
            
        }

        //Adding ToDoView as sheet that can be dragged from bottom of screen
        .sheet(isPresented: $showingToDoView) {
            ToDoView(showToDoView: $showingToDoView)
        }

        //Event handler for drag gestures, check if user dragged up (doesn't require drag to have started at bottom of screen)
        .gesture(DragGesture()
            .onEnded { value in

                //Making sure drag was long enough to avoid false drag events
                if value.location.y < value.startLocation.y - 25 {
                    showingToDoView = true
                }
            })
        .background(Color(hue: 0.814, saturation: 0.275, brightness: 0.944))
    }
}

//View preview struct for xcode built-in previews
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}