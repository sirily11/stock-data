from typing import List
from model.post import Post
from model.base_fetcher import BaseFetcher


class SinaFetcher(BaseFetcher):

    def __fetch_content__(self, keyword: str, stock_number: float) -> List[Post]:
        url = f"https://s.weibo.com/weibo?q={keyword}"
        r = self.session.get(url)
        posts = []
        contents = r.html.find(".txt")
        for i, c in enumerate(contents):
            sentiment = self.__get__sentiment_score__(c.text)
            posts.append(Post(content=c.text, sentiment=sentiment,
                              stock_number=stock_number, time=self.time))

        return posts
