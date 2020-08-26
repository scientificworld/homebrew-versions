require "language/go"

class Mongodb30 < Formula
  desc "High-performance document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r3.0.12.tar.gz"
  sha256 "b9bea5e3d59b93775d5d55fb1dd161272aeefa193c2311a8f6722ad46d7a21ab"

  bottle do
    cellar :any_skip_relocation
    sha256 "61b1e171727f9ef4f591bf67edae88070c5641dd3de3ffe3a25e191312351bf5" => :el_capitan
    sha256 "08a60c93e6f9db053a2e395ae81726f1b5002cdd7a953a3e9207a2ee07ef05a3" => :yosemite
    sha256 "b13af26aec7da81a371d445c2d4de538e6881f4af3b1c87391ae70d31ad8dc78" => :mavericks
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  needs :cxx11

  depends_on "boost" => :optional
  depends_on "go" => :build
  depends_on :macos => :mountain_lion
  depends_on "scons" => :build
  depends_on "openssl" => :optional

  go_resource "github.com/mongodb/mongo-tools" do
    url "https://github.com/mongodb/mongo-tools.git",
      :tag => "r3.0.12",
      :revision => "81c527a658a687b83564dfb9767df64420e9bcab"
  end

  def install
    ENV.cxx11 if MacOS.version < :mavericks

    # New Go tools have their own build script but the server scons "install" target is still
    # responsible for installing them.
    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/mongodb/mongo-tools" do
      # https://github.com/Homebrew/homebrew/issues/40136
      inreplace "build.sh", '-ldflags "-X github.com/mongodb/mongo-tools/common/options.Gitspec=`git rev-parse HEAD` -X github.com/mongodb/mongo-tools/common/options.VersionStr=$(git describe)"', ""

      args = %w[]

      if build.with? "openssl"
        args << "ssl"
        ENV["LIBRARY_PATH"] = "#{Formula["openssl"].opt_prefix}/lib"
        ENV["CPATH"] = "#{Formula["openssl"].opt_prefix}/include"
      end
      system "./build.sh", *args
    end

    mkdir "src/mongo-tools"
    cp Dir["src/github.com/mongodb/mongo-tools/bin/*"], "src/mongo-tools/"

    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --osx-version-min=#{MacOS.version}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
    ]

    args << "--use-system-boost" if build.with? "boost"
    args << "--use-new-tools"
    args << "--disable-warnings-as-errors" if MacOS.version >= :yosemite

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var+"mongodb").mkpath
    (var+"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>4096</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>4096</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
