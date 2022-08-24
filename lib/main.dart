import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_guide/models/transaction.dart';
import 'package:flutter_guide/widgets/chart.dart';
import 'package:flutter_guide/widgets/new_transaction.dart';
import 'package:flutter_guide/widgets/transaction_list.dart';
import 'package:intl/intl.dart';
import './models/transaction.dart';

void main() {

  //stop portrait mode rotation
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(
          secondary: Colors.amber,
        ),
        errorColor: Colors.red,
        fontFamily: 'QuickSand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
        appBarTheme: AppBarTheme(
            toolbarTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  headline6:
                      const TextStyle(fontFamily: 'OpenSans', fontSize: 20),
                )
                .bodyText2,
            titleTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                  button: const TextStyle(color: Colors.white),
                  headline6: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
                .headline6),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
          ),
        ),
      ),
      title: 'Personal Expenses',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // final List<Transaction> transaction = [];

  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'New shoes',
    //   amount: 99.99,
    //   date: DateTime.now(),
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Weekly grocery',
    //   amount: 16.54,
    //   date: DateTime.now(),
    // ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void didChangeAppLifeCycleState(AppLifecycleState state){
    print(state);
  }

  @override
  dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransaction {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(
        const Duration(days: 7),
      ));
    }).toList();
  }

  bool _showChart = false;

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime choosenDate) {
    final newTx = Transaction(
      id: DateTime.now().toString(),
      title: txTitle,
      amount: txAmount,
      date: choosenDate,
    );
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((element) => element.id == id);
    });
  }

  // late String titleInput;
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTransaction(_addNewTransaction),
        );
      },
    );
  }

  List <Widget> _buildLandscapContent(MediaQueryData mediaQuery , PreferredSizeWidget appBar,Widget txListWidget){
    return [Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Show Chart',style: Theme.of(context).textTheme.headline6,),
        Switch.adaptive(value: _showChart, onChanged: (val){
          setState(() {
            _showChart = val;
          });
        })
      ],
    ),
      _showChart
          ?  SizedBox(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
            0.7,
        child: Chart(_recentTransaction),
      )
          : txListWidget
    ];
  }

  List <Widget> _buildPortraitContent(MediaQueryData mediaQuery , PreferredSizeWidget appBar,Widget txListWidget){
    return [ SizedBox(
      height: (mediaQuery.size.height -
          appBar.preferredSize.height -
          mediaQuery.padding.top) *
          0.3,
      child: Chart(_recentTransaction),
    ),txListWidget];
  }

  @override
  Widget build(BuildContext context) {
    final isLandScaped = MediaQuery.of(context).orientation == Orientation.landscape;
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = (Platform.isIOS ?  CupertinoNavigationBar(
      middle: const Text(
        'Personal Expenses',
        style: TextStyle(fontFamily: 'Open Sans'),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
       GestureDetector(
         child: const Icon(CupertinoIcons.add),
         onTap: () => _startAddNewTransaction(context),
       )
      ],),
    ) : AppBar(
      title: const Text(
        'Personal Expenses',
        style: TextStyle(fontFamily: 'Open Sans'),
      ),
      actions: [
        IconButton(
            onPressed: () => _startAddNewTransaction(context),
            icon: const Icon(Icons.add))
      ],
    )) as PreferredSizeWidget;
    final txListWidget = SizedBox(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
            0.7,
        child: TransactionList(_userTransactions, _deleteTransaction));

    final pageBody = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLandScaped) ..._buildLandscapContent(mediaQuery, appBar,txListWidget),
          if(!isLandScaped)
            ..._buildPortraitContent(mediaQuery, appBar,txListWidget),

        ],
      ),
    );

    return Platform.isIOS ?  CupertinoPageScaffold( navigationBar: appBar as ObstructingPreferredSizeWidget, child: pageBody ,)  :
    Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Platform.isIOS ? Container() : FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
