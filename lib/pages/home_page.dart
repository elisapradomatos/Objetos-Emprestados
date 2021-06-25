import 'package:borrowed_stuff/components/centered_circular_progress.dart';
import 'package:borrowed_stuff/components/centered_message.dart';
import 'package:borrowed_stuff/components/stuff_card.dart';
import 'package:borrowed_stuff/controllers/home_controller.dart';
import 'package:borrowed_stuff/models/stuff.dart';
import 'package:borrowed_stuff/pages/sutff_detail_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:borrowed_stuff/components/app_constants.dart';
import 'package:borrowed_stuff/pages/settings_screen.dart';
import 'package:borrowed_stuff/pages/card_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();
  bool _loading = true;
  var _isDarkMode;

  @override
  void initState() {
    super.initState();
    _controller.readAll().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Objetos Emprestados'),
        actions: [
         _settings(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: Stack( children: <Widget>[
        _buildStuffList(),
        _backgroundAnimWidget(),
        //_cardWidget(),



      ]
      ),
      );

  }

  _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      label: Text('Emprestar'),
      icon: Icon(Icons.add),
      onPressed: _addStuff,
    );
  }

  _buildStuffList() {
    if (_loading) {
      return CenteredCircularProgress();
    }

    if (_controller.stuffList.isEmpty) {
      return CenteredMessage('Vazio', icon: Icons.warning);
    }

    return ListView.builder(
      itemCount: _controller.stuffList.length,
      itemBuilder: (context, index) {
        final stuff = _controller.stuffList[index];
        return StuffCard(
          stuff: stuff,
          onDelete: () {
            _deleteStuff(stuff);
          },
          onEdit: () {
            _editStuff(index, stuff);
          },
          onCall: () {
            _callStuff(stuff);
          },
        );
      },
    );
  }

  _addStuff() async {
    print('New stuff');
    final stuff = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StuffDetailPage()),
    );

    if (stuff != null) {
      setState(() {
        _controller.create(stuff);
      });

      Flushbar(
        title: "Novo empréstimo",
        backgroundColor: Colors.black,
        message: "${stuff.description} emprestado para ${stuff.contactName}.",
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  _editStuff(index, stuff) async {
    print('Edit stuff');
    final editedStuff = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StuffDetailPage(editedStuff: stuff)),
    );

    if (editedStuff != null) {
      setState(() {
        _controller.update(index, editedStuff);
      });

      Flushbar(
        title: "Empréstimo atualizado",
        backgroundColor: Colors.blue,
        message:
            "${editedStuff.description} emprestado para ${editedStuff.contactName}.",
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  _deleteStuff(Stuff stuff) {
     print('Delete stuff');
    setState(() {
      _controller.delete(stuff);
    });

    Flushbar(
      title: "Exclusão",
      backgroundColor: Colors.red,
      message: "${stuff.description} excluido com sucesso.",
      duration: Duration(seconds: 2),
    )..show(context);
  }


  _callStuff(Stuff stuff) async {
   // print('Call stuff');
   final url = "tel:" + stuff.phone;

   if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }

  }



  _backgroundAnimWidget() {
    return Center(
      child: FlareActor(Constants.background_anim,
          alignment: Alignment.center,
          fit: BoxFit.fill,
          animation: _isDarkMode
              ? Constants.night_animation
              : Constants.day_animation),
    );
  }

  _cardWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 70, left: 30, right: 30),
            child: CardWidgetScreen(),
          ),
        ),
        SizedBox(
          height: 150,
        ),
      ],
    );
  }


  _settings() {
    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).accentIconTheme.color,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingScreen()),
            );
          },
        ),
      ),
    );
  }

}
