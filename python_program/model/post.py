class Post:
    def __init__(self, content: str, sentiment: float, stock_number: str, time):
        self.content = content
        self.sentiment = sentiment
        self.stock_number = stock_number
        self.time = time

    def toJson(self):
        return {
            "sentiment": self.sentiment,
            "content": self.content,
            "stock_number": self.stock_number,
            "time": self.time
        }