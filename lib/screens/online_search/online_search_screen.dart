import 'package:ev_dictionary/screens/offline_search/components/switch_button.dart';
import 'package:flutter/material.dart';
import 'package:ev_dictionary/screens/definition/components/shared_appbar.dart';
import 'package:ev_dictionary/utilities/constaints.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
// import 'package:translator/translator.dart';

class OnlineSearchScreen extends StatefulWidget {
  @override
  _OnlineSearchScreenState createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends State<OnlineSearchScreen> {
  Translate translateType = Translate.av;
  String output = '';
  late String input;

  var _controller = TextEditingController();

  // final translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();

  Future<void> _speak() async {
    if (translateType == Translate.av) {
      await flutterTts.setLanguage('en-US');
    } else if (translateType == Translate.va) {
      await flutterTts.setLanguage('vi-VN');
    }

    await flutterTts.setSpeechRate(0.8);
    await flutterTts.speak(input);
  }

  void _changeTranslateType() {
    setState(() {
      // set all text to default
      _controller.text = '';
      input = '';
      output = '';

      // change type
      if (translateType == Translate.av) {
        translateType = Translate.va;
      } else {
        translateType = Translate.av;
      }
    });
  }

  void _onSubmitted(String value) async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      setState(() {
        output = 'You\'re offline';
      });
      return;
    }
    String sourceLang;
    String targetLang;

    if (translateType == Translate.av) {
      sourceLang = 'en';
      targetLang = 'vi';
    } else {
      sourceLang = 'vi';
      targetLang = 'en';
    }

    // http.Response response = await http.get(
    //     'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=$value');
    http.Response response = await http.get(Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLang&tl=$targetLang&dt=t&q=$value'));

    setState(() {
      if (response.statusCode == 200) {
        if (value.length > 0) {
          List temp = response.body.split('\n')[0].split('\"');

          output = temp[1];
        }
      } else {
        output = 'Response status error code: ${response.statusCode} :(';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // To make keyboard doesn't pop up when open this screen
    Future.delayed(const Duration(),
        () => SystemChannels.textInput.invokeMethod('TextInput.hide'));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(size.height * 0.1),
        child: SharedAppBar(
          size: size,
          title: 'Online Search',
          backgroundColor: kEnglishAppbarColor,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              child: TextField(
                controller: _controller,
                autofocus: false,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  // enabledBorder to make set color for border when unfocus
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  labelText: translateType == Translate.av
                      ? 'English - Vietnamese'
                      : 'Vietnamese - English',
                  hintText: "Tap to enter text",
                  fillColor: kBackgroundCardColor,
                  filled: true,
                ),
                style: const TextStyle(
                  fontSize: 22,
                ),

                // Google limit request, so after a few minutes
                // the translator stop working if use onChanged

                // I've try another way using response but google still blocks onChanged function
                // So this app can only use onSubmitted with limited requests
                // https://daynhauhoc.com/t/xin-file-json-key-co-chua-google-translate-api/76506/11
                onSubmitted: _onSubmitted,

                onChanged: (value) {
                  input = value.trim();
                },
              ),
            ),
            SwitchButton(
              color: Colors.blue,
              onPressed: _changeTranslateType,
            ),
            // Wrap by Flexible remove A RenderFlex overflowed by ...
            // And I can add width: double.infinity, height: double.infinity to
            // Container without error :)
            Flexible(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 35, 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue, width: 2),
                      color: kBackgroundCardColor,
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        output,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -20,
                    child: RawMaterialButton(
                      onPressed: () {
                        _speak();
                      },
                      elevation: 1.0,
                      fillColor: Colors.white,
                      child: const Icon(
                        Icons.volume_up,
                        size: 20.0,
                      ),
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
