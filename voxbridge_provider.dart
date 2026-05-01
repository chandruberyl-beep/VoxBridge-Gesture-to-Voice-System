import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';

class ActivityLog {
  final String time;
  final String message;
  ActivityLog({required this.time, required this.message});
}

class VoxBridgeProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator();

  String _receivedText = '';
  String _translatedText = '';
  bool _isConnected = false;
  String _selectedLanguageCode = 'en';
  String _selectedLanguageName = 'English';
  final List<ActivityLog> _activityLog = [];

  StreamSubscription? _gestureSubscription;
  StreamSubscription? _syncSubscription;

  // ── Gesture names & phrases ───────────────────────────────────────────────
  final Map<int, String> _gestureNames = {};
  final Map<int, String> _gesturePhrases = {};

  String get receivedText => _receivedText;
  String get translatedText => _translatedText;
  bool get isConnected => _isConnected;
  String get selectedLanguageCode => _selectedLanguageCode;
  String get selectedLanguageName => _selectedLanguageName;
  List<ActivityLog> get activityLog => _activityLog;

  String getGestureName(int index) => _gestureNames[index] ?? '';
  String getGesturePhrase(int index) => _gesturePhrases[index] ?? '';

  VoxBridgeProvider() {
    _initTts();
    _startListening();
    _watchConnectionState();
    loadGestures();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_selectedLanguageCode);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  // Auto connection watcher using Firestore snapshotsInSync
  void _watchConnectionState() {
    _syncSubscription =
        FirebaseFirestore.instance.snapshotsInSync().listen((_) {
      if (!_isConnected) {
        _isConnected = true;
        _addLog('connected to firebase');
        notifyListeners();
      }
    });

    FirebaseFirestore.instance
        .collection('_health')
        .doc('ping')
        .snapshots()
        .listen(
      (_) {
        if (!_isConnected) {
          _isConnected = true;
          notifyListeners();
        }
      },
      onError: (_) {
        _isConnected = false;
        _addLog('connection lost — retrying');
        notifyListeners();
      },
    );
  }

  void _startListening() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _gestureSubscription = FirebaseFirestore.instance
        .collection('gestures')
        .doc('latest')
        .snapshots()
        .listen(
      (snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data();
        if (data == null) return;

        final text = data['text'] as String? ?? '';
        final processed = data['processed'] as bool? ?? false;

        if (text.isEmpty || processed) return;

        _receivedText = text;
        _addLog('gesture received: $text');
        notifyListeners();

        // Translate and speak
        await _translateAndSpeak(text);

        // Mark as processed
        await FirebaseFirestore.instance
            .collection('gestures')
            .doc('latest')
            .update({'processed': true});
      },
      onError: (error) {
        _isConnected = false;
        _addLog('listener error — reconnecting');
        notifyListeners();
      },
    );
  }

  Future<void> _translateAndSpeak(String text) async {
    try {
      if (_selectedLanguageCode == 'en') {
        _translatedText = '';
        notifyListeners();
        await _tts.setLanguage('en-US');
        await _tts.speak(text);
        _addLog('speaking in English');
      } else {
        final translation = await _translator.translate(
          text,
          to: _selectedLanguageCode,
        );
        _translatedText = translation.text;
        _addLog('translated to $_selectedLanguageName');
        notifyListeners();

        await _tts.setLanguage(_ttsLanguageCode(_selectedLanguageCode));
        await _tts.speak(_translatedText);
        _addLog('speaking in $_selectedLanguageName');
      }
      notifyListeners();
    } catch (e) {
      _addLog('translation error — speaking original');
      await _tts.speak(text);
      notifyListeners();
    }
  }

  String _ttsLanguageCode(String code) {
    switch (code) {
      case 'hi':
        return 'hi-IN';
      case 'ta':
        return 'ta-IN';
      case 'ml':
        return 'ml-IN';
      default:
        return 'en-US';
    }
  }

  void setLanguage(String code, String name) {
    _selectedLanguageCode = code;
    _selectedLanguageName = name;
    _addLog('language set to $name');
    notifyListeners();
  }

  void _addLog(String message) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    _activityLog.add(ActivityLog(time: time, message: message));
    if (_activityLog.length > 50) _activityLog.removeAt(0);
  }

  void clearLog() {
    _activityLog.clear();
    notifyListeners();
  }

  // ── Load gestures from Firestore ──────────────────────────────────────────
  Future<void> loadGestures() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gestures')
          .doc('my_gestures')
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
      for (int i = 1; i <= 8; i++) {
        _gestureNames[i] = data['gesture_${i}_name'] as String? ?? '';
        _gesturePhrases[i] = data['gesture_${i}_phrase'] as String? ?? '';
      }
      notifyListeners();
    } catch (e) {
      _addLog('failed to load gestures');
    }
  }

  // ── Save gesture to Firestore ─────────────────────────────────────────────
  Future<void> updateGesture(int index, String phrase, String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      _gestureNames[index] = name;
      _gesturePhrases[index] = phrase;
      notifyListeners();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('gestures')
          .doc('my_gestures')
          .set({
        'gesture_${index}_name': name,
        'gesture_${index}_phrase': phrase,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _addLog('gesture $index updated: $phrase');
    } catch (e) {
      _addLog('failed to save gesture $index');
    }
  }

  @override
  void dispose() {
    _gestureSubscription?.cancel();
    _syncSubscription?.cancel();
    _tts.stop();
    super.dispose();
  }
}
