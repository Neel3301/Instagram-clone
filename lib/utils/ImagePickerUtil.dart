import 'package:image_picker/image_picker.dart';

//log
import 'dart:developer' as devtools show log;

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  } else {
    devtools.log('No Image Selected');
  }
}
