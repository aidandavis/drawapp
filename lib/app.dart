import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drawappFirebase/draw_page.dart';
import 'package:drawappFirebase/bloc/painter_bloc.dart';
import 'package:flutter/material.dart';

class DrawApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DrawApp',
      home: ChooseRoom(),
    );
  }
}

class ChooseRoom extends StatefulWidget {
  @override
  _chooseRoomState createState() => _chooseRoomState();
}

class _chooseRoomState extends State<ChooseRoom> {
  String _messageText;
  String _chosenRoom;

  final _roomEntryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // reset message text when typing
    _roomEntryController.addListener(() {
      setState(() {
        _messageText = null;
      });
    });
  }

  _createNewRoom() async {
    final newRoomName = UniqueKey().toString().substring(2, 7);

    await Firestore.instance
        .collection('canvases')
        .document(newRoomName)
        .setData({'timeCreated': Timestamp.now()});

    setState(() {
      _roomEntryController.clear();
      _chosenRoom = newRoomName;
      _messageText = null;
    });
  }

  _tryRoom() async {
    if (_roomEntryController.text.length != 5) {
      setState(() {
        _messageText = 'Room names are 5 characters long.';
      });
      return;
    }

    final roomDoc = await Firestore.instance
        .collection('canvases')
        .document(_roomEntryController.text)
        .get();

    print(roomDoc.exists);

    if (roomDoc.exists) {
      setState(() {
        _chosenRoom = _roomEntryController.text;
        _roomEntryController.clear();
        _messageText = null;
      });
    } else {
      setState(() {
        _messageText = "Couldn't find the room, try again.";
      });
    }
  }

  @override
  void dispose() {
    _roomEntryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _chosenRoom != null
            ? Text('Room $_chosenRoom')
            : Text('Enter or Create a Room'),
        centerTitle: true,
        actions: _chosenRoom != null
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    setState(() {
                      _chosenRoom = null;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: _chosenRoom != null
          ? BlocProvider<PainterBloc>(
              child: DrawPage(),
              bloc: PainterBloc(_chosenRoom),
            )
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: MaterialButton(
                    child: Text(
                      'New Room',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: () => _createNewRoom(),
                    color: Colors.green,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _roomEntryController,
                    onSubmitted: (_) => _tryRoom(),
                    autofocus: true,
                    maxLength: 5,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                        labelText: 'Enter the 5-character Room name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                        )),
                  ),
                ),
                MaterialButton(
                  child: Text(
                    'Try the room you just typed...',
                    style: TextStyle(fontSize: 16),
                  ),
                  color: Colors.amberAccent,
                  onPressed: () => _tryRoom(),
                ),
                _messageText != null ? Text(_messageText) : null,
              ].where((item) => item != null).toList(),
            ),
    );
  }
}
