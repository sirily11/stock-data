import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:puppeteer/puppeteer.dart';

import 'StockData.dart';

import 'package:meta/meta.dart';

class StockDataFetcher {
  final String stockID;

  @override
  String toString() {
    return "<StockDataFetcher: $stockID />";
  }

  String get _url {
    return 'http://quote.eastmoney.com/f1.html?code=$stockID&market=1';
  }

  StockDataFetcher({@required this.stockID});

  static Future<List<StockDataFetcher>> getDataFetcher() async {
    var db = Db("mongodb://192.168.31.60:27017/stock");
    await db.open();
    var coll = db.collection('selected_stock');

    var documents = await coll.find().toList();
    return documents
        .map<StockDataFetcher>(
            (e) => StockDataFetcher(stockID: e['stock_number']))
        .toList();
  }

  Future<String> _getTime(Page page) async {
    var result = await page.evaluate<String>(r'''
    result =>{
      return document.querySelector("#day").innerText
    }
    ''');
    result = result.replaceAll('（', '');
    result = result.replaceAll(')', '');
    var results = result.split(' ');
    return results[0];
  }

  Future<List<StockData>> fetch() async {
    List<StockData> ret = [];
    var browser = await puppeteer.launch(headless: true);
    var page = await browser.newPage();

    await page.goto(_url, wait: Until.networkAlmostIdle);
    await page.waitForSelector('.contentDiv');

    var time = await _getTime(page);

    while (true) {
      print("Fetching");
      var results = await page.evaluate<List>(r'''
    //language=js
    results => {
    let table = document.querySelector('.contentDiv')
    let tableContents = Array.from(table.querySelectorAll('tbody'))
    return tableContents.map((tc) => {
    let entries = Array.from(tc.querySelectorAll('tr'))
    return entries.map((entry) =>{
        let contents =  Array.from(entry.querySelectorAll('td'))
          return {
           time: contents[0].innerText,
            price: contents[1].innerText,
            volumn: contents[2].innerText
        }

    })
    });
}
''', args: [1]);
      results.forEach((element) {
        var l = (element as List).map((e) {
          e['time'] = '$time ${e['time']}';
          e['stock'] = '$stockID';
          return StockData.fromJson(e);
        }).toList();

        var fl = l.where((element) => !ret.contains(element)).toList();
        ret.addAll(fl);
      });

      await Future.delayed(Duration(milliseconds: 2000));
      if (await _goToNext(page)) {
        print('${ret.last.time} - ${ret.length}');
      } else {
        break;
      }
    }
    await browser.close();
    return ret;
  }

  Future<void> writeToDB(List<StockData> data) async {
    var db = Db("mongodb://192.168.31.60:27017/stock");
    await db.open();
    var coll = db.collection('stock_data');
    await coll.insertAll(data.map((e) => e.toJson()).toList());
    print('Upload finished');
  }

  Future<bool> _goToNext(Page page) async {
    try{
      await page.click('.liPage.nextPage.canClick');
      return true;
    } catch(err){
      return false;
    }

  }

}
