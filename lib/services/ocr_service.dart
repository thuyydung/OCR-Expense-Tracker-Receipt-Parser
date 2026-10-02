import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'heuristic_regex_parser.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ParsedReceipt> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return HeuristicRegexParser.parse(recognizedText.text);
  }

  void dispose() {
    _textRecognizer.close();
  }
}