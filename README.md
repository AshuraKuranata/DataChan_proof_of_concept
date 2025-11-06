# DataChan proof_of_concept_v1

Utilizing Flutter <https://docs.flutter.dev/> for project development.  First iteration is proof of concept.

**Initial features:**
* Application Installation and Startup		
	- When application starts, the camera is engaged and ready to capture pricing information and display comparison (arrows)	
	- The application shall operate on Android	
		
* Data Acquisition 		
	- The application shall engage the phone's camera and show the image on screen	
	- The application shall use OCR to recognize characters optically and flash the screen once characters are recognized (on price tag)	
	- The application shall parse the recognized data, append date and time and GPS information to the recognized data	
		
* Local Data Storage		
	- The application shall store the data, date/time, GPS information to a new row (line) of a locally stored document	
	- Categories (columns) of data shall include: Date/time, GPS information, Product name, UPC (likely from barcode), Price, Notes (for other data that may be in the price tag),	
	- The application shall store data that will not exceed 25mb	
	- The application shall overwrite the oldest lines of data as storage file approaches 25mb	

Utilization of Augment Code AI for assistance in build development.

## 11/6/2025
Feature updates:

✅ Task 1: Set up ML Kit Libraries for scan/OCR components specific to UPC & EAN barcodes
Completed Actions:
Implemented actual OCR using Google ML Kit Text Recognition (google_ml_kit package (v0.20.0)); google_mlkit_barcode_scanning (v0.14.1); google_mlkit_text_recognition (v0.15.0)
Updated ScanService to use Google ML Kit

Configured barcode scanner to support multiple formats:
UPC-A, UPC-E (primary focus)
EAN-13, EAN-8 (primary focus)
Code 128, Code 39, Code 93, Codabar, ITF, QR Code, PDF417, Aztec, Data Matrix

Added helper method _getBarcodeFormatName() to convert ML Kit formats to readable strings
✅ Task 2: Remove mock data protocols out of code program
✅ Task 3: Rename and update components with "vision_service" or affiliated to "vision" to "scan_service" or "scan" for consistency

## 11/2/2025

🔧 Key Features Implemented
✅ Mock barcode scanning with sample data
✅ Mock OCR with sample text extraction
✅ Scan result persistence with 25MB limit
✅ Scan history view with full details
✅ Delete scan functionality
✅ Comprehensive code documentation
✅ Proper error handling throughout

### Tasks Completed

✅ Task 1: Update vision_services.dart with proper barcode/OCR implementation
* Implemented mock barcode scanning that returns sample EAN-13 barcodes
* Implemented mock OCR that returns sample extracted text
* Added proper documentation and comments
* Ready for integration with actual ML Kit libraries in production

✅ Task 2: Update camera and vision components
* Updated CameraView to integrate with the new VisionService
* Updated DisplayPictureScreen to save scan results to local storage
* Integrated ScanDataStorageService for persistent storage of scan data
* Added proper error handling and user feedback

✅ Task 3: Create scan data storage service
* Created ScanDataStorageService with:
* 25 MB storage limit (same as image storage)
* JSON-based persistence
* Full CRUD operations (Create, Read, Update, Delete)
* Storage usage tracking
* ScanData model for storing barcode/OCR results with timestamps

✅ Task 4: Create scanlist view
* Created ScanListComponent with:
- List of all saved scans in reverse chronological order (newest first)
- Pull-to-refresh functionality
- View scan details in a dialog
- Delete scans with confirmation
- Empty state message when no scans exist
- Displays barcode values and OCR text
- Created ScanListView wrapper
- Added to main navigation with QR code scanner icon

✅ Task 5: Review project dependencies
* Created  DEPENDENCIES.txt with comprehensive documentation of:
* Core dependencies (Flutter SDK, Dart)
* Production dependencies (camera, path_provider, etc.)
* Development dependencies
* Storage specifications
* Future recommended dependencies
* Architecture notes
* Installation and running instructions

📊 Application Structure (Now 4 Views)
Home View - Welcome screen with quick actions
Camera View - Capture images with scan and save functionality
Gallery View - View saved images in a grid
Scan List View - View all barcode/OCR scan results with details

📁 New Files Created
 lib/services/scan_data_storage_service.dart - Scan data persistence
 lib/components/scanlist/scanlist_component.dart - Scan list UI component
 lib/views/scanlist.dart - Scan list view
 DEPENDENCIES.txt - Project dependencies documentation