class Redis28 < Formula
  homepage "http://redis.io/"
  url "http://download.redis.io/releases/redis-2.8.21.tar.gz"
  sha256 "3da371693bb54c22da04d86cab1b871072c8d19bdfbc4f811469b7b53384c563"

  bottle do
    cellar :any
    sha256 "a116b30423226cd4445de190acd97c955962d7ae589ccac0aaf9b9585fb5dfca" => :yosemite
    sha256 "a0b72d84d805f8fec1bc1307479ba550e620fca0198746704c23b44833e3e0bd" => :mavericks
    sha256 "82d23051ab34705cf98a00e8416ec4ea394f5f1753b82519e8f0cfc36f87f46d" => :mountain_lion
  end

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = MacOS.prefer_64_bit? ? "-arch x86_64" : "-arch i386"

    # Head and stable have different code layouts
    src = (buildpath/"src/Makefile").exist? ? buildpath/"src" : buildpath
    system "make", "-C", src, "CC=#{ENV.cc}"

    %w[benchmark cli server check-dump check-aof sentinel].each { |p| bin.install src/"redis-#{p}" => "redis28-#{p}" }
    %w[run db/redis28 log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis-2.8.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis28/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end

    etc.install "redis.conf" => "redis28.conf" unless (etc/"redis28.conf").exist?
    etc.install "sentinel.conf" => "redis28-sentinel.conf" unless (etc/"redis28-sentinel.conf").exist?
  end

  plist_options :manual => "redis28-server #{HOMEBREW_PREFIX}/etc/redis28.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_prefix}/bin/redis28-server</string>
          <string>#{etc}/redis28.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/redis28.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/redis28.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    # This previously wasn't bottled. Make sure it is.
    assert File.exist?(HOMEBREW_PREFIX/"etc/redis28.conf")

    system "#{bin}/redis28-server", "--version"
  end
end
