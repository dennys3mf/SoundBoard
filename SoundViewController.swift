//
//  SoundViewController.swift
//  SoundBar
//
//  Created by Gabriel Marquez on 4/11/23.
//

import UIKit
import AVFoundation
import CoreData

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!

    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?

    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // detener la grabación
            grabarAudio?.stop()
            // cambiar texto del botón grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // empezar a grabar
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                grabarAudio?.record()
                // cambiar el texto del botón grabar a detener
                grabarButton.setTitle("DETENER", for: .normal)
                reproducirButton.isEnabled = false
            } catch {
                print("Error al iniciar la grabación")
            }
        }
    }

    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.play()
            print("Reproduciendo")
        } catch {
            print("Error al reproducir el audio")
        }
    }

    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        do {
            grabacion.audio = try Data(contentsOf: audioURL!)
        } catch {
            print("Error al agregar el audio")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }

    func configurarGrabacion() {
        do {
            // Creando sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // Creando la dirección para el archivo de audio
            let basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // Impresión de la ruta donde se guardan los archivos
            print("*****************")
            print(audioURL!)
            print("*****************")

            // Crear opciones para el grabador de audio
            var settings: [String: Any] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            settings[AVSampleRateKey] = 44100.0
            settings[AVNumberOfChannelsKey] = 2

            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio?.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
}
