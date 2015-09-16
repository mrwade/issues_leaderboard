var path = require('path');

module.exports = {
  entry: "./web/static/js/app.js",

  output: {
    path: "./priv/static/js",
    filename: "app.js"
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        include: path.join(__dirname),
        exclude: /node_modules/,
        loaders: ['babel-loader']
      }
    ]
  }
};
