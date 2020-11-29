import 'dart:io';

import 'package:stock_data/StockData.dart';
import 'package:stock_data/StockDataFetcher.dart';

void main(List<String> arguments) async {
  print('Start program');
  var fetchers = await StockDataFetcher.getDataFetcher();
  for(var fetcher in fetchers){
    var data = await fetcher.fetch();
    await fetcher.writeToDB(data);
    exit(0);
  }
}
