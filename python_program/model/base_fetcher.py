from typing import List
from model.post import Post
from requests_html import HTMLSession
from snownlp import SnowNLP
import pymongo
from datetime import datetime


class BaseFetcher:
    def __init__(self) -> None:
        self.session = HTMLSession()
        self.client = pymongo.MongoClient('mongodb://192.168.31.60/')
        self.time = datetime.now()

    def fetch(self):
        print("fetching...")
        stocks = self.__fetch_selected_stocks__()
        results = []
        for s in stocks:
            stock_number = s['stock_number']
            keywords = s['keywords']
            for key in keywords:
                posts = self.__fetch_content__(
                    stock_number=stock_number, keyword=key)
                results += posts
        self.__upload_posts__(results)

    def __upload_posts__(self, posts: List[Post]):
        print("Uploading...")
        mydb = self.client['stock']
        coll = mydb['posts']
        for post in posts:
            coll.update({"content": post.content}, post.toJson(), upsert=True)

    def __fetch_selected_stocks__(self):
        mydb = self.client['stock']
        coll = mydb['selected_stock']
        stocks = coll.find()
        return stocks

    def __get__sentiment_score__(self, content: str) -> float:
        s = SnowNLP(content)
        return s.sentiments

    def __fetch_content__(self, keyword: str, stock_number: float) -> List[Post]:
        raise NotImplemented
