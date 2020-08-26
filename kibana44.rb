class Kibana44 < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://github.com/elastic/kibana.git", :tag => "v4.4.2", :revision => "b0ef773a465d0eb27d192ca77f881eba90ef93d5"
  head "https://github.com/elastic/kibana.git"

  conflicts_with "kibana", :because => "Different versions of same formula"

  bottle do
    sha256 "f0e5591eb069135d45391f1a923cb60aa70c07dc51a1f6fb71e3a0f0f09d7268" => :el_capitan
    sha256 "ec055fba53a6c7eee74592705b7790866cd6367ed3177d3019d937d471e5e0d3" => :yosemite
    sha256 "035f5609881e8851a6f5537b38386df488971df3297eda8b9fc7e929aa0fd545" => :mavericks
  end

  resource "node" do
    url "https://nodejs.org/dist/v4.3.2/node-v4.3.2.tar.gz"
    sha256 "1f92f6d31f7292ce56db57d6703efccf3e6c945948f5901610cefa69e78d3498"
  end

  def install
    resource("node").stage buildpath/"node"
    cd buildpath/"node" do
      system "./configure", "--prefix=#{libexec}/node"
      system "make", "install"
    end

    # do not download binary installs of Node.js
    inreplace buildpath/"tasks/build/index.js", /('_build:downloadNodeBuilds:\w+',)/, "// \\1"

    # do not build packages for other platforms
    platforms = Set.new(["darwin-x64", "linux-x64", "linux-x86", "windows"])
    if OS.mac? && Hardware::CPU.is_64_bit?
      platform = "darwin-x64"
    elsif OS.linux?
      platform = Hardware::CPU.is_64_bit? ? "linux-x64" : "linux-x86"
    else
      raise "Installing Kibana via Homebrew is only supported on Darwin x86_64, Linux i386, Linux i686, and Linux x86_64"
    end
    platforms.delete(platform)
    sub = platforms.to_a.join("|")
    inreplace buildpath/"tasks/config/platforms.js", /('(#{sub})',?(?!;))/, "// \\1"

    # do not build zip package
    inreplace buildpath/"tasks/build/archives.js", /(await exec\('zip'.*)/, "// \\1"

    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    system "npm", "install"
    system "npm", "run", "build"
    mkdir "tar" do
      system "tar", "--strip-components", "1", "-xf", Dir[buildpath/"target/kibana-*-#{platform}.tar.gz"].first

      rm_f Dir["bin/*.bat"]
      prefix.install "bin", "config", "node_modules", "optimize", "package.json", "src", "webpackShims"
    end

    inreplace "#{bin}/kibana", %r{/node/bin/node}, "/libexec/node/bin/node"

    cd prefix do
      inreplace "config/kibana.yml", "/var/run/kibana.pid", var/"run/kibana.pid"
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
    (prefix/"installedPlugins").mkdir
  end

  plist_options :manual => "kibana"

  def caveats; <<-EOS.undent
    Config: #{etc}/kibana/
    If you wish to preserve your plugins upon upgrade, make a copy of
    #{prefix}/installedPlugins before upgrading, and copy it into the
    new keg location after upgrading.
    EOS
  end

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
