FROM google/dart

WORKDIR dart-program
COPY . .
RUN pub get
RUN dart2native bin/stock_data.dart -o run
RUN ls
CMD ["./run"]