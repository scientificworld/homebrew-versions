class Perl518 < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz"
  sha256 "7cbed5ef11900e8f68041215eea0de5e443d53393f84c41d5c9c69c150a4982f"

  bottle do
    sha256 "5dd29dc3db33fef36b20f65846097c6baf8b3bd52733d0de39b97dc333089a9c" => :yosemite
    sha256 "6f668e0501e54013a4dc1483aeed25b3c9ecd60976fc78b198c0e8f27d3d4842" => :mavericks
    sha256 "301f4d292b2936d97de340e691d86ad541f8dcc7eb56db8d0785df288494d194" => :mountain_lion
  end

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes"
  option "with-tests", "Build and run the test suite"

  deprecated_option "use-dtrace" => "with-dtrace"

  def install
    args = [
      "-des",
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      "-Duseshrplib",
      "-Duselargefiles",
      "-Dusethreads",
    ]

    args << "-Dusedtrace" if build.with? "dtrace"

    system "./Configure", *args
    system "make"
    system "make", "test" if build.with? "tests"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    By default Perl installs modules in your HOME dir. If this is an issue run:
      #{bin}/cpan o conf init
    EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end
end
