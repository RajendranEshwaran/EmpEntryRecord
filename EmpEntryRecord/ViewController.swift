//
//  ViewController.swift
//  EmpEntryRecord
//
//  Created by Rajendran Eshwaran on 12/9/19.
//  Copyright © 2019 Rajendran Eshwaran. All rights reserved.
//

import UIKit
import CoreData

struct EmpDetails {
    var name:String
    var phoneNumber : String
}

class ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    
    @IBOutlet weak var empEntryTable: UITableView!
    var name:String?
    var phone:String?
    
   // var empdetail = [EmpDetails(name: "Rajay", phoneNumber: "4343434")]
    
    var EmpArray = [EmpDetails]()
    

    @IBAction func addEmpArriaval(_ sender: Any) {
        
       let alert = UIAlertController(title: "Emp Detail", message: "Enter Name & PhoneNumber", preferredStyle: .alert)
        
        // Add button
        let addDetailAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let usernameTxt = alert.textFields![0]
            let passwordTxt = alert.textFields![1]
            //Asign textfileds text to our global varibles"
            self.name = usernameTxt.text
            self.phone = passwordTxt.text

            print("name \(String(describing: self.name))\n phone\(String(describing: self.phone))")
                        
            self.EmpArray.append(EmpDetails(name: self.name!, phoneNumber: self.phone!))
            
            self.empEntryTable.reloadData()
            
            self.saveRecordToCoreData()
        })

        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })

        //1 textField for EmpName
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter username"
            //If required mention keyboard type, delegates, text sixe and font etc...
            //EX:
            textField.keyboardType = .default
        }

        //2nd textField for PhoneNumber
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter PhoneNumber"
            textField.isSecureTextEntry = false
        
        }

        // Add actions
        alert.addAction(addDetailAction)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        empEntryTable.delegate = self
        empEntryTable.dataSource = self
        // Do any additional setup after loading the view.
        
        
        getRecordFromCoreData()
    }
    
    func saveRecordToCoreData()
    {
        //Step 1: // Container is set up in the AppDelegates so we need to refer that container.
            guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
            //Step 2: Create context from persistent container
            let context = appdelegate.persistentContainer.viewContext
            
            // Step 3: Create entity
        guard let entityName = NSEntityDescription.entity(forEntityName: "EmpRegister", in: context) else{return}
        
        // Step 4: Assign the value to entity and its attributes
        let empManagedObject = NSManagedObject(entity: entityName, insertInto: context)
            
        empManagedObject.setValue(self.name, forKey: "name")
        empManagedObject.setValue(self.phone, forKey: "phone")
        
        // Step 5: Save data in to coredata
        do{
            try context.save()
        }catch let error as NSError{
            print("Error in Data Save \(error)")
        }
    }
    
    func getRecordFromCoreData()
    {
        // Step 1: Setting the appdelegate persistant container
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        // Step 2: Create context from container
        let context = appdelegate.persistentContainer.viewContext
        
        // Step 3: Create the fetch request for the entity
        let fetchRequest = NSFetchRequest <NSFetchRequestResult>(entityName: "EmpRegister")
        
        // Step 4: Get the by fetch request from context
        do{
            let  result = try context.fetch(fetchRequest)
            for data in result as![NSManagedObject]
            {
                print(data.value(forKey: "name") as! String);
                print(data.value(forKey: "phone") as! String);
                let _name = data.value(forKey: "name")
                let _phone = data.value(forKey: "phone")
                EmpArray.append(EmpDetails(name: _name as! String, phoneNumber: _phone as! String))
            }
        }
            catch {
                print("Failed to Get")
            }
    }
    
    
    func deleteRecordFromCoreData(index :Int,name:String)
    {
        // Step 1: Set appdelegate persistant container
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        // Step 2: Create a context from the persistant contaier
        let context = appdelegate.persistentContainer.viewContext
        
        // Step 3: Create Fetch request to fetch value
        let fetchReq = NSFetchRequest <NSFetchRequestResult> (entityName: "EmpRegister")
        
        // Step 4: Predicate value by fetch request
        fetchReq.predicate = NSPredicate(format: "name == %d", name)
        
        do{
            
            let data = try context.fetch(fetchReq)
           for object in data {
            context.delete(object as! NSManagedObject)
            }
            
            do{
                try context.save()
            }catch{
                print("Save Eror!!")
            }
        }
        catch{
            print("Delete error!!")
        }
    }
    
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EmpArray.count
      }
      
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        let empdet = EmpArray[indexPath.row]
        cell.nameLbl.text = "Emp_Name :" + empdet.name
        cell.phoneLbl.text = "Mob_Number:" + empdet.phoneNumber
        return cell
        
      }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if(editingStyle == .delete)
        {
            let empdet = EmpArray[indexPath.row]
            let tempName = empdet.name
            print(tempName)
            EmpArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .middle)
            tableView.endUpdates()
            
            deleteRecordFromCoreData(index: indexPath.row,name: tempName)
        }
    }
      
}

