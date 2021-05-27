//
//  ViewController.swift
//  contactosCoreData
//
//  Created by Mac19 on 06/05/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var nombreEnviar: String?
    var telEnviar: Int64?
    var direccionEnviar: String?
    var indiceEnviar: Int?
    
    
    var contactos = [Contacto]()
    
    //Conexion al contexto de la base de datos
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tablaContactos: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Leer los datos de la base de datos de coreData
        cargarCoreData()
        tablaContactos.reloadData()
        
        
        
        tablaContactos.register(UINib(nibName: "ContactoTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
                                
        tablaContactos.delegate = self
        tablaContactos.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Aparecio la vista")
        tablaContactos.reloadData()
    }


    @IBAction func agregarContB(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Agregar", message: "Nuevo contacto", preferredStyle: .alert)
        
        let accionAceptar = UIAlertAction(title: "Agregar", style: .default) { (_) in
            
            
             
            guard let nombreAlert = alerta.textFields?.first?.text else
            { return }
            guard let telefonoAlert = Int64(alerta.textFields?[1].text ?? "0000000000") else
            { return }
            guard let direccionAlert = alerta.textFields?[2].text else
            {return}
            guard let correoAlert = alerta.textFields?.last?.text else
            {return}
            
            
            
            let imagenTemporal = UIImageView(image: #imageLiteral(resourceName: "contacto"))
            //Crear el obj para guardar un coredata
            
            let nuevoContacto = Contacto(context: self.contexto)
            nuevoContacto.nombre = nombreAlert
            nuevoContacto.telefono = telefonoAlert
            nuevoContacto.direccion = direccionAlert
            nuevoContacto.imagen = imagenTemporal.image!.pngData()
            nuevoContacto.correo = correoAlert

            self.contactos.append(nuevoContacto)
            self.guardarContacto()
            self.tablaContactos.reloadData()
            
            print(self.contactos)
            
        }
        alerta.addTextField { (nombreTF) in
            nombreTF.placeholder = "Nombre"
            nombreTF.autocapitalizationType = .words
        }
        
        alerta.addTextField { (telefonoTF) in
            telefonoTF.placeholder = "Telefono"
            telefonoTF.keyboardType = .numberPad
        }
        
        alerta.addTextField { (direccionTF) in
            direccionTF.placeholder = "DIreccion"
        }
        alerta.addTextField {(correoTF) in
            correoTF.placeholder = "Correo"
        }
        
        
        alerta.addAction(accionAceptar)
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true)
    }
    
    //guardar
    func guardarContacto(){
        do {
            try contexto.save()
            print("Se guardo el contexto")
        } catch let error as NSError {
            print("Error al guardar:\(error.localizedDescription)")
        }
    }
    //leer
    func cargarCoreData(){
        let fetchRequest: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        do {
            contactos = try contexto.fetch(fetchRequest)
        } catch {
            print("Error al cargar datos de core data \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
        let celda = tablaContactos.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactoTableViewCell
        
        celda.nombreLabel.text = contactos[indexPath.row].nombre
        celda.telefonoLabel.text = "📞\(contactos[indexPath.row].telefono )"
        celda.contactoImage.image = UIImage(data: contactos[indexPath.row].imagen!)
        return celda
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tablaContactos.deselectRow(at: indexPath, animated: true)
        nombreEnviar = contactos[indexPath.row].nombre
        telEnviar = contactos[indexPath.row].telefono
        direccionEnviar = contactos[indexPath.row].direccion
        indiceEnviar = indexPath.row
        performSegue(withIdentifier: "editarContacto", sender: self)
    }
    
    //Metodos swipeActions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionBorrar = UIContextualAction(style: .normal, title:"") { (_, _, _) in
            print("Borrar")
            //eliminar de coredata
            self.contexto.delete(self.contactos[indexPath.row])
            //eliminar de la interfz
            self.contactos.remove(at: indexPath.row)
            self.guardarContacto()
            self.tablaContactos.reloadData()
        }
        accionBorrar.image = UIImage(named: "borrar.png")
        accionBorrar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionBorrar])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionllamada = UIContextualAction(style: .normal, title: "") { (_, _, _) in
            print("Relizar llamada")
            guard let telefono = self.contactos[indexPath.row].value(forKey: "telefono") else { return }
            print("Llamando al nuemro: \(telefono)")
            
            if let phoneCallURL = URL(string: "TEL://+52\(telefono)") {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
        }
        accionllamada.image = UIImage(named: "telefono.png")
        accionllamada.backgroundColor = .green
        
        let accionMensaje = UIContextualAction(style: .normal, title: "") { (_, _, _) in
            print("enviar mensaje")
        }
        accionMensaje.image = UIImage(named: "mensaje.png")
        accionMensaje.backgroundColor = .cyan
        
        
        return UISwipeActionsConfiguration(actions: [accionllamada, accionMensaje])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarContacto"{
            let objEditar = segue.destination as! EditarViewController
            objEditar.recibirNombre = nombreEnviar
            objEditar.recibirTelefono = telEnviar
            objEditar.recibirDireccion = direccionEnviar
            objEditar.indice = indiceEnviar
        }
    }
}
