import 'package:HackRU/screens/login.dart';
import 'package:HackRU/screens/scanner2.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'colors.dart';
import 'package:hidden_drawer_menu/hidden_drawer/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/menu/item_hidden_menu.dart';
import 'package:hidden_drawer_menu/hidden_drawer/screen_hidden_drawer.dart';
import 'package:HackRU/screens/about.dart';
import 'package:HackRU/screens/map.dart';
import 'package:HackRU/screens/help.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:HackRU/screens/home.dart';
import 'package:HackRU/filestore.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackRU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: bluegrey_dark,
        accentColor: mintgreen_light,
      ),
      home: Login(),
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => new Login(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ScreenHiddenDrawer> items = new List();

  @override
  void initState() {
    items.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: "Home",
          baseStyle: TextStyle( color: Colors.white.withOpacity(0.8), fontSize: 28.0 ),
          colorLineSelected: mintgreen_light,
        ),
        Home()));

    items.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: "Map",
          baseStyle: TextStyle( color: Colors.white.withOpacity(0.8), fontSize: 28.0 ),
          colorLineSelected: pink_light,
        ),
        Map()));

    items.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: "Help",
          baseStyle: TextStyle( color: Colors.white.withOpacity(0.8), fontSize: 28.0 ),
          colorLineSelected: mintgreen_dark,
        ),
        Help()));

    items.add(new ScreenHiddenDrawer(
        new ItemHiddenMenu(
          name: "About",
          baseStyle: TextStyle( color: Colors.white.withOpacity(0.8), fontSize: 28.0 ),
          colorLineSelected: pink_dark,
        ),
        About()));


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      actionsAppBar: <Widget>[
        IconButton(icon: Icon(GroovinMaterialIcons.logout, color: pink_light,),
          color: pink_light,
          splashColor: pink_light,
          onPressed: (){
            Navigator.of(context).pushAndRemoveUntil(new MaterialPageRoute( builder: (BuildContext context) => Login()), ModalRoute.withName('/login'));
            deleteStoredCredential();
        })
      ],
      backgroundColorMenu: bluegrey_dark,
      backgroundColorAppBar: bluegrey_dark,
      elevationAppBar: 0,
      backgroundMenu: DecorationImage(image: ExactAssetImage('assets/images/drawer_bg.png'),fit: BoxFit.cover),
      screens: items,
      iconMenuAppBar: Icon(Icons.arrow_back, color: mintgreen_light,),
    );

  }
}
