import 'dart:html' as html;
import 'dart:js_util';
import 'dart:js' as js;
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clientwebapp/res/custom_colors.dart';
import 'package:clientwebapp/authentication/google_sign_in/utils/authentication.dart';
import 'package:clientwebapp/common/widgets/app_bar_title.dart';
import 'package:clientwebapp/authentication/google_sign_in/screens/sign_in_screen.dart';
import 'package:clientwebapp/common/screens/home_screen.dart';
import 'package:clientwebapp/common/screens/list_screen.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  @override
  SpeechScreenState createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late User _user;
  int _selectedIndex = 0;
  String text = '';
  late html.VideoElement _preview;
  late html.AudioElement _audioPreview;
  late html.MediaRecorder _recorder;
  late html.AudioElement _result;
  bool _isShow = false;
  //final RecorderStream _recorder = RecorderStream();

  bool recognizing = false;
  bool recognizeFinished = false;

  //BehaviorSubject<List<int>>? _audioStream;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToHomeScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
        user: _user,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _routeToListScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ListScreen(user: _user),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  //StreamSubscription<List<int>>? _audioStreamSubscription;

  /* void streamingRecognize() async {
    _audioStream = BehaviorSubject<List<int>>();*/
  /*_audioStreamSubscription = _recorder.audioStream.listen((event) {
      _audioStream!.add(event);
    });*/

  //await _recorder.start();

  /*setState(() {
      recognizing = true;
    });*/
  /*final serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString('assets/test_service_account.json')));
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);*/
  //final config = _getConfig();

  /*final responseStream = speechToText.streamingRecognize(
        StreamingRecognitionConfig(config: config, interimResults: true),
        _audioStream!);*/

  //var responseText = '';

  /* responseStream.listen((data) {
      final currentText =
          data.results.map((e) => e.alternatives.first.transcript).join('\n');

      if (data.results.first.isFinal) {
        responseText += '\n' + currentText;
        setState(() {
          text = responseText;
          recognizeFinished = true;
        });
      } else {
        setState(() {
          text = responseText + '\n' + currentText;
          recognizeFinished = true;
        });
      }
    }, onDone: () {
      setState(() {
        recognizing = false;
      });
    });
  }
*/

  void stopRecording() async {
    _recorder.stop();
    // await _audioStreamSubscription?.cancel();
    //await _audioStream?.close();
    setState(() {
      //recognizing = false;
    });
  }

  /* RecognitionConfig _getConfig() => RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US');*/

  @override
  void initState() {
    super.initState();
    _user = widget._user;

    //_recorder.initialize();
    //var cameraConfig = {'audio': true};
    //Future<MediaStream>? mediaStream = getUserMedia(cameraConfig);

    //print(mediaStream);

    _audioPreview = html.AudioElement()
      ..autoplay = true
      ..controls = true
      ..muted = true;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory('audioPreview', (int _) => _audioPreview);

    _result = html.AudioElement()
      ..autoplay = false
      ..controls = true;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('result', (int _) => _result);

    /*  _preview = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..width = html.window.innerWidth!
      ..height = html.window.innerHeight!;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('preview', (int _) => _preview);

    final Future<html.MediaStream?> stream = _openCamera();*/
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacement(_routeToHomeScreen());
        break;
      case 1:
        Navigator.of(context).pushReplacement(_routeToListScreen());
        break;
      case 2:
        print('signing out');
        setState(() {
          //_isSigningOut = true;
        });
        await Authentication.signOut(context: context);
        setState(() {
          //_isSigningOut = false;
        });
        if (!mounted) return;
        Navigator.of(context).pushReplacement(_routeToSignInScreen());
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.firebaseNavy,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.firebaseNavy,
        title: const AppBarTitle(
          sectionName: 'Speech',
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        mouseCursor: SystemMouseCursors.grab,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Lists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Sign Out',
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /*Text(
                'Recording Preview',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                width: 300,
                height: 200,
                color: Colors.blue,
                child: HtmlElementView(
                  key: UniqueKey(),
                  viewType: 'preview',
                ),
              ),*/
              /*if (recognizeFinished)
                _RecognizeContent(
                  text: text,
                ),*/
              Text(
                'Audio Preview',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                width: 300,
                height: 200,
                color: Colors.blue,
                child: HtmlElementView(
                  key: UniqueKey(),
                  viewType: 'audioPreview',
                ),
              ),
              Visibility(
                  visible: !_isShow,
                  child: ElevatedButton(
                      onPressed: () async {
                        final html.MediaStream? audioStream =
                            await _openAudio();

                        //late html.VideoElement result;
                        //recorder = html.MediaRecorder(audioStream!);
                        //recorder.start();
                        _recorder = html.MediaRecorder(audioStream!);
                        //recognizing;
                        //streamingRecognize;
                        _recorder.start();

                        html.Blob blob = html.Blob([], 'audio/flac');

                        /*audioStream.addEventListener(type, (event) => null)

                        audioStream.addEventListener('active', (event) {
                          print("media stream active");
                        }, true);*/

                        _recorder.addEventListener('dataavailable', (event) {
                          blob = js.JsObject.fromBrowserObject(event)['data'];
                        }, true);

                        _recorder.addEventListener('stop', (event) {
                          final url = html.Url.createObjectUrl(blob);
                          _result.src = url;

                          audioStream?.getTracks().forEach((track) {
                            if (track.readyState == 'live') {
                              track.stop();
                            }
                          });
                        });
                      },
                      child: const Text('Start Listening...'))),
              Visibility(
                  visible: !_isShow,
                  child: ElevatedButton(
                      onPressed: () {
                        stopRecording();
                      },
                      child: const Text('Stop Listening'))),
              Text(
                'Recording Result',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                width: 300,
                height: 200,
                color: Colors.blue,
                child: HtmlElementView(
                  key: UniqueKey(),
                  viewType: 'result',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*Future<MediaStream>? getUserMedia([Map<dynamic, dynamic>? constraints]) {
    return window.navigator.mediaDevices?.getUserMedia(constraints);
  }*/

  Future<html.MediaStream?> _openCamera() async {
    try {
      final html.MediaStream? stream = await html.window.navigator.mediaDevices
          ?.getUserMedia({'video': true, 'audio': true});
      _preview.srcObject = stream;
      return stream;
    } catch (err) {
      print('Error$err'); /* handle the error */
      return null;
    }

    //_preview.srcObject = stream;
    //return stream;
  }

  Future<html.MediaStream?> _openAudio() async {
    const constraints = {
      'video': false,
      'audio': {'echoCancellation': true, 'sampleSize': 16}
    };

    try {
      final html.MediaStream? stream =
          await html.window.navigator.mediaDevices?.getUserMedia(constraints);
      _audioPreview.srcObject = stream;
      print('Got audio stream: ${stream?.id}');
      return stream;
    } catch (err) {
      print('Error$err'); /* handle the error */
      return null;
    }
  }

  /* void stopRecording() {
    _recorder.stop();
  }*/
}

/*class _RecognizeContent extends StatelessWidget {
  final String? text;

  const _RecognizeContent({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const Text(
            'The text recognized by the Google Speech Api:',
          ),
          const SizedBox(
            height: 16.0,
          ),
          Text(
            text ?? '---',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}*/

