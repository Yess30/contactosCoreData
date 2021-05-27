

import UIKit
import CoreData

class EditarViewController: UIViewController {
    
    var contactos = [Contacto]()
    
    //Conexion al contexto de la base de datos
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var recibirNombre: String?
    var recibirTelefono: Int64?
    var recibirDireccion: String?
    var indice: Int?

    @IBOutlet weak var ImagenPerfil: UIImageView!
    @IBOutlet weak var nombreTF: UITextField!
    @IBOutlet weak var telefonoTF: UITextField!
    @IBOutlet weak var direccionTF: UITextField!
    @IBOutlet weak var correoTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cargarCoreData()
        
        correoTF.text = contactos[indice!].correo
        ImagenPerfil.image = UIImage(data: contactos[indice!].imagen!)
        nombreTF.text = recibirNombre
        telefonoTF.text = "\(String(describing: recibirTelefono!))"
        telefonoTF.keyboardType = .numberPad
        direccionTF.text = recibirDireccion
        
        let gestura = UITapGestureRecognizer(target: self, action: #selector(clickImagen))
        gestura.numberOfTapsRequired = 1
        gestura.numberOfTouchesRequired	 = 1
        
        ImagenPerfil.addGestureRecognizer(gestura)
        ImagenPerfil.isUserInteractionEnabled = true
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func clickImagen(gestura: UITapGestureRecognizer){
        print("Cambiar imagen")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
  
    
    @IBAction func fotoButton(_ sender: UIBarButtonItem) {
    
        print("Cambiar imagen")
        let vc = UIImagePickerController()
        vc.sourceType = .savedPhotosAlbum
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
        
    }
    
    
    @IBAction func GuardarButton(_ sender: UIButton) {
        do {
            self.contactos[indice!].setValue(nombreTF.text, forKey: "nombre")
            self.contactos[indice!].setValue(Int64(telefonoTF.text!), forKey: "telefono")
            self.contactos[indice!].setValue(direccionTF.text, forKey: "direccion")
            self.contactos[indice!].setValue(ImagenPerfil.image?.pngData(), forKey: "imagen")
            self.contactos[indice!].setValue(correoTF.text, forKey: "correo")
            
            
            try self.contexto.save()
            print("se actualizo el contexto")
        } catch {
            print("Error al actualizar: \(error.localizedDescription)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func cancelarButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
// protocolo para la gestura de la imagen y seleccionar imagen

extension EditarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imagenSelec = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            ImagenPerfil.image = imagenSelec
            
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
