import UIKit
import CoreData

class CoreDataManager: NSObject {
    
    static let sharedInstance = CoreDataManager()
    
    func appDelegate()->AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        return self.appDelegate().persistentContainer.viewContext
    }
    
    func createNewSearchRecord(title: String) -> SearchHistory {
            let newRecord = SearchHistory(context: managedObjectContext())
            newRecord.title = title
            return newRecord
    }
    
    func saveContext() {
        do{
            try self.managedObjectContext().save()
        } catch {
            print(error)
        }
    }
    func fetchSearchRecords() -> [SearchHistory]? {
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        do {
            let recordArray = try managedObjectContext().fetch(request)
            return recordArray
        } catch {
            print(error)
            return nil
        }
    }
    
    func delete(_ item: NSManagedObject) {
        managedObjectContext().delete(item)
        if managedObjectContext().hasChanges {
            do {
                try managedObjectContext().save()
            } catch {
                managedObjectContext().rollback()
            }
        }
    }
}
