class Swig304 < Formula
  desc "Generate scripting interfaces to C/C++ code"
  homepage "http://www.swig.org/"
  url "https://downloads.sourceforge.net/project/swig/swig/swig-3.0.4/swig-3.0.4.tar.gz"
  sha256 "410ffa80ef5535244b500933d70c1b65206333b546ca5a6c89373afb65413795"

  bottle do
    sha256 "cf966237371c601faf71b6bd08dd362b501831a528a142a87b3858ff076039e9" => :yosemite
    sha256 "f19c10ac219d5964fe4ccfb20b4c6e397a37c8e0ff8dffdf4a0c8a72c9552339" => :mavericks
    sha256 "d595676661e73d64a6a7cbd6a7ad180ea7dc5da1870b29c314fb8d7832375862" => :mountain_lion
  end

  option :universal

  depends_on "pcre"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      int add(int x, int y)
      {
        return x + y;
      }
    EOS
    (testpath/"test.i").write <<-EOS.undent
      %module test
      %inline %{
      extern int add(int x, int y);
      %}
    EOS
    (testpath/"run.rb").write <<-EOS.undent
      require "./test"
      puts Test.add(1, 1)
    EOS
    system "#{bin}/swig", "-ruby", "test.i"
    system ENV.cc, "-c", "test.c"
    system ENV.cc, "-c", "test_wrap.c", "-I/System/Library/Frameworks/Ruby.framework/Headers/"
    system ENV.cc, "-bundle", "-flat_namespace", "-undefined", "suppress", "test.o", "test_wrap.o", "-o", "test.bundle"
    assert_equal "2", shell_output("ruby run.rb").strip
  end
end
