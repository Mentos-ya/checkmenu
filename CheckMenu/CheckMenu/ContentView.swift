//
//  ContentView.swift
//  CheckMenu
//
//  Created by Ilya Yakupov on 19.08.2025.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var capturedImage: UIImage?
    @State private var cameraPermissionGranted = false
    @State private var showingImageSourceAlert = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var recognizedText = ""
    @State private var translatedText = ""
    @State private var isTranslating = false
    @State private var showTranslation = false
    
    var body: some View {
                    VStack(spacing: UIScreen.main.bounds.height < 700 ? 20 : 30) {
            Text("CheckMenu")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Сфотографируй текст для перевода")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if let image = capturedImage {
                VStack(spacing: 15) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .cornerRadius(10)
                    
                    if !recognizedText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Распознанный текст:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ScrollView {
                                Text(recognizedText)
                                    .font(.body)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: UIScreen.main.bounds.height < 700 ? 80 : 100)
                            
                            if !translatedText.isEmpty && showTranslation {
                                Text("Перевод:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ScrollView {
                                    Text(translatedText)
                                        .font(.body)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .frame(maxHeight: UIScreen.main.bounds.height < 700 ? 80 : 100)
                            }
                        }
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "camera")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Нажми кнопку для фотографирования")
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            VStack(spacing: 15) {
                Button(action: {
                    showingImageSourceAlert = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Выбрать изображение")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                if let _ = capturedImage {
                    Button(action: {
                        recognizeText()
                    }) {
                        HStack {
                            Image(systemName: "text.viewfinder")
                            Text("Распознать текст")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    
                    if !recognizedText.isEmpty {
                        Button(action: {
                            translateText()
                        }) {
                            HStack {
                                if isTranslating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "globe")
                                }
                                Text(isTranslating ? "Переводим..." : "Перевести")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }
                        .disabled(isTranslating)
                    }
                }
            }
            
            if !cameraPermissionGranted {
                Text("Разрешите доступ к камере в настройках")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(sourceType: imageSource, capturedImage: $capturedImage)
        }
        .actionSheet(isPresented: $showingImageSourceAlert) {
            ActionSheet(
                title: Text("Выберите источник"),
                message: Text("Откуда взять изображение?"),
                buttons: [
                    .default(Text("Камера")) {
                        imageSource = .camera
                        checkCameraPermission()
                    },
                    .default(Text("Библиотека фотографий")) {
                        imageSource = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .onAppear {
            checkCameraPermission()
        }
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            showingImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    cameraPermissionGranted = granted
                    if granted {
                        showingImagePicker = true
                    }
                }
            }
        case .denied, .restricted:
            cameraPermissionGranted = false
        @unknown default:
            cameraPermissionGranted = false
        }
    }
    
    func recognizeText() {
        guard let image = capturedImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            DispatchQueue.main.async {
                self.recognizedText = recognizedStrings.joined(separator: "\n")
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en", "ru", "es", "fr", "de", "it", "pt", "zh", "ja", "ko"]
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Ошибка распознавания текста: \(error)")
        }
    }
    
    func translateText() {
        guard !recognizedText.isEmpty else { return }
        
        isTranslating = true
        showTranslation = false
        
        TranslationService.shared.translateText(recognizedText) { translated in
            DispatchQueue.main.async {
                self.translatedText = translated
                self.isTranslating = false
                self.showTranslation = true
            }
        }
    }
    

}

#Preview {
    ContentView()
}
