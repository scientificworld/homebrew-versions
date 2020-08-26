class Perl514 < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz"
  mirror "https://mirrors.kernel.org/debian/pool/main/p/perl/perl_5.14.2.orig.tar.bz2"
  sha256 "803fd44c492fcef79fda456a6f50455766e00ddec2e568a543630f65ff3f44cb"

  bottle do
    sha256 "36d658ad1c0590f496b583024902136b071f217baf55e3e26704a67dc051f6c5" => :yosemite
    sha256 "abf06637a284ed6028f8795bc12eb87572992e8daf9b2d7cc9d77797dfd31f2d" => :mavericks
    sha256 "1531ddcaef9299f4951e404f3de775e9229479ae5640bd4116623c920f69f882" => :mountain_lion
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
