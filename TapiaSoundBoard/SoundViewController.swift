//
//  SoundViewController.swift
//  TapiaSoundBoard
//
//  Created by Joshua Tapia on 31/10/23.
//

import UIKit
import AVFoundation
import CoreData

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var lblTiempo: UILabel!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var startTime: Date?
    var timer: Timer?
    var tiempoTranscurrido : String = ""
    var isTimerRunning = false
    
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
            try session.setCategory(AVAudioSession.Category.playAndRecord,
                                    mode: AVAudioSession.Mode.default,
                                    options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Creando dirección para el archivo de audio
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                       .userDomainMask,
                                                                       true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            // Impresión de ruta donde se guardan los archivos
            print("*********************")
            print(audioURL!)
            print("*********************")
            
            // Crear opciones para el grabador de audio
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }

    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled  = true
            agregarButton.isEnabled = true
            print("\(startTime!) + aa \(tiempoTranscurrido)")
            stopTimer()
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled  = false
            startTimer()
        }
    }
    func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let startTime = self.startTime else { return }
            let currentTime = Date().timeIntervalSince(startTime)
            let minutes = Int(currentTime) / 60
            let seconds = Int(currentTime) % 60
            self.lblTiempo?.text = String(format: "%02d:%02d", minutes, seconds)
            self.tiempoTranscurrido = String(format: "%02d:%02d", minutes, seconds)
            print (String(format: "%02d:%02d", minutes, seconds))
        }
        isTimerRunning = true
    }

    func stopTimer() {
        
            timer?.invalidate() // Detiene el temporizador
            timer = nil
            isTimerRunning = false
        

    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
            print(sender.value)
      
            reproducirAudio?.volume = sender.value
        }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = self.tiempoTranscurrido
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
