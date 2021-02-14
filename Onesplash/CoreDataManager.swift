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
    
    func createFilterAttributes(title: String, state: Bool) -> FilterAttributes {
        let attr = FilterAttributes(context: managedObjectContext())
        attr.title = title
        attr.state = state
        return attr
    }
    
    func saveContext() {
        do{
            try self.managedObjectContext().save()
        } catch {
            print(error)
        }
    }
    func fetchSearchRecords<T: NSManagedObject>(type: T.Type) -> [T]? {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
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
