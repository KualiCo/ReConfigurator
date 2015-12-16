module.exports = {
  entry: './src/index.js',

  output: {
    path: './dist',
    filename: 'index.js'
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },

  module: {
    loaders: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file?name=[name].[ext]'
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm'
      },
      {
        test: /\.styl/,
        exclude: [/node_modules/],
        loader: 'style!css!stylus'
      }
    ],

    noParse: /\.elm$/
  },

  devServer: {
    inline: true,
    stats: 'errors-only',
    proxy: {
      '/api/cm*': {
        target: 'http://monsters.kuali.dev:3000',
        secure: false,
        changeOrigin: true
      }
    }
  }
}
