//
//  ViewController.swift
//  TheContactsApp
//
//  Created by John Kouris on 10/24/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var contactsTableView: UITableView!
    var contacts: [Contact]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        fetchContacts()
    }
    
    func fetchContacts() {
        // Fetch the data from Core Data and display in the tableview
        do {
            let request = Contact.fetchRequest() as NSFetchRequest<Contact>
            
            let nameSort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [nameSort]
            
            self.contacts = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.contactsTableView.reloadData()
            }
        } catch {
            print("Error fetching people")
        }
        
    }

    @IBAction func addTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add New Contact", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        let nameTextField = ac.textFields![0]
        nameTextField.placeholder = "Enter contact name"
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // Create a contact object
            let newContact = Contact(context: self.context)
            newContact.name = nameTextField.text
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                print("Error trying to save")
            }
            
            // Refresh the data
            self.fetchContacts()
        }
        
        ac.addAction(saveAction)
        
        present(ac, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        cell.textLabel?.text = contacts?[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // identify the contact you want to remove
            let contactToRemove = self.contacts![indexPath.row]
            
            // remove the contact from core data's context
            self.context.delete(contactToRemove)
            
            // save the change
            do {
                try self.context.save()
            } catch {
                print("Error saving the deletion")
            }
            
            // get all contacts and delete the row from the table view
            self.fetchContacts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
