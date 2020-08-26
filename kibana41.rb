class Kibana41 < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://github.com/elastic/kibana.git", :tag => "v4.1.8", :revision => "e4f4c5bef5fbec91f0890bd08f6a622f6c4648ad"
  head "https://github.com/elastic/kibana.git"

  bottle do
    sha256 "4c69a9977417403e7ceb0cd908643a89b529189a994eb94837adbdc485d8162f" => :el_capitan
    sha256 "963cd1dbf7ae233222244a303504e1cbdf335ce2d79b947f3ed6ce93fd82c07a" => :yosemite
    sha256 "ea04294f5933f7d733747f7d78195fd1c1b3dcb87936ae8c622a28f17d59175d" => :mavericks
  end

  conflicts_with "kibana", :because => "Different versions of same formula"

  resource "node" do
    url "https://nodejs.org/dist/v4.4.4/node-v4.4.4.tar.gz"
    sha256 "53c694c203ee18e7cd393612be08c61ed6ab8b2a165260984a99c014d1741414"
  end

  def install
    resource("node").stage buildpath/"node"
    cd buildpath/"node" do
      system "./configure", "--prefix=#{libexec}/node"
      system "make", "install"
    end

    # do not download binary installs of Node.js
    inreplace buildpath/"tasks/build.js", /('download_node_binaries',)/, "// \\1"

    # do not build packages for other platforms
    if OS.mac? && Hardware::CPU.is_64_bit?
      platform = "darwin-x64"
    elsif OS.linux?
      platform = Hardware::CPU.is_64_bit? ? "linux-x64" : "linux-x86"
    else
      raise "Installing Kibana via Homebrew is only supported on Darwin x86_64, Linux i386, Linux i686, and Linux x86_64"
    end
    inreplace buildpath/"Gruntfile.js", /^(\s+)platforms: .*/, "\\1platforms: [ '#{platform}' ],"

    # do not build zip packages
    inreplace buildpath/"tasks/config/compress.js", /(build_zip: .*)/, "// \\1"

    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    system "npm", "install", "grunt-cli", "bower"
    system "npm", "install"
    system "node_modules/.bin/bower", "install"
    system "node_modules/.bin/grunt", "build"

    mkdir "tar" do
      system "tar", "--strip-components", "1", "-xf", Dir[buildpath/"target/kibana-*-#{platform}.tar.gz"].first

      rm_f Dir["bin/*.bat"]
      prefix.install "bin", "config", "plugins", "src"
    end

    inreplace "#{bin}/kibana", %r{/node/bin/node}, "/libexec/node/bin/node"

    cd prefix do
      inreplace "config/kibana.yml", %r{/var\/run\/kibana.pid}, var/"run/kibana.pid"
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"

      (var/"kibana/plugins").install Dir["plugins/*"]
      rm_rf "plugins"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
    ln_s var/"kibana/plugins", prefix/"plugins"
  end

  def caveats; <<-EOS.undent
    Plugins: #{var}/kibana/plugins/
    Config: #{etc}/kibana/
    EOS
  end

  plist_options :manual => "kibana"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/kibana</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end
