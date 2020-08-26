class Redis26 < Formula
  desc "Persistent key-value database, built-in net interface"
  homepage "http://redis.io/"
  url "http://download.redis.io/releases/redis-2.6.17.tar.gz"
  sha256 "5a65b54bb6deef2a8a4fabd7bd6962654a5d35787e68f732f471bbf117f4768e"

  bottle do
    cellar :any
    sha256 "1c0c9565f242a1e34d171950a341e2f38372e49cc5420162c73cf2c39ef2c682" => :yosemite
    sha256 "f4abb52ec0ef232b85aae9c0e3bbc6cfdfca3e43daeef38e46f3eaeb35644b45" => :mavericks
    sha256 "4d936a5010e9b50f1c9c347192f11e0b8e365a1948455f6b27415d1a28e35b50" => :mountain_lion
  end

  conflicts_with "redis",
                 :because => "Differing version of Homebrew/homebrew Redis"

  def install
    # Architecture isn't detected correctly on 32bit Snow Leopard without help
    ENV["OBJARCH"] = MacOS.prefer_64_bit? ? "-arch x86_64" : "-arch i386"

    # Head and stable have different code layouts
    src = (buildpath/"src/Makefile").exist? ? buildpath/"src" : buildpath
    system "make", "-C", src, "CC=#{ENV.cc}"

    %w[benchmark cli server check-dump check-aof].each { |p| bin.install src/"redis-#{p}" }
    %w[run db/redis log].each { |p| (var+p).mkpath }

    # Fix up default conf file to match our paths
    inreplace "redis.conf" do |s|
      s.gsub! "/var/run/redis.pid", "#{var}/run/redis.pid"
      s.gsub! "dir ./", "dir #{var}/db/redis/"
      s.gsub! "\# bind 127.0.0.1", "bind 127.0.0.1"
    end

    etc.install "redis.conf" unless (etc/"redis.conf").exist?
  end

  plist_options :manual => "redis-server #{HOMEBREW_PREFIX}/etc/redis.conf"

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
          <string>#{opt_prefix}/bin/redis-server</string>
          <string>#{etc}/redis.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/redis.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/redis.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/redis-server", "--version"
  end
end
