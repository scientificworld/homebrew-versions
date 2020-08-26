class Phantomjs198 < Formula
  homepage "http://www.phantomjs.org/"
  url "https://github.com/ariya/phantomjs/archive/1.9.8.tar.gz"
  sha256 "3a321561677f678ca00137c47689e3379c7fe6b83f7597d2d5de187dd243f7be"

  bottle do
    cellar :any
    sha256 "be4913496eb91b9b33403f3fb747b91ea82ef41fef55046decf4a3d4b46bfc91" => :yosemite
    sha256 "d6d7437ccad4c41c23b4758ac10520d498fb2a1cc95e126838637f1e2e6dbb3b" => :mavericks
    sha256 "18f7252d93b7a9eca9b64e813aae1c04f1975189c3b1e1047ef7f4cf0dff245d" => :mountain_lion
  end

  depends_on "openssl"

  # https://github.com/Homebrew/homebrew/issues/42249
  depends_on MaximumMacOSRequirement => :yosemite

  def install
    if MacOS.prefer_64_bit?
      inreplace "src/qt/preconfig.sh", "-arch x86", "-arch x86_64"
    end
    system "./build.sh", "--confirm", "--jobs", ENV.make_jobs,
      "--qt-config", "-openssl-linked"
    bin.install "bin/phantomjs"
    (share+"phantomjs").install "examples"
  end

  test do
    path = testpath/"test.js"
    path.write <<-EOS
      console.log("hello");
      phantom.exit();
    EOS

    assert_equal "hello", shell_output("#{bin}/phantomjs #{path}").strip
  end
end
