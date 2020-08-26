class Phantomjs192 < Formula
  homepage "http://www.phantomjs.org/"
  url "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/phantomjs/phantomjs-1.9.2-macosx.zip"
  sha256 "85a1ddc5c5acb630abbfdc10617b5b248856d400218a9ec14872c7e1afef6698"

  depends_on :macos => :snow_leopard

  def install
    bin.install "bin/phantomjs"
  end
end
