import 'dart:convert';
import 'package:advanced_audio_manager/advanced_audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

class voice_generation with ChangeNotifier {



  Future generate(api_key,voice_id,model,text) async {
    final player = AudioPlayer();
    final response = await http.post(
      Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/${voice_id}/stream'),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': api_key,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "model_id": model,
        "voice_settings": {"stability": .15, "similarity_boost": .75}
      }),
    );
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      api_key_is_wrong = true;
      notifyListeners();
    }
  }
  List<DropdownMenuItem> dropdown_list_models = [];
  List<DropdownMenuItem> dropdown_list_voices= [];
  bool api_key_is_wrong = false;
  Future get_models(context,api_key) async {
    dropdown_list_models = [];
    dropdown_list_voices = [];
    final response_models = await http.get(Uri.parse('https://api.elevenlabs.io/v1/models'),headers: {'xi-api-key': api_key});
    if (response_models.statusCode == 200) {
      var json_models = jsonDecode(response_models.body);
      for (var x in json_models) {
        dropdown_list_models.add(
          DropdownMenuItem(
            value: x['model_id'],
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(PhosphorIcons.microphone()),
                ),
                Text("${x['name']}",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.015),textAlign: TextAlign.left),
              ],
            ),
          )
        );
      }

      final response_voices = await http.get(Uri.parse('https://api.elevenlabs.io/v1/voices'),headers: {'xi-api-key': api_key});
      var json_voices = jsonDecode(response_voices.body);
      for (var x in json_voices["voices"]) {
        dropdown_list_voices.add(
            DropdownMenuItem(
              value: x['voice_id'],
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(PhosphorIcons.user()),
                  ),
                  Text("${x['name']}",style: TextStyle(fontFamily: "Roboto",fontWeight: FontWeight.w700,fontSize: MediaQuery.of(context).size.width * 0.015),textAlign: TextAlign.left),
                ],
              ),
            )
        );
      }
    } else {
      api_key_is_wrong = true;
    }
    notifyListeners();
  }



}