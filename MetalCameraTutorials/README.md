# Metal Camera Tutorial

## What is AVCaptureSession?
*AVCaptureSession* is a class in *AVFoundation* framework
<br>*AVCaptureSession* object to coordinate the flow of data from audio or video input devices to outputs

## These Project work flow
- **Initialise session** : Session being actual AVCaptureSession Instance
- **Request access to hardware** : Get a *AVCaptureDevice* instance<br>This instance represents a single hardware piece
- **Add input to session** : Input is a *AVCaptureDeviceInput* instance initialised with *AVCaptureDevice*
- **Add output to session** : *AVCaptureVideoDataOutput* instance that need to configure with the format you wantt your data in
- **Start the session** : Data will be streaming

## Get frame data
- **CMSampleBuffer** : A Core Foundation object representing a generic container for media data
- **CVImageBuffer** : CVImageBuffer being a more specific container for image data